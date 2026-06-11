힙을 동일한 크기의 **Region으로 분할**하여 가비지가 많은 Region부터 우선 수거하는 방식입니다.

## 기존 GC와의 차이

```
[기존 GC - 고정된 영역]
┌──────────┬────┬────┬──────────────────┐
│   Eden   │ S0 │ S1 │   Old Generation │
└──────────┴────┴────┴──────────────────┘
→ 영역 크기 고정, 역할 고정

[G1 GC - Region 기반]
┌───┬───┬───┬───┐
│ E │ S │ O │ E │
├───┼───┼───┼───┤
│ O │ E │ H │ S │
├───┼───┼───┼───┤
│ E │ O │ E │ O │
└───┴───┴───┴───┘
→ 각 Region이 동적으로 역할 변경
→ H: Humongous (거대 객체 전용 Region)
```

## Region 종류

|Region|설명|
|---|---|
|**Eden**|새로 생성된 객체 저장|
|**Survivor**|Minor GC 생존 객체|
|**Old**|오래 살아남은 객체|
|**Humongous**|Region 크기 50% 이상인 거대 객체|
|**Free**|아직 역할 미지정|

## 동작 단계

### 1. Young GC

```
Eden Region이 꽉 참 → STW 발생
→ Eden + Survivor Region에서 살아남은 객체
→ 새로운 Survivor Region으로 이동
→ age 초과 객체는 Old Region으로 Promotion
→ 기존 Eden Region → Free Region으로 전환
```

### 2. Concurrent Mark (동시 마킹)

```
Old Region 사용량이 임계값(기본 45%) 초과 시 시작
→ 애플리케이션과 동시에 실행 (STW 없음)

1. Initial Mark    → GC Root 마킹 (STW, 짧음)
2. Root Region Scan → Survivor Region 스캔 (동시)
3. Concurrent Mark → 전체 힙 살아있는 객체 마킹 (동시)
4. Remark          → 마킹 마무리 (STW, 짧음)
5. Cleanup         → 빈 Region 회수 (STW, 짧음)
```

### 3. Mixed GC

```
Concurrent Mark 완료 후
→ Young Region + 가비지 비율 높은 Old Region 선별 수거

가비지 비율 높은 순서대로 수거 (Garbage First!)
→ 제한된 STW 시간 내에 최대한 많은 가비지 수거
```

### 4. Full GC (최후 수단)

```
Mixed GC로도 메모리 부족 시 발생
→ 단일 스레드 Mark-Sweep-Compact (매우 느림)
→ 가능하면 발생하지 않도록 튜닝 필요
```

## 핵심 - Garbage First

```
각 Region의 가비지 비율을 추적
→ 가비지 많은 Region부터 우선 수거
→ 제한된 STW 시간 내 최대 효율 달성

Region A: 가비지 90% → 먼저 수거 O
Region B: 가비지 20% → 나중에 수거
```

## STW 목표 시간 설정

```
-XX:MaxGCPauseMillis=200  // 기본값 200ms

G1 GC는 이 목표 시간 안에 수거할 Region 수를 조절
→ 목표 시간이 짧을수록 한 번에 수거하는 양 감소
→ 목표 시간이 길수록 한 번에 수거하는 양 증가
```

## 전체 흐름

```
객체 생성 → Eden Region
     ↓ (Eden 꽉 참)
  Young GC → Survivor / Old Region으로 이동
     ↓ (Old 사용량 45% 초과)
  Concurrent Mark → 살아있는 객체 파악
     ↓
  Mixed GC → Young + Old Region 수거
     ↓ (메모리 부족)
  Full GC → 전체 수거 (최후 수단)
```

## 기존 GC와 비교

||Parallel GC|G1 GC|
|---|---|---|
|**힙 구조**|고정 영역|동적 Region|
|**STW 예측**|어려움|가능 (목표 시간 설정)|
|**힙 크기**|중규모|대규모 (4GB+)|
|**단편화**|발생 가능|Region 단위 관리로 감소|
|**Full GC**|자주 발생|최후 수단|

> G1 GC는 **STW 시간을 예측 가능하게 제어**할 수 있어, 응답시간이 중요한 대규모 서버 환경에 적합하며 Java 9부터 기본 GC로 채택되었습니다.