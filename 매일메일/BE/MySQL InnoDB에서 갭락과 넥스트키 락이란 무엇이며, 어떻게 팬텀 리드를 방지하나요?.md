---
title: "MySQL InnoDB에서 갭락과 넥스트키 락이란 무엇이며, 어떻게 팬텀 리드를 방지하나요?"
tags: [매일메일, Backend]
status: published
---

[[MySQL]] [[InnoDB]]에서 [[갭 락]]과 [[넥스트키 락]]은 범위 조회 중 다른 트랜잭션이 새 레코드를 삽입해 [[팬텀 리드]]를 만드는 것을 막기 위한 잠금 메커니즘입니다.

## Phantom Read란 무엇인가요?

Phantom Read는 [[트랜잭션]]이 동일한 조건의 쿼리를 반복 실행할 때, 나중에 실행된 쿼리에서 처음에는 존재하지 않았던 새로운 행이 나타나는 현상입니다.

```sql
START TRANSACTION;

SELECT * FROM orders WHERE amount > 150;

-- 다른 트랜잭션에서 amount = 250인 행 삽입 후 커밋

SELECT * FROM orders WHERE amount > 150;
```

두 번째 조회에서 처음에는 없던 행이 나타나면 팬텀 리드입니다.

## 갭 락

갭 락은 특정 인덱스 값 사이의 공간을 잠그는 락입니다. 기존 레코드 사이의 간격을 보호해 해당 범위에 새 레코드가 삽입되는 것을 방지합니다.

예를 들어 인덱스 값 `10`과 `20` 사이의 갭이 잠기면, 다른 트랜잭션은 그 사이에 `15`를 삽입할 수 없습니다.

## 넥스트키 락

넥스트키 락은 레코드 락과 갭 락을 결합한 형태입니다. 특정 인덱스 레코드 자체와 그 주변 갭을 함께 잠가, 레코드 변경과 범위 내 삽입을 동시에 제어합니다.

```sql
SELECT * FROM orders
WHERE orders_id BETWEEN 2 AND 4
FOR UPDATE;
```

위와 같은 잠금 읽기에서는 조건에 맞는 레코드뿐 아니라 관련 인덱스 범위의 갭도 잠겨, 다른 트랜잭션의 삽입이 대기할 수 있습니다.

## 팬텀 리드 방지 메커니즘

트랜잭션 A가 특정 범위를 조회할 때 해당 범위에 갭 락 또는 넥스트키 락이 걸리면, 트랜잭션 B는 그 범위 안에 새 레코드를 삽입할 수 없습니다. 따라서 트랜잭션 A가 같은 조건으로 다시 조회해도 새로운 행이 나타나지 않아 팬텀 리드가 방지됩니다.

## 추가 학습 자료

- [MySQL - InnoDB Locking](https://dev.mysql.com/doc/refman/8.0/en/innodb-locking.html)
- [MySQL - Transaction Isolation Levels](https://dev.mysql.com/doc/refman/8.0/en/innodb-transaction-isolation-levels.html)
