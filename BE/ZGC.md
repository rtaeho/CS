대부분의 GC 작업을 **애플리케이션과 동시에 실행**하여 힙 크기에 관계없이 **STW를 1ms 이하**로 유지하는 초저지연 GC입니다.

## 기존 GC와의 차이

```
[G1 GC]
애플리케이션: [====]  [====]  [====]
GC:               [STW][concurrent][STW]
→ STW가 여러 번 발생

[ZGC]
애플리케이션: [========================]
GC:          [concurrent==============][STW(1ms)]
→ 거의 모든 작업을 동시에 처리
→ STW는 아주 짧게만 발생
```

## 핵심 기술

### 1. Colored Pointers (색깔 있는 포인터)

```
일반 포인터: [       메모리 주소       ]

ZGC 포인터: [GC 상태 bits][메모리 주소]
             ↑
       4가지 상태 정보 저장
       - Marked0
       - Marked1
       - Remapped
       - Finalizable

→ 포인터 자체에 GC 상태를 저장
→ 별도 자료구조 없이 객체 상태 파악 가능
```

### 2. Load Barriers (로드 배리어)

```
객체 참조 시 자동으로 GC 상태 확인

Object obj = ref;  // 일반 코드
           ↓
// ZGC가 내부적으로 처리
Object obj = ref;
if (ref의 포인터 상태 확인 필요) {
    // 필요한 GC 작업 수행 (재배치 등)
}

→ 애플리케이션 실행 중에도 GC 작업 가능
→ STW 없이 객체 이동 가능
```

## 동작 단계

```
1. Initial Mark (STW - 1ms 이하)
   GC Root 마킹

2. Concurrent Mark (동시)
   애플리케이션과 동시에 전체 힙 마킹

3. Remark (STW - 1ms 이하)
   마킹 마무리

4. Concurrent Prepare for Relocation (동시)
   이동시킬 Region 선별

5. Initial Relocation (STW - 1ms 이하)
   GC Root가 참조하는 객체 이동

6. Concurrent Relocation (동시)
   나머지 객체 이동 (애플리케이션과 동시)
   Load Barrier가 이동된 참조 자동 수정
```

## STW 비교

```
힙 크기 100GB 가정

Parallel GC: STW 수십 초
G1 GC:       STW 수백 ms
ZGC:         STW 1ms 이하 O (힙 크기 무관)
```

## 장단점

|장점|단점|
|---|---|
|STW 1ms 이하|Load Barrier로 인한 CPU 오버헤드|
|힙 크기 무관한 일정한 STW|처리량(Throughput)이 G1보다 낮음|
|8MB ~ 16TB 힙 지원|Java 15+ (비교적 최신)|
|대규모 힙에서도 안정적|튜닝 옵션 적음|

## GC 선택 기준

```
처리량(Throughput) 중요    → Parallel GC
응답시간 + 대용량 힙       → G1 GC
초저지연 (1ms 이하)        → ZGC
```

## Java 버전별 ZGC

|버전|내용|
|---|---|
|**Java 11**|실험적 도입|
|**Java 15**|정식 출시|
|**Java 16**|동시 스레드 스택 처리 추가|
|**Java 21**|세대별 ZGC 도입 (Young/Old 분리)|

```
// ZGC 활성화
-XX:+UseZGC

// Java 21 세대별 ZGC
-XX:+UseZGC -XX:+ZGenerational
```

> ZGC는 **힙 크기가 커져도 STW가 늘어나지 않는** 것이 핵심 장점으로, 수십 GB 이상의 대용량 힙을 사용하면서 응답시간이 중요한 서비스에 적합합니다.