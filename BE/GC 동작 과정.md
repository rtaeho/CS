Java의 GC는 **Young Generation의 Minor GC와 Old Generation의 Major GC**로 나뉘며, 객체의 생존 기간에 따라 단계적으로 관리됩니다.

## 전체 힙 구조

```
┌─────────────────────────────────────────────┐
│              Young Generation               │
│  ┌──────────┬─────────────┬─────────────┐   │
│  │   Eden   │  Survivor0  │  Survivor1  │   │
│  └──────────┴─────────────┴─────────────┘   │
├─────────────────────────────────────────────┤
│              Old Generation                 │
├─────────────────────────────────────────────┤
│              Metaspace                      │
│         (클래스 메타데이터)                    │
└─────────────────────────────────────────────┘
```

## 1단계 - 객체 생성 (Eden 할당)

```
new Object() 호출
→ Eden 영역에 객체 할당

Eden:  [A] [B] [C] [D] [E]
S0:    (비어있음)
S1:    (비어있음)
Old:   []
```

## 2단계 - Minor GC 발생 (Eden 꽉 참)

```
Eden이 꽉 차면 Minor GC 발생
→ STW (Stop The World) 시작
→ GC Root에서 Reachability 탐색
→ 도달 가능 객체만 S0으로 복사 + age + 1
→ Eden 전체 초기화
→ STW 종료

Eden:  (초기화)
S0:    [A(age1)] [C(age1)]   ← 살아남은 객체
S1:    (비어있음)
Old:   []
```

## 3단계 - Minor GC 반복 (Survivor 간 이동)

```
Eden 다시 꽉 참 → Minor GC 발생
Eden + S0(from)에서 살아남은 객체 → S1(to)으로 복사

Eden:  [F] [G] [H] [I] [J]
S0:    [A(age1)] [C(age1)]
↓ Minor GC
Eden:  (초기화)
S0:    (초기화)
S1:    [A(age2)] [F(age1)] [H(age1)]

→ 이후 GC마다 S0 ↔ S1 역할 교체하며 반복
```

## 4단계 - Promotion (Old Generation으로 이동)

```
age 임계값(기본 15) 초과 시 Old로 승격

S0: [A(age15)]
↓ Minor GC
Old: [A]  ← Promotion 발생

또는 Survivor 영역이 꽉 차도 Old로 바로 이동
```

## 5단계 - Major GC 발생 (Old 꽉 참)

```
Old Generation이 꽉 차면 Major GC (Full GC) 발생
→ STW 시간이 Minor GC보다 훨씬 길다

Young + Old 전체를 대상으로 GC 수행
→ Mark(표시) → Sweep(수거) → Compact(압축)
```

## Mark - Sweep - Compact 상세

**Mark 단계**

```
GC Root에서 참조 그래프 탐색
도달 가능한 객체에 표시(Mark)

Old: [AO] [BX] [CO] [DX] [EO]
```

**Sweep 단계**

```
Mark 안 된 객체 수거

Old: [AO] [  ] [CO] [  ] [EO]
     → 중간중간 빈 공간 발생 (단편화)
```

**Compact 단계**

```
살아남은 객체를 앞으로 모음 (단편화 제거)

Old: [A] [C] [E] [        빈 공간        ]
```

## [[GC 종류]]별 동작 방식

| GC              | 방식        | STW   | 특징          |
| --------------- | --------- | ----- | ----------- |
| **Serial GC**   | 단일 스레드    | 김     | 소규모 적합      |
| **Parallel GC** | 멀티 스레드    | 중간    | Java 8 기본값  |
| **G1 GC**       | Region 분할 | 짧음    | Java 9+ 기본값 |
| **ZGC**         | 동시 처리     | 매우 짧음 | Java 15+    |

## G1 GC 구조 (Java 9+ 기본)

```
힙을 동일한 크기의 Region으로 분할
→ 각 Region이 동적으로 Eden/Survivor/Old 역할 담당

┌───┬───┬───┬───┐
│ E │ S │ O │ E │
├───┼───┼───┼───┤
│ O │ E │ S │ O │
├───┼───┼───┼───┤
│ E │ O │ E │ S │
└───┴───┴───┴───┘
→ 가비지가 많은 Region부터 우선 수거
→ STW 시간 예측 가능 및 최소화
```

## Minor GC vs Major GC 비교

||Minor GC|Major GC|
|---|---|---|
|**대상**|Young Generation|Old Generation|
|**발생 시점**|Eden 꽉 찰 때|Old 꽉 찰 때|
|**STW 시간**|짧음 (ms 단위)|길음 (초 단위)|
|**빈도**|자주|드물게|
|**알고리즘**|Copy|Mark-Sweep-Compact|

## 전체 흐름 요약

```
객체 생성 → Eden
     ↓ (Eden 꽉 참)
  Minor GC → 살아남으면 Survivor (age++)
     ↓ (age 임계값 초과 or Survivor 꽉 참)
  Promotion → Old Generation
     ↓ (Old 꽉 참)
  Major GC → Mark → Sweep → Compact
```

> GC 튜닝의 핵심은 **STW 시간 최소화**로, 대부분의 객체가 Young Generation에서 수거되도록 설계하여 (약 98%) Major GC 빈도를 줄이는 것이 목표입니다.