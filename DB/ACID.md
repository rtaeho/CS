## Atomicity (원자성)

**전부 성공하거나 전부 실패**합니다. 중간 상태가 없습니다.

```sql
START TRANSACTION;
UPDATE accounts SET balance = balance - 100000 WHERE user = 'A';  -- 성공
UPDATE accounts SET balance = balance + 100000 WHERE user = 'B';  -- 실패!
ROLLBACK;  -- 첫 번째 UPDATE도 취소됨
```

원자(Atom) = 더 이상 쪼갤 수 없는 단위

트랜잭션 안의 작업들은 하나처럼 취급

---

## Consistency (일관성)

**트랜잭션 전후로 데이터 무결성이 유지**됩니다.

```sql
-- 규칙: 잔액은 0 이상이어야 함
-- A 잔액: 50,000원

START TRANSACTION;
UPDATE accounts SET balance = balance - 100000 WHERE user = 'A';
-- 잔액이 -50,000이 되어버림 → 규칙 위반 → 실패
ROLLBACK;
```

```
일관성 규칙 예시:
- 잔액 >= 0
- 외래 키 참조 무결성
- UNIQUE 제약
```

트랜잭션이 끝나면 **모든 규칙이 만족된 상태**여야 합니다.

---

## Isolation (격리성)

**동시에 실행되는 트랜잭션이 서로 영향을 주지 않음**처럼 보입니다.

```
트랜잭션 A: A 잔액 읽기 → 계산 → 업데이트
트랜잭션 B: A 잔액 읽기 → 계산 → 업데이트

동시에 실행되면?
```

### 격리 안 되면 (문제 발생)

```
A 잔액: 100,000원

트랜잭션 A: 읽기 (100,000)
트랜잭션 B: 읽기 (100,000)
트랜잭션 A: 50,000 출금 → 50,000 저장
트랜잭션 B: 30,000 출금 → 70,000 저장

결과: 70,000원 (50,000 + 30,000 = 80,000 빠져야 하는데!)
```

### 격리 되면

```
트랜잭션 A: 읽기 → 계산 → 저장 (50,000)
트랜잭션 B: 읽기 (50,000) → 계산 → 저장 (20,000)

결과: 20,000원 (정상)
```

격리 레벨에 따라 **얼마나 격리할지** 조절합니다.

---

## Durability (지속성)

**커밋된 데이터는 영구 저장**됩니다. 시스템이 꺼져도 살아있습니다.

```sql
START TRANSACTION;
UPDATE accounts SET balance = 50000 WHERE user = 'A';
COMMIT;  -- 이 순간 디스크에 기록

-- 직후 서버 다운!
-- 재부팅 후에도 A 잔액은 50,000원
```

### 구현 방식

```
1. Write-Ahead Logging (WAL)
   - 데이터 변경 전에 로그 먼저 기록
   - 장애 시 로그로 복구

2. 체크포인트
   - 주기적으로 메모리 → 디스크 동기화
```

---

## 정리

|특성|의미|보장 내용|
|---|---|---|
|Atomicity|원자성|전부 성공 or 전부 실패|
|Consistency|일관성|규칙 위반 없음|
|Isolation|격리성|트랜잭션끼리 간섭 없음|
|Durability|지속성|커밋되면 영구 저장|

---

## 비유

```
ATM에서 출금:

Atomicity: 돈 나오고 잔액 차감이 동시에 (하나만 X)
Consistency: 잔액이 마이너스가 되지 않음
Isolation: 옆 사람 출금이 내 잔액에 영향 X
Durability: 출금 완료 후 정전되어도 기록 유지
```