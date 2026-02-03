JVM이 메모리에 적재된 바이트코드를 실제 기계어로 변환·실행하는 핵심 엔진입니다.

## 전체 위치

```
.class (바이트코드)
   │
   ▼
┌──────────── JVM ────────────┐
│  Class Loader               │
│       ▼                     │
│  Runtime Data Area          │
│       ▼                     │
│  ┌─ Execution Engine ─────┐ │
│  │  Interpreter            │ │
│  │  JIT Compiler           │ │
│  │  Garbage Collector      │ │
│  └─────────────────────────┘ │
│       ▼                     │
│  Native Method Interface    │
└─────────────────────────────┘
   ▼
  OS / CPU
```

## 3대 구성 요소

### 1. Interpreter (인터프리터)

바이트코드를 **한 줄씩 읽어 즉시 실행**합니다.

```
bytecode: iconst_1     →  해석 → 실행
          iconst_2     →  해석 → 실행
          iadd         →  해석 → 실행
          istore_1     →  해석 → 실행
```

|장점|단점|
|---|---|
|초기 실행 속도가 빠름 (컴파일 대기 없음)|같은 코드를 반복 실행해도 매번 해석|
|메모리 사용이 적음|루프·핫스팟 코드에서 성능 저하|

### 2. [[JIT]] Compiler (Just-In-Time 컴파일러)

반복 실행되는 **핫스팟(Hot Spot) 코드**를 감지해 **네이티브 코드로 일괄 컴파일**하고 캐싱합니다.

```
최초 호출       → Interpreter가 실행
반복 호출 감지   → JIT가 네이티브 코드로 컴파일
이후 호출       → 캐싱된 네이티브 코드 직접 실행 (해석 생략)
```

#### JIT 내부 동작 흐름

```
바이트코드
   │
   ▼
Profiler (실행 횟수 카운팅)
   │  임계값 초과?
   ▼
IR 생성 (Intermediate Representation)
   │
   ▼
최적화 (Inlining, Dead Code 제거, Loop 최적화 등)
   │
   ▼
네이티브 코드 생성 → Code Cache에 저장
```

#### JIT 컴파일러 종류 (HotSpot JVM)

|컴파일러|별칭|특징|
|---|---|---|
|**C1**|Client Compiler|가벼운 최적화, 빠른 컴파일 → 시작 속도 중시|
|**C2**|Server Compiler|공격적 최적화, 느린 컴파일 → 최대 실행 속도 중시|
|**Tiered**|(기본값)|C1 → C2 단계적 적용으로 양쪽 장점 활용|

#### Tiered Compilation 5단계

```
Level 0 : Interpreter
Level 1 : C1 (프로파일링 없음, 단순 메서드)
Level 2 : C1 (제한적 프로파일링)
Level 3 : C1 (전체 프로파일링)         ← 대부분 여기서 시작
Level 4 : C2 (최대 최적화)            ← 핫스팟 코드 최종 도달
```

#### 주요 JIT 최적화 기법

|기법|설명|예시|
|---|---|---|
|**Method Inlining**|메서드 호출을 본문으로 대체|`getAge()` → 필드 직접 접근|
|**Loop Unrolling**|루프 반복을 펼쳐 분기 비용 감소|4회 반복 → 4줄로 전개|
|**Dead Code Elimination**|실행되지 않는 코드 제거|`if(false)` 블록 삭제|
|**Escape Analysis**|객체가 메서드 밖으로 안 나가면 스택 할당|Heap 할당 회피 → GC 부담 감소|
|**Null Check Elimination**|불필요한 null 체크 제거|프로파일링으로 항상 non-null 확인 시|

### 3. Garbage Collector (가비지 컬렉터)

Heap 영역에서 **더 이상 참조되지 않는 객체를 자동 회수**합니다.

```java
void example() {
    Object a = new Object();  // Heap에 할당
    a = null;                  // 참조 끊김 → GC 대상
}
```

#### GC 동작 영역

```
┌─── Young Gen ───┐       ┌─── Old Gen ───┐
│ Eden │ S0 │ S1  │       │               │
│  Minor GC       │       │   Major GC    │
│  (빈번, 빠름)   │       │  (드묾, 느림)  │
└─────────────────┘       └───────────────┘
```

#### 주요 GC 알고리즘

|GC|특징|적합 환경|
|---|---|---|
|**Serial**|단일 스레드, Stop-The-World|소규모 앱, 클라이언트|
|**Parallel**|멀티 스레드 GC|처리량(Throughput) 중시|
|**G1**|Heap을 Region 단위 관리 (Java 9+ 기본)|범용, 대용량 힙|
|**ZGC**|수 ms 이하 pause, TB급 힙 지원|초저지연 요구 서비스|
|**Shenandoah**|ZGC와 유사, RedHat 주도|저지연 요구 서비스|

## Interpreter vs JIT 비교

|항목|Interpreter|JIT Compiler|
|---|---|---|
|변환 단위|한 줄씩|메서드·블록 단위|
|실행 시점|즉시|임계값 초과 후|
|결과 캐싱|✗|✓ (Code Cache)|
|초기 속도|빠름|컴파일 오버헤드 있음|
|반복 실행 성능|느림|빠름 (네이티브 수준)|

## 실행 예시

```java
for (int i = 0; i < 100_000; i++) {
    compute(i);   // 반복 호출
}
```

```
i = 0~999       → Interpreter가 해석·실행
i = 1,000 부근  → Profiler가 "핫스팟" 감지, C1 컴파일 트리거
i = 5,000 부근  → C2 최적화 컴파일 완료
i = 5,001~      → Code Cache의 네이티브 코드 직접 실행
```

## 핵심 정리

Execution Engine은 **Interpreter로 빠르게 시작**하고, **JIT Compiler로 반복 코드를 최적화**하며, **GC로 메모리를 자동 관리**합니다. 이 세 가지가 협력하여 Java가 "한 번 작성하면 어디서든, 충분히 빠르게, 메모리 걱정 없이" 실행될 수 있도록 보장합니다.