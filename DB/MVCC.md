MVCC(Multi-Version Concurrency Control)는 데이터를 수정할 때 **이전 버전을 유지하여, 읽기 작업과 쓰기 작업이 서로 차단하지 않고 동시에 수행**될 수 있게 하는 동시성 제어 기법입니다.

## 왜 필요한가

```
[MVCC가 없는 경우 — 락 기반]
트랜잭션A: UPDATE 상품 가격 (쓰기 락 획득)
트랜잭션B: SELECT 상품 가격 → 대기 ⏳ (A가 끝날 때까지)

→ 읽기도 쓰기 락에 의해 차단됨
→ 동시 사용자가 많으면 성능 급감

[MVCC가 있는 경우]
트랜잭션A: UPDATE 상품 가격 (새 버전 생성)
트랜잭션B: SELECT 상품 가격 → 이전 버전을 읽음 → 대기 없음 ✅

→ 읽기와 쓰기가 서로 차단하지 않음
→ 동시 처리량 대폭 향상
```

## 핵심 원리

```
"데이터를 수정해도 이전 버전을 삭제하지 않고 보관한다"

[시간순 흐름]
시점 1: 가격 = 45,000 (version 1)
시점 2: UPDATE → 가격 = 39,000 (version 2 생성, version 1 보관)
시점 3: UPDATE → 가격 = 42,000 (version 3 생성, version 1,2 보관)

┌─────────────────────────────────────────────┐
│ 버전 저장소 (Undo Log / 버전 체인)            │
│                                             │
│ version 3: 가격 = 42,000 (최신)              │
│ version 2: 가격 = 39,000                     │
│ version 1: 가격 = 45,000                     │
└─────────────────────────────────────────────┘

→ 각 트랜잭션은 자신의 시작 시점에 맞는 버전을 읽음
```

## MySQL(InnoDB)의 MVCC 동작

### Undo Log 기반

```
[데이터 수정 시]

1. 현재 데이터를 Undo Log에 복사 (이전 버전 보관)
2. 실제 데이터를 새 값으로 수정
3. 수정된 행에 트랜잭션 ID와 Undo Log 포인터 기록

┌──────────── 실제 테이블 ────────────┐
│ id │ price  │ trx_id │ undo_ptr    │
│ 1  │ 42,000 │ 103    │ ──────────→ │──┐
└────────────────────────────────────┘  │
                                        ▼
┌──────────── Undo Log ──────────────┐
│ price = 39,000 │ trx_id: 102 │ ──→ │──┐
└─────────────────────────────────────┘  │
                                         ▼
┌──────────── Undo Log ──────────────┐
│ price = 45,000 │ trx_id: 101 │ NULL │
└─────────────────────────────────────┘

→ 포인터를 따라가면 이전 버전들을 탐색할 수 있음
```

### 읽기 시 버전 선택 — 스냅샷

```
[REPEATABLE READ에서의 동작]

트랜잭션A (trx_id: 104, 시작 시점: T1)
트랜잭션B (trx_id: 105)

T1: 트랜잭션A 시작
T2: 트랜잭션A: SELECT price → 스냅샷 생성
    → "104보다 먼저 커밋된 버전만 보겠다"
    → version(trx_id: 101, price: 45,000) 확인 → 커밋됨 → 이 값을 읽음 ✅

T3: 트랜잭션B: UPDATE price = 39,000 + COMMIT (trx_id: 105)

T4: 트랜잭션A: SELECT price
    → 여전히 "104보다 먼저 커밋된 버전만 본다"
    → trx_id: 105는 104 이후 → 무시
    → trx_id: 101의 45,000을 읽음 ✅

→ 트랜잭션A는 시작 시점의 일관된 데이터를 계속 봄
→ 반복 읽기 보장 (Non-Repeatable Read 방지)
```

## 격리 수준별 MVCC 동작 차이

### READ COMMITTED

```
각 SELECT마다 새로운 스냅샷 생성

트랜잭션A 시작 (trx_id: 104)

T1: SELECT price → 스냅샷 생성 → 45,000 읽음
T2: 트랜잭션B: UPDATE price = 39,000 + COMMIT
T3: SELECT price → 새 스냅샷 생성 → 39,000 읽음 (B의 커밋 반영)

→ 같은 트랜잭션 내에서 다른 값을 읽을 수 있음
→ Non-Repeatable Read 발생 가능 ⚠️
```

### REPEATABLE READ (MySQL 기본)

```
트랜잭션 시작 시 한 번만 스냅샷 생성, 끝까지 유지

트랜잭션A 시작 (trx_id: 104)

T1: SELECT price → 스냅샷 생성 → 45,000 읽음
T2: 트랜잭션B: UPDATE price = 39,000 + COMMIT
T3: SELECT price → 기존 스냅샷 유지 → 45,000 읽음 (B의 커밋 무시)

→ 같은 트랜잭션 내에서 항상 같은 값을 읽음
→ Non-Repeatable Read 방지 ✅
```

|격리 수준|스냅샷 생성 시점|같은 트랜잭션 내 일관성|
|---|---|---|
|**READ COMMITTED**|매 SELECT마다|보장하지 않음|
|**REPEATABLE READ**|트랜잭션 첫 SELECT 시|보장 ✅|

