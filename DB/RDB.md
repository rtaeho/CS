데이터를 **행(Row)과 열(Column)으로 구성된 테이블** 형태로 저장하고, 테이블 간 관계를 정의해 데이터를 관리하는 데이터베이스입니다.

## 구조

```
[Users 테이블]                    [Orders 테이블]
+----+--------+-------+          +----+---------+--------+
| id | name   | email |          | id | user_id | amount |
+----+--------+-------+          +----+---------+--------+
|  1 | Alice  | a@... |          |  1 |    1    | 10,000 |
|  2 | Bob    | b@... |          |  2 |    1    | 20,000 |
+----+--------+-------+          |  3 |    2    |  5,000 |
                                  +----+---------+--------+
                                            ↑
                                       FK (외래키)
```

## 핵심 개념

|개념|설명|
|---|---|
|테이블|데이터를 저장하는 기본 단위|
|PK (기본키)|각 행을 고유하게 식별하는 키|
|FK (외래키)|다른 테이블의 PK를 참조하는 키|
|스키마|테이블 구조 정의|

## 기본 SQL

```sql
-- 테이블 생성
CREATE TABLE users (
    id    INT PRIMARY KEY AUTO_INCREMENT,
    name  VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- 삽입
INSERT INTO users (name, email) VALUES ('Alice', 'a@example.com');

-- 조회
SELECT * FROM users WHERE id = 1;

-- 조인 (테이블 간 관계 활용)
SELECT u.name, o.amount
FROM users u
JOIN orders o ON u.id = o.user_id;

-- 수정 / 삭제
UPDATE users SET name = 'Bob' WHERE id = 1;
DELETE FROM users WHERE id = 1;
```

## ACID 속성

관계형 DB가 트랜잭션에 대해 보장하는 4가지 특성입니다.

|속성|설명|
|---|---|
|**A**tomicity (원자성)|트랜잭션은 전부 성공하거나 전부 실패|
|**C**onsistency (일관성)|트랜잭션 전후로 데이터 무결성 유지|
|**I**solation (격리성)|동시 트랜잭션이 서로 간섭하지 않음|
|**D**urability (지속성)|커밋된 데이터는 영구 저장|

## RDB vs NoSQL

| 항목     | RDB               | [[NoSQL]]      |
| ------ | ----------------- | -------------- |
| 데이터 구조 | 고정 스키마 (테이블)      | 유연한 스키마        |
| 관계 표현  | JOIN으로 표현         | 중첩 구조 or 비정규화  |
| 확장 방식  | 수직 확장             | 수평 확장          |
| 일관성    | ACID 보장           | 최종 일관성         |
| 대표 제품  | MySQL, PostgreSQL | MongoDB, Redis |

> 데이터 간 관계가 복잡하고 일관성이 중요한 경우 RDB가 적합합니다. 대용량 비정형 데이터나 빠른 확장이 필요한 경우 NoSQL을 고려합니다.
