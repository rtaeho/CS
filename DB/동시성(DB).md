동시성(Concurrency)이란 데이터베이스에서 **여러 트랜잭션이 동시에 같은 데이터에 접근할 때 발생하는 충돌을 제어하는 것**을 의미합니다.

## 왜 문제가 되는가

```
[단일 사용자 — 문제 없음]
사용자A: 잔액 조회 → 10,000원 → 출금 5,000원 → 잔액 5,000원 ✅

[동시 접근 — 문제 발생]
시간  사용자A                    사용자B
 │   잔액 조회 → 10,000원
 │                              잔액 조회 → 10,000원
 │   출금 5,000원
 │   잔액 = 10,000 - 5,000 = 5,000원 저장
 │                              출금 3,000원
 │                              잔액 = 10,000 - 3,000 = 7,000원 저장
 ▼
결과: 잔액 7,000원 (사용자A의 출금이 사라짐 ❌)
정상: 잔액 2,000원 (10,000 - 5,000 - 3,000)
```

## 동시성 문제의 종류

### 1. 갱신 분실 (Lost Update)

```
두 트랜잭션이 같은 데이터를 동시에 수정하여 하나의 수정이 사라지는 문제

트랜잭션A: READ 재고 = 10
트랜잭션B: READ 재고 = 10
트랜잭션A: UPDATE 재고 = 10 - 1 = 9
트랜잭션B: UPDATE 재고 = 10 - 1 = 9  ← A의 수정을 덮어씀

결과: 재고 9 (실제로는 8이어야 함) ❌
```

### 2. 더티 리드 (Dirty Read)

```
커밋되지 않은 데이터를 다른 트랜잭션이 읽는 문제

트랜잭션A: UPDATE 가격 = 50000 (아직 COMMIT 안 함)
트랜잭션B: READ 가격 = 50000 ← 커밋 안 된 데이터를 읽음
트랜잭션A: ROLLBACK (가격 원복 → 45000)

결과: 트랜잭션B는 존재하지 않는 가격(50000)으로 처리함 ❌
```

### 3. 반복 불가능 읽기 (Non-Repeatable Read)

```
같은 트랜잭션 내에서 같은 데이터를 두 번 읽었는데 값이 다른 문제

트랜잭션A: READ 가격 = 45000
트랜잭션B: UPDATE 가격 = 39000 + COMMIT
트랜잭션A: READ 가격 = 39000 ← 같은 트랜잭션인데 값이 다름 ❌
```

### 4. 팬텀 리드 (Phantom Read)

```
같은 조건으로 조회했는데 행의 수가 달라지는 문제

트랜잭션A: SELECT COUNT(*) FROM orders WHERE date = '2025-02-13' → 10건
트랜잭션B: INSERT INTO orders (...) + COMMIT
트랜잭션A: SELECT COUNT(*) FROM orders WHERE date = '2025-02-13' → 11건 ❌
          → 없던 행이 유령(Phantom)처럼 등장
```

## 해결 방법 1: [[트랜잭션]] [[격리 수준]] (Isolation Level)

DB가 동시성 문제를 어디까지 허용할지 설정하는 수준입니다.

| 격리 수준                | Dirty Read | Non-Repeatable Read | Phantom Read | 성능    |
| -------------------- | ---------- | ------------------- | ------------ | ----- |
| **READ UNCOMMITTED** | ⚠️ 발생      | ⚠️ 발생               | ⚠️ 발생        | 가장 빠름 |
| **READ COMMITTED**   | ✅ 방지       | ⚠️ 발생               | ⚠️ 발생        | 빠름    |
| **REPEATABLE READ**  | ✅ 방지       | ✅ 방지                | ⚠️ 발생        | 보통    |
| **SERIALIZABLE**     | ✅ 방지       | ✅ 방지                | ✅ 방지         | 가장 느림 |
|                      |            |                     |              |       |

```sql
-- MySQL 기본 격리 수준: REPEATABLE READ
-- PostgreSQL, Oracle 기본: READ COMMITTED

-- 격리 수준 확인
SELECT @@transaction_isolation;

-- 격리 수준 변경
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

```
격리 수준이 높을수록 → 동시성 문제 방지 ✅ but 성능 저하 ❌
격리 수준이 낮을수록 → 성능 좋음 ✅ but 동시성 문제 발생 가능 ❌

→ 서비스 요구사항에 따라 적절한 수준 선택
```

## 해결 방법 2: 락 (Lock)

### 비관적 락 (Pessimistic Lock)

**"충돌이 발생할 것이다"**라고 가정하고, 데이터를 읽는 시점에 락을 걸어 다른 트랜잭션의 접근을 차단합니다.

```sql
-- 비관적 락 — 다른 트랜잭션이 이 행을 수정/읽기 불가
SELECT * FROM products WHERE id = 1 FOR UPDATE;
```

```java
// JPA 비관적 락
public interface ProductRepository extends JpaRepository<Product, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT p FROM Product p WHERE p.id = :id")
    Optional<Product> findByIdForUpdate(@Param("id") Long id);
}
```

```java
@Transactional
public void decreaseStock(Long productId, int quantity) {
    // 락을 걸고 조회 → 다른 트랜잭션은 대기
    Product product = productRepository.findByIdForUpdate(productId)
            .orElseThrow(() -> new IllegalArgumentException("상품 없음"));

    product.decreaseStock(quantity);
}
```

```
트랜잭션A: SELECT ... FOR UPDATE (락 획득)
트랜잭션B: SELECT ... FOR UPDATE (대기 ⏳)
트랜잭션A: UPDATE + COMMIT (락 해제)
트랜잭션B: 이제 락 획득 → 최신 데이터로 처리 ✅
```

|장점|단점|
|---|---|
|데이터 정합성 확실히 보장|락 대기로 인한 성능 저하|
|구현이 직관적|데드락 발생 가능|
|충돌이 잦은 경우 적합|동시 처리량 감소|

### 낙관적 락 (Optimistic Lock)

**"충돌이 거의 없을 것이다"**라고 가정하고, 락을 걸지 않고 수정 시점에 버전을 비교하여 충돌을 감지합니다.

```java
// JPA 낙관적 락 — @Version 사용
@Entity
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private int stock;

    @Version  // 수정할 때마다 자동 증가
    private Long version;
}
```

```
[동작 원리]