## MVCC가 해결하는 것과 해결하지 못하는 것

```
[MVCC가 해결하는 것]
✅ 읽기-쓰기 동시 수행 (서로 차단하지 않음)
✅ 더티 리드 방지 (커밋된 버전만 읽음)
✅ 반복 읽기 보장 (REPEATABLE READ에서)
✅ 일관된 읽기 (Consistent Read)

[MVCC가 해결하지 못하는 것]
❌ 쓰기-쓰기 충돌 → 여전히 락 필요
❌ 갱신 분실 (Lost Update) → 비관적/낙관적 락으로 해결
```

```
[쓰기-쓰기 충돌 — MVCC만으로 부족]

트랜잭션A: READ 재고 = 10 (MVCC 스냅샷)
트랜잭션B: READ 재고 = 10 (MVCC 스냅샷)
트랜잭션A: UPDATE 재고 = 9 + COMMIT
트랜잭션B: UPDATE 재고 = 9 + COMMIT ← 갱신 분실 ❌

→ 이 경우는 SELECT ... FOR UPDATE (비관적 락) 등이 필요
```

## MVCC + 락의 조합

```java
// 읽기 전용 — MVCC만으로 충분 (락 불필요)
@Transactional(readOnly = true)
public ProductResponse findById(Long id) {
    // MVCC 스냅샷으로 일관된 읽기
    Product product = productRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("상품 없음"));
    return new ProductResponse(product);
}

// 쓰기 — MVCC + 비관적 락 조합
@Transactional
public void decreaseStock(Long productId, int quantity) {
    // FOR UPDATE로 쓰기 락 획득 → 다른 트랜잭션 대기
    Product product = productRepository.findByIdForUpdate(productId)
            .orElseThrow(() -> new IllegalArgumentException("상품 없음"));

    product.decreaseStock(quantity);
}
```

```
[동시 접근 시]

읽기 + 읽기: MVCC로 둘 다 대기 없이 처리 ✅
읽기 + 쓰기: MVCC로 읽기는 이전 버전 조회, 쓰기는 최신 데이터 수정 ✅
쓰기 + 쓰기: 락으로 순차 처리 (하나가 대기) ✅
```

## MVCC의 비용 — Undo Log 관리

```
[Undo Log 누적 문제]

트랜잭션이 오래 유지되면:
→ 해당 트랜잭션의 스냅샷에서 참조하는 이전 버전을 삭제할 수 없음
→ Undo Log가 계속 쌓임 → 디스크/메모리 사용량 증가

[Purge Thread]
MySQL InnoDB는 백그라운드에서 Purge Thread가
더 이상 참조되지 않는 Undo Log를 정리함

→ 긴 트랜잭션을 피하는 것이 MVCC 환경에서 중요
```

```java
// ❌ 긴 트랜잭션 — Undo Log 누적 유발
@Transactional
public void longProcess() {
    Product product = productRepository.findById(1L).orElseThrow();

    externalApiCall();       // 외부 API 호출 (수 초 소요)
    sendEmail();             // 이메일 발송 (수 초 소요)
    generateReport();        // 리포트 생성 (수 초 소요)

    product.update(...);     // 이 시점까지 트랜잭션이 열려 있음
}

// ✅ 트랜잭션 범위 최소화
public void optimizedProcess() {
    updateProduct();          // 짧은 트랜잭션
    externalApiCall();        // 트랜잭션 밖에서 처리
    sendEmail();
    generateReport();
}

@Transactional
public void updateProduct() {
    Product product = productRepository.findById(1L).orElseThrow();
    product.update(...);
    // 빠르게 커밋 → Undo Log 정리 가능
}
```

## DB별 MVCC 구현 차이

|항목|MySQL (InnoDB)|PostgreSQL|
|---|---|---|
|**이전 버전 저장**|Undo Log (별도 공간)|테이블 내에 직접 저장|
|**버전 정리**|Purge Thread|VACUUM 프로세스|
|**기본 격리 수준**|REPEATABLE READ|READ COMMITTED|
|**스냅샷 방식**|트랜잭션 ID 기반|XID(트랜잭션 ID) 기반|

```
[MySQL InnoDB]
테이블: 최신 버전만 저장
Undo Log: 이전 버전 보관 → Purge Thread가 정리

[PostgreSQL]
테이블: 모든 버전을 테이블 안에 저장 (튜플 버전 관리)
→ 테이블이 비대해질 수 있음 → VACUUM으로 정리 필수
```

## 면접 포인트

- MVCC의 핵심 가치는 **"읽기와 쓰기가 서로 차단하지 않는다"**는 것이며, 이를 통해 동시 처리량이 대폭 향상됩니다.
- MySQL InnoDB는 **Undo Log에 이전 버전을 보관**하고, 각 트랜잭션은 자신의 스냅샷에 맞는 버전을 읽는 방식으로 MVCC를 구현합니다.
- MVCC는 **읽기-쓰기 동시성은 해결하지만, 쓰기-쓰기 충돌은 해결하지 못하므로** 재고 차감 같은 경우에는 여전히 비관적 락이나 낙관적 락이 필요합니다.
- 긴 트랜잭션은 Undo Log 누적을 유발하므로, **트랜잭션 범위를 최소화하는 것**이 MVCC 환경에서의 성능 최적화 핵심입니다.