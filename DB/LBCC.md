Lock-Based Concurrency Control(LBCC)은 **트랜잭션이 데이터에 접근할 때 락(Lock)을 획득하여 다른 트랜잭션의 접근을 제어하는 동시성 제어 기법**입니다.

## MVCC와의 관계

```
[동시성 제어의 두 가지 큰 축]

LBCC (Lock-Based)              MVCC (Multi-Version)
├─ 데이터에 락을 걸어 접근 차단    ├─ 데이터의 여러 버전을 유지
├─ 읽기-쓰기 서로 차단            ├─ 읽기-쓰기 서로 차단하지 않음
├─ 정합성 확실                   ├─ 동시성 높음
└─ 동시성 낮음                   └─ 쓰기-쓰기는 여전히 락 필요

→ 현대 DB는 MVCC를 기본으로 사용하되
→ 쓰기-쓰기 충돌 등 MVCC만으로 부족한 부분에 LBCC를 보조적으로 사용
→ 즉, 대부분의 DB는 MVCC + LBCC를 함께 사용
```

## LBCC의 핵심 개념

### 락의 종류

```
[공유 락 (Shared Lock, S-Lock)]
읽기 락. 여러 트랜잭션이 동시에 획득 가능

트랜잭션A: S-Lock 획득 → 읽기 ✅
트랜잭션B: S-Lock 획득 → 읽기 ✅ (동시 가능)
트랜잭션C: X-Lock 획득 시도 → 대기 ⏳ (S-Lock과 충돌)

→ 읽는 동안 다른 트랜잭션이 수정하지 못하게 보호
→ 읽기끼리는 서로 차단하지 않음

[배타 락 (Exclusive Lock, X-Lock)]
쓰기 락. 하나의 트랜잭션만 획득 가능

트랜잭션A: X-Lock 획득 → 쓰기 ✅
트랜잭션B: S-Lock 획득 시도 → 대기 ⏳
트랜잭션C: X-Lock 획득 시도 → 대기 ⏳

→ 수정하는 동안 다른 트랜잭션이 읽기/쓰기 모두 불가
```

### 락 호환성 매트릭스

```
          │ S-Lock 보유 │ X-Lock 보유 │ 락 없음
──────────┼────────────┼────────────┼────────
S-Lock 요청│  ✅ 허용    │  ❌ 대기    │ ✅ 허용
X-Lock 요청│  ❌ 대기    │  ❌ 대기    │ ✅ 허용

→ 공유-공유: 허용 (읽기-읽기 동시 가능)
→ 공유-배타: 차단 (읽기 중 수정 불가)
→ 배타-배타: 차단 (수정 중 수정 불가)
→ 배타-공유: 차단 (수정 중 읽기 불가)
```

## 락의 범위 (Granularity)

```
[락을 거는 단위]

테이블 락 (Table Lock)
├─ 테이블 전체를 잠금
├─ 구현 단순, 동시성 최저
└─ MyISAM에서 사용

페이지 락 (Page Lock)
├─ 디스크 페이지(보통 8KB~16KB) 단위 잠금
├─ SQL Server 등에서 사용
└─ 테이블 락보다 세밀, 행 락보다 거친

행 락 (Row Lock)
├─ 행(레코드) 단위 잠금
├─ 동시성 가장 높음
└─ InnoDB에서 사용

갭 락 (Gap Lock)
├─ 인덱스 레코드 사이의 빈 공간 잠금
├─ INSERT 차단 목적
└─ InnoDB REPEATABLE READ에서 사용
```

```
[동시성과 오버헤드 트레이드오프]

테이블 락  ←───────────────────→  행 락
 오버헤드 낮음                     오버헤드 높음
 동시성 낮음                       동시성 높음

테이블 락: 락 1개로 전체 관리 → 간단하지만 병목
행 락:     행마다 락 관리 → 복잡하지만 동시성 높음
```

## 2PL (Two-Phase Locking)

LBCC에서 트랜잭션의 직렬 가능성(Serializability)을 보장하기 위한 프로토콜입니다.

```
[2PL 규칙]
1. Growing Phase (확장 단계): 락을 획득만 하고 해제하지 않음
2. Shrinking Phase (수축 단계): 락을 해제만 하고 새로 획득하지 않음

→ 한 번 락을 해제하면 더 이상 새 락을 획득할 수 없음
```

```
[2PL 동작 예시]

              Growing Phase          │  Shrinking Phase
              (락 획득만)             │  (락 해제만)
                                    │
  Lock(A) ──→ Lock(B) ──→ Lock(C) ──┤──→ Unlock(A) ──→ Unlock(B) ──→ Unlock(C)
                                    │
                               Lock Point
                            (보유 락 최대)
```

```
[2PL을 위반하면?]

트랜잭션A: Lock(X) → Read(X) → Unlock(X) → Lock(Y) → Read(Y) → Unlock(Y)
                                   ↑
                     락 해제 후 새 락 획득 → 2PL 위반

→ X를 해제한 후 Y를 잠그는 사이에
→ 다른 트랜잭션이 X를 수정할 수 있음
→ 직렬 가능성 보장 불가 → 데이터 불일치 발생 가능
```

