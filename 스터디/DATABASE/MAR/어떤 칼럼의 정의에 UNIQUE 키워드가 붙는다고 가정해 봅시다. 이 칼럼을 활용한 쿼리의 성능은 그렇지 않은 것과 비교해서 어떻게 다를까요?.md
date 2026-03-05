UNIQUE 제약이 걸린 컬럼은 **내부적으로 인덱스가 자동 생성**되기 때문에, 조회 성능이 일반 컬럼보다 빠릅니다.

## UNIQUE = 자동 인덱스 생성

```sql
CREATE TABLE user (
    id    BIGINT PRIMARY KEY,
    email VARCHAR(255) UNIQUE,  -- 내부적으로 UNIQUE INDEX 자동 생성
    name  VARCHAR(100)          -- 인덱스 없음
);

SHOW INDEX FROM user;
-- | Table | Key_name    | Column_name |
-- | user  | PRIMARY     | id          |
-- | user  | email       | email       |  ← 자동 생성됨
```

## 조회 성능 비교

```sql
-- ✅ UNIQUE 컬럼 조회 → 인덱스 사용 (B+Tree 탐색)
SELECT * FROM user WHERE email = 'kim@test.com';
-- 시간복잡도: O(log n)

-- ❌ 일반 컬럼 조회 → Full Table Scan
SELECT * FROM user WHERE name = '김철수';
-- 시간복잡도: O(n)
```

```sql
-- EXPLAIN으로 확인
EXPLAIN SELECT * FROM user WHERE email = 'kim@test.com';
-- type: const  ← 단 1건 보장이므로 가장 빠른 탐색

EXPLAIN SELECT * FROM user WHERE name = '김철수';
-- type: ALL    ← Full Scan
```

## 인덱스 탐색 type 비교

|type|설명|성능|
|---|---|---|
|**const**|UNIQUE/PK로 단 1건 조회|최상|
|**ref**|일반 인덱스로 조회|좋음|
|**range**|인덱스 범위 탐색|보통|
|**ALL**|Full Table Scan|최하|

> UNIQUE 컬럼은 값이 **반드시 1건만 존재**함이 보장되므로 `const`로 처리됩니다.

## UNIQUE 인덱스의 쓰기 성능

조회는 빠르지만, **쓰기 시 중복 검사 비용**이 추가됩니다.

```
INSERT / UPDATE 시
    ↓
UNIQUE 인덱스 중복 검사 (B+Tree 탐색)
    ↓
중복 없음 → 삽입
중복 있음 → 에러
```

|작업|UNIQUE 컬럼|일반 컬럼|
|---|---|---|
|**SELECT**|✅ 빠름 (index)|❌ 느림 (Full Scan)|
|**INSERT**|중복 검사 비용 추가|검사 없음|
|**UPDATE**|중복 검사 비용 추가|검사 없음|

## 결론

> UNIQUE 키워드는 **중복 방지 + 인덱스 자동 생성** 두 가지 효과를 동시에 가집니다. 조회가 잦은 컬럼(이메일, 사용자명 등)에 UNIQUE를 걸면 **제약 보장 + 성능 향상**을 동시에 얻을 수 있습니다.