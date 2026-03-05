RDB의 **ACID 보장을 위한 구조적 특성** 때문에 특정 상황에서 NoSQL보다 부하가 많이 걸릴 수 있습니다.

## 부하 원인

### 1. 락(Lock) 메커니즘

```
트랜잭션 격리성(Isolation) 보장을 위해 락 사용

Thread A: UPDATE user SET balance = 900 WHERE id = 1;
                ↓
          [id=1 행에 락 획득]
                ↓
Thread B: SELECT * FROM user WHERE id = 1;
          → 락 해제까지 대기 ⏳

→ 동시 요청이 많을수록 락 경합(Lock Contention) 심화
```

### 2. 엄격한 스키마 변경

```sql
-- 대용량 테이블에 컬럼 추가 시
ALTER TABLE user ADD COLUMN age INT;

-- 내부적으로 테이블 전체를 재구성
-- 수천만 건이면 수십 분씩 걸릴 수 있음
-- 그 동안 해당 테이블 락 발생 ❌
```

### 3. JOIN 비용

```sql
SELECT u.name, o.product, p.amount
FROM user u
JOIN orders o ON u.id = o.user_id
JOIN payment p ON o.id = p.order_id
WHERE u.id = 1;

-- 테이블마다 인덱스 탐색 + 결과 조합 비용 발생
-- 데이터가 많아질수록 비용 급증
```

### 4. 수직 확장의 한계

```
트래픽 급증 시

RDB  → 서버 스펙 업그레이드 (Scale-Up)
        but, 한 서버에 쓰기가 집중 → 병목 ❌

NoSQL → 서버 추가 (Scale-Out)
        쓰기를 여러 서버에 분산 ✅
```

### 5. MVCC(다중 버전 동시성 제어) 오버헤드

```
RDB는 트랜잭션 격리를 위해 데이터의 여러 버전을 관리

UPDATE 발생 시
→ 기존 데이터를 Undo Log에 보존
→ 새 버전 저장
→ 트랜잭션 종료 후 불필요 버전 정리 (Vacuum/Purge)

→ 쓰기가 많을수록 Undo Log 증가 → 정리 비용 발생
```

## 그럼에도 NoSQL이 무조건 빠르지 않은 이유

|상황|RDB가 더 유리한 경우|
|---|---|
|**단순 PK 조회**|클러스터드 인덱스로 1회 탐색, 매우 빠름|
|**복잡한 집계**|최적화된 쿼리 플랜 & 인덱스 활용|
|**데이터 정합성**|NoSQL은 중복 데이터 동기화 비용 발생|
|**소규모 데이터**|NoSQL 분산 오버헤드가 오히려 부담|

```
MongoDB 예시 - JOIN 대신 중복 저장
→ 이메일 변경 시 수만 개 문서 전부 업데이트 필요
→ 이 경우 RDB의 정규화가 오히려 효율적
```

## 결론

> RDB의 부하 원인은 **ACID 보장을 위한 락, 트랜잭션, 스키마 엄격성** 입니다. 하지만 이는 **"정합성을 보장하는 비용"** 이며, NoSQL은 그 비용을 **일관성을 포기함으로써** 줄인 것입니다. 즉, 트레이드오프이지 NoSQL이 무조건 빠른 것이 아닙니다.