### 2PL의 변형

```
[Basic 2PL]
Growing → Shrinking
→ 데드락 발생 가능

[Strict 2PL]
Growing → 모든 X-Lock을 COMMIT/ROLLBACK까지 유지
→ 대부분의 DB가 사용하는 방식
→ Cascading Rollback 방지

[Rigorous 2PL]
Growing → 모든 락(S-Lock + X-Lock)을 COMMIT/ROLLBACK까지 유지
→ 가장 엄격
```

```
[Strict 2PL — 실제 DB 동작]

BEGIN;
  SELECT ... FOR UPDATE;  ← X-Lock 획득 (Growing)
  UPDATE ...;             ← X-Lock 유지
  SELECT ... LOCK IN SHARE MODE; ← S-Lock 추가 획득 (Growing)
COMMIT;                   ← 모든 락 해제 (Shrinking)

→ COMMIT 전까지 한 번도 락을 해제하지 않음
→ COMMIT 시점에 모든 락을 한꺼번에 해제
```

## LBCC만 사용하는 경우의 문제점

```
[읽기-쓰기 상호 차단]

트랜잭션A: S-Lock(상품1) → 읽기 중...
트랜잭션B: X-Lock(상품1) 요청 → 대기 ⏳ (A의 S-Lock 때문)

→ 읽기가 쓰기를 차단
→ 동시 사용자가 많으면 성능 급감

이것이 MVCC가 등장한 이유:
→ MVCC에서는 읽기가 이전 버전을 보므로 쓰기를 차단하지 않음
```

```
[데드락 (Deadlock)]

트랜잭션A: Lock(상품1) → Lock(상품2) 시도 → 대기 ⏳
트랜잭션B: Lock(상품2) → Lock(상품1) 시도 → 대기 ⏳

→ A는 B를 기다리고, B는 A를 기다림
→ 영원히 대기 → 데드락

[DB의 데드락 해결]
InnoDB: 데드락 감지 → 비용이 적은 트랜잭션을 강제 롤백
→ "Deadlock found when trying to get lock" 에러 발생
```

## LBCC vs MVCC 비교

|항목|LBCC|MVCC|
|---|---|---|
|**원리**|락으로 접근 차단|여러 버전 유지|
|**읽기-읽기**|S-Lock끼리 허용|항상 허용|
|**읽기-쓰기**|서로 차단 ❌|서로 차단 안 함 ✅|
|**쓰기-쓰기**|서로 차단|서로 차단|
|**동시성**|낮음|높음|
|**데드락**|발생 가능|줄어듦 (읽기 락 없으므로)|
|**구현 복잡도**|단순|복잡 (버전 관리 필요)|
|**저장 비용**|없음|Undo Log 등 추가 저장 필요|

## 현대 DB의 실제 사용 — MVCC + LBCC 혼합

```
[InnoDB의 혼합 전략]

일반 SELECT:
→ MVCC (스냅샷 읽기, 락 없음)
→ 높은 동시성

SELECT ... FOR UPDATE:
→ LBCC (배타 락 + 갭 락)
→ 쓰기 충돌 방지

UPDATE / DELETE:
→ LBCC (배타 락 + 갭 락)
→ 데이터 정합성 보장

SERIALIZABLE의 일반 SELECT:
→ LBCC (자동 공유 락)
→ 완전한 직렬 가능성
```

```
[정리]

읽기 전용       → MVCC만 사용 (락 없음, 동시성 최대)
읽기 + 쓰기 보호 → MVCC + LBCC 조합 (필요한 곳만 락)
완전한 격리     → LBCC 위주 (SERIALIZABLE)

→ 현대 DB는 "기본 MVCC + 필요 시 LBCC"가 표준 전략
```

## SQL 문별 사용되는 메커니즘

|SQL|메커니즘|락 종류|
|---|---|---|
|`SELECT`|MVCC|락 없음|
|`SELECT ... LOCK IN SHARE MODE`|LBCC|공유 락 (S-Lock)|
|`SELECT ... FOR UPDATE`|LBCC|배타 락 (X-Lock) + 갭 락|
|`UPDATE`|LBCC|배타 락 (X-Lock) + 갭 락|
|`DELETE`|LBCC|배타 락 (X-Lock) + 갭 락|
|`INSERT`|LBCC|배타 락 (X-Lock)|

## 면접 포인트

- LBCC는 **락을 통해 동시 접근을 제어하는 전통적인 방식**이며, 공유 락(S-Lock)과 배타 락(X-Lock)의 호환성 규칙에 따라 동시성을 관리합니다.
- LBCC의 가장 큰 단점은 **읽기와 쓰기가 서로 차단**된다는 점이며, 이를 해결하기 위해 MVCC가 등장했습니다. 현대 DB는 **MVCC를 기본으로 사용하고, 쓰기 충돌 등 MVCC만으로 부족한 부분에 LBCC를 보조적으로 사용**합니다.
- 2PL(Two-Phase Locking)은 LBCC에서 **트랜잭션의 직렬 가능성을 보장하기 위한 프로토콜**이며, 대부분의 DB는 Strict 2PL을 사용하여 COMMIT 시점까지 모든 배타 락을 유지합니다.