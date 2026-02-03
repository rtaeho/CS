프로그램 **실행 도중에** 바이트코드를 네이티브 기계어로 변환하는 컴파일 방식입니다.

## 이름의 의미

```
Just-In-Time = "딱 그 순간에"

바이트코드가 실행되는 바로 그 순간(런타임)에 기계어로 컴파일한다는 뜻
```

## 동작 흐름

```
프로그램 시작
   │
   ▼
Interpreter가 바이트코드를 한 줄씩 실행
   │
   │  동시에 Profiler가 실행 횟수 카운팅
   │
   ▼
특정 코드가 임계값(기본 10,000회) 초과?
   │
   ├── No → 계속 Interpreter 실행
   │
   └── Yes → JIT Compiler가 해당 코드를 네이티브 기계어로 변환
                │
                ▼
          Code Cache에 저장
                │
                ▼
          다음 호출부터 캐싱된 기계어 직접 실행
```

## 왜 처음부터 전부 컴파일하지 않는가

```
전체 코드를 미리 컴파일하면?
─────────────────────────
프로그램 시작 시 수만 개 메서드를 전부 컴파일
→ 시작 지연 수 초 ~ 수십 초
→ 실제로는 20% 코드가 80% 시간을 차지
→ 나머지 80% 코드 컴파일은 낭비

JIT의 전략
─────────
자주 실행되는 20%만 선별 컴파일
→ 최소 비용으로 최대 성능 확보
```

## 실행 예시

```java
for (int i = 0; i < 100_000; i++) {
    compute(i);
}
```

```
i = 0          Interpreter가 compute() 해석 실행
i = 1          Interpreter가 compute() 해석 실행
...            (Profiler: "compute 호출 횟수 증가 중...")
i = 9,999      임계값 도달 → JIT 컴파일 트리거
               ┌─────────────────────────┐
               │ compute()를 기계어로 변환 │
               │ Code Cache에 저장        │
               └─────────────────────────┘
i = 10,000~    Code Cache의 기계어 직접 실행 (Interpreter 생략)
```

## JIT 내부 동작 상세

```
바이트코드
   │
   ▼
Profiler (핫스팟 감지)
   │
   ▼
IR 생성 (Intermediate Representation)
   │
   ▼
최적화 단계
   │
   ▼
네이티브 코드 생성 → Code Cache 저장
```

### 주요 최적화 기법

|기법|설명|예시|
|---|---|---|
|**Method Inlining**|메서드 호출을 본문으로 대체|`getAge()` 호출 → 필드 직접 접근|
|**Loop Unrolling**|루프를 펼쳐 분기 비용 감소|`for(4회)` → 4줄 코드로 전개|
|**Dead Code Elimination**|실행 안 되는 코드 제거|`if(false)` 블록 삭제|
|**Escape Analysis**|메서드 밖으로 안 나가는 객체를 스택에 할당|Heap 할당 회피 → GC 부담 감소|
|**Speculative Optimization**|런타임 프로파일링 기반 추측 최적화|"이 타입은 항상 String" → 타입 체크 생략|

## Speculative Optimization — JIT만의 강점

AOT는 할 수 없고 **JIT만 가능한 최적화**입니다.

```java
void process(Object obj) {
    if (obj instanceof String) {
        // 문자열 처리
    } else if (obj instanceof Integer) {
        // 숫자 처리
    }
}
```

```
[ AOT ]
컴파일 시점에는 obj에 뭐가 올지 모름
→ 모든 분기를 다 준비해야 함

[ JIT ]
Profiler: "process()에 99% String이 들어오네"
→ String 분기만 최적화된 기계어 생성
→ 나머지 분기는 드물게 발생 시 Deoptimize 후 재컴파일
```

## HotSpot JVM의 Tiered Compilation

JIT는 한 번에 최적화하지 않고 **단계적으로** 수준을 올립니다.

```
Level 0 : Interpreter               (해석 실행)
            ↓
Level 1-3 : C1 Compiler             (가벼운 최적화 + 프로파일링)
            ↓
Level 4 : C2 Compiler               (최대 최적화)
```

|컴파일러|컴파일 속도|최적화 수준|역할|
|---|---|---|---|
|**C1 (Client)**|빠름|가벼움|빠르게 기계어 전환 + 프로파일링 데이터 수집|
|**C2 (Server)**|느림|공격적|프로파일링 기반 최대 성능 최적화|

```
성능
 ▲
 │                    ┌── Level 4 (C2 최적화)
 │                   ╱
 │            ┌─────╱──── Level 3 (C1 최적화)
 │           ╱
 │     ─────╱──────────── Level 0 (Interpreter)
 │    ╱
 └──────────────────────────────────────► 시간
      빠른 시작        점진적 최적화
```

## Deoptimization — 최적화 되돌리기

JIT의 추측이 틀리면 **최적화를 철회**합니다.

```
1. Profiler: "항상 String이 들어온다"
2. JIT: String 전용 기계어 생성
3. 갑자기 Integer가 들어옴
4. Deoptimize: 최적화 코드 폐기 → Interpreter로 복귀
5. 새로운 프로파일링 → 재컴파일
```

이 덕분에 **잘못된 최적화가 프로그램을 망가뜨리지 않습니다.**

## JIT 적용 언어

|언어|JIT 엔진|
|---|---|
|**Java**|HotSpot C1/C2, GraalVM JIT|
|**C#**|.NET RyuJIT|
|**JavaScript**|V8 TurboFan, SpiderMonkey IonMonkey|
|**Python**|PyPy JIT|
|**Lua**|LuaJIT|

## AOT vs JIT 최종 비교

|항목|AOT|JIT|
|---|---|---|
|컴파일 시점|실행 전|실행 중|
|시작 속도|빠름|느림 (워밍업)|
|장기 성능|일정|워밍업 후 더 빠를 수 있음|
|런타임 최적화|불가|가능 (Speculative)|
|메모리|적음|JIT 컴파일러 + Code Cache 추가|
|플랫폼 독립성|OS마다 빌드|바이트코드 하나로 어디서든|

## 핵심 정리

JIT는 **실행 중에 자주 쓰이는 코드만 선별적으로 기계어 변환**하는 전략입니다. 모든 코드를 미리 컴파일하는 AOT와 달리, **런타임 프로파일링 데이터를 활용한 추측 최적화(Speculative Optimization)** 가 가능하며, 추측이 틀리면 Deoptimize로 안전하게 되돌립니다. 이 때문에 장기 실행 환경에서는 AOT보다 **더 높은 최대 성능**을 낼 수 있습니다.