초기 상태: id=1, stock=10, version=0

트랜잭션A: SELECT → {stock: 10, version: 0}
트랜잭션B: SELECT → {stock: 10, version: 0}

트랜잭션A: UPDATE SET stock=9, version=1 WHERE id=1 AND version=0
           → 성공 ✅ (version이 0에서 1로 변경)

트랜잭션B: UPDATE SET stock=9, version=1 WHERE id=1 AND version=0
           → 실패 ❌ (version이 이미 1이므로 WHERE 조건 불일치)
           → OptimisticLockException 발생
```

```java
// 낙관적 락 — 충돌 시 재시도 로직
@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;

    public void decreaseStock(Long productId, int quantity) {
        int maxRetry = 3;

        for (int i = 0; i < maxRetry; i++) {
            try {
                Product product = productRepository.findById(productId)
                        .orElseThrow(() -> new IllegalArgumentException("상품 없음"));

                product.decreaseStock(quantity);
                productRepository.save(product);
                return;  // 성공 시 종료

            } catch (OptimisticLockException e) {
                if (i == maxRetry - 1) {
                    throw new RuntimeException("재고 차감 실패: 충돌이 지속됨");
                }
                // 잠시 대기 후 재시도
            }
        }
    }
}
```

|장점|단점|
|---|---|
|락을 걸지 않아 성능 좋음|충돌 시 재시도 로직 필요|
|동시 처리량 높음|충돌이 잦으면 재시도 비용 증가|
|충돌이 드문 경우 적합|실패 처리 로직이 복잡해질 수 있음|

## 비관적 락 vs 낙관적 락 비교

|항목|비관적 락|낙관적 락|
|---|---|---|
|**가정**|충돌이 자주 발생|충돌이 거의 없음|
|**락 시점**|읽기 시점에 락|락 없음 (수정 시 버전 비교)|
|**충돌 처리**|대기 후 순차 처리|예외 발생 → 재시도|
|**성능**|동시성 낮음|동시성 높음|
|**적합 상황**|재고 차감, 좌석 예약|게시글 수정, 설정 변경|
|**데드락**|발생 가능|발생 안 함|

## 해결 방법 3: 분산 락 (Redis)

서버가 여러 대인 경우 DB 락만으로는 부족할 수 있어 **Redis를 활용한 분산 락**을 사용합니다.

```java
// Redis 분산 락 — Redisson 사용
@Service
@RequiredArgsConstructor
public class ProductService {

    private final RedissonClient redissonClient;
    private final ProductRepository productRepository;

    public void decreaseStock(Long productId, int quantity) {
        RLock lock = redissonClient.getLock("lock:product:" + productId);

        try {
            // 락 획득 시도 (최대 5초 대기, 3초 후 자동 해제)
            boolean acquired = lock.tryLock(5, 3, TimeUnit.SECONDS);

            if (!acquired) {
                throw new RuntimeException("락 획득 실패");
            }

            Product product = productRepository.findById(productId)
                    .orElseThrow(() -> new IllegalArgumentException("상품 없음"));

            product.decreaseStock(quantity);
            productRepository.save(product);

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("락 획득 중 인터럽트");
        } finally {
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();  // 반드시 해제
            }
        }
    }
}
```

## 상황별 선택 가이드

|상황|권장 방식|이유|
|---|---|---|
|**재고 차감**|비관적 락|충돌 빈번, 정합성 최우선|
|**좌석 예약**|비관적 락|동시 선점 방지 필수|
|**게시글 수정**|낙관적 락|충돌 드묾, 성능 우선|
|**설정 변경**|낙관적 락|동시 수정 가능성 낮음|
|**다중 서버 재고**|분산 락 (Redis)|서버 간 동기화 필요|
|**결제 처리**|비관적 락 + 멱등키|이중 결제 방지|

## 면접 포인트

- 동시성 문제는 **갱신 분실, 더티 리드, 반복 불가능 읽기, 팬텀 리드** 네 가지로 분류되며, 트랜잭션 격리 수준에 따라 어떤 문제가 방지되는지 설명할 수 있어야 합니다.
- 비관적 락과 낙관적 락의 선택 기준은 **"충돌 빈도"**이며, 충돌이 잦으면 비관적 락, 드물면 낙관적 락이 적합합니다.
- 서버가 여러 대인 Scale-Out 환경에서는 DB 락만으로 부족할 수 있어 **Redis 분산 락(Redisson)**을 함께 사용하며, 이는 재고 관리, 선착순 이벤트 등에서 필수적인 패턴입니다.