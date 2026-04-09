## Serial GC

단일 스레드로 GC를 수행하는 가장 단순한 GC입니다.

```
GC 발생 → 단일 스레드가 모든 GC 작업 처리
→ STW 시간이 가장 길다

Young: Copy 알고리즘ㄱ
Old:   Mark-Sweep-Compact 알고리즘
```

|항목|내용|
|---|---|
|**스레드**|단일|
|**STW**|가장 김|
|**적합한 환경**|단일 코어, 소규모 메모리|
|**JVM 옵션**|`-XX:+UseSerialGC`|

---

## Parallel GC

여러 스레드로 GC를 병렬 수행하여 STW 시간을 줄인 GC입니다.

```
GC 발생 → 여러 스레드가 동시에 GC 작업 처리
→ Serial GC보다 STW 시간 단축

Young: Parallel Copy 알고리즘
Old:   Parallel Mark-Sweep-Compact 알고리즘
```

|항목|내용|
|---|---|
|**스레드**|멀티 (기본: CPU 코어 수)|
|**STW**|Serial보다 짧음|
|**적합한 환경**|멀티코어, 처리량 중요한 서버|
|**Java 버전**|Java 8 기본값|
|**JVM 옵션**|`-XX:+UseParallelGC`|

---

## [[G1 GC]] (Garbage First GC)

힙을 동일한 크기의 **Region으로 분할**하여 가비지가 많은 Region부터 우선 수거하는 GC입니다.

```
힙을 Region으로 분할
┌───┬───┬───┬───┐
│ E │ S │ O │ E │
├───┼───┼───┼───┤
│ O │ E │ S │ O │
└───┴───┴───┴───┘
→ 가비지 비율 높은 Region부터 수거 (Garbage First)
→ STW 목표 시간 설정 가능
```

|항목|내용|
|---|---|
|**스레드**|멀티|
|**STW**|짧고 예측 가능|
|**힙 구조**|Region 기반 (동적 역할 변경)|
|**적합한 환경**|대용량 힙(4GB+), 응답시간 중요|
|**Java 버전**|Java 9+ 기본값|
|**JVM 옵션**|`-XX:+UseG1GC`|

```
// STW 목표 시간 설정 (기본 200ms)
-XX:MaxGCPauseMillis=200
```

**G1 GC 동작 단계**

```
1. Young GC    → Eden, Survivor Region 수거
2. Concurrent Mark → Old Region 동시 마킹 (STW 없음)
3. Mixed GC    → Young + 일부 Old Region 수거
4. Full GC     → 최후 수단 (가능하면 회피)
```

---

## [[ZGC]] (Z Garbage Collector)

대부분의 GC 작업을 **애플리케이션 실행과 동시에 처리**하여 STW를 극도로 최소화한 GC입니다.

```
GC 작업 대부분을 애플리케이션 스레드와 동시 수행
→ STW 시간 1ms 이하 목표
→ 힙 크기에 관계없이 일정한 STW 유지
```

|항목|내용|
|---|---|
|**스레드**|멀티 + 동시(Concurrent)|
|**STW**|1ms 이하|
|**힙 크기**|8MB ~ 16TB|
|**적합한 환경**|초저지연 서비스, 대용량 힙|
|**Java 버전**|Java 15+ (정식)|
|**JVM 옵션**|`-XX:+UseZGC`|

**ZGC 핵심 기술**

```
Colored Pointers: 객체 포인터에 GC 상태 정보 저장
Load Barriers:    객체 접근 시 GC 상태 확인
→ 애플리케이션 실행 중에도 GC 작업 가능
```

---

## 전체 비교

||Serial|Parallel|G1|ZGC|
|---|---|---|---|---|
|**스레드**|단일|멀티|멀티|멀티+동시|
|**STW**|매우 김|중간|짧음|1ms 이하|
|**처리량**|낮음|높음|높음|중간|
|**힙 크기**|소규모|중규모|대규모|초대규모|
|**Java 기본**|-|Java 8|Java 9+|-|

```
처리량 중요    → Parallel GC
응답시간 중요  → G1 GC
초저지연 필요  → ZGC
```

> 대부분의 서버 환경에서는 **G1 GC**가 적합하며, 수십 ms의 지연도 허용되지 않는 실시간 서비스에서는 **ZGC** 도입을 고려합니다.