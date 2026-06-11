---
title: "NoSQL"
tags: [NoSQL, 분산시스템, 스키마]
status: published
---

데이터를 테이블이 아닌 다양한 형태로 저장하며, 고정 스키마 없이 유연하게 대용량 데이터를 처리하는 비관계형 데이터베이스입니다.

## 종류

### 1. Document DB

JSON 형태의 문서로 데이터를 저장합니다.

```json
// MongoDB 예시
{
  "_id": "1",
  "name": "Alice",
  "orders": [
    { "item": "book", "amount": 10000 },
    { "item": "pen",  "amount": 2000  }
  ]
}
```

### 2. Key-Value DB

키와 값의 쌍으로 저장합니다.

```
// Redis 예시
SET user:1 "Alice"
GET user:1  → "Alice"
```

### 3. Column Family DB

행 대신 컬럼 단위로 데이터를 저장합니다.

```
// Cassandra 예시
row_key: "user:1"
  → name: "Alice"
  → email: "a@..."
```

### 4. Graph DB

노드와 엣지로 관계를 저장합니다.

```
(Alice) --[FRIEND]--> (Bob)
(Alice) --[BOUGHT]--> (Book)
```

## 핵심 특성: CAP 이론

분산 시스템에서 세 가지를 동시에 만족할 수 없습니다.

```
        Consistency (일관성)
             △
            / \
           /   \
          /     \
Availability ─── Partition Tolerance
 (가용성)          (분할 내성)

NoSQL은 보통 AP 또는 CP를 선택
```

|조합|설명|예시|
|---|---|---|
|CP|일관성 + 분할 내성|MongoDB, Redis|
|AP|가용성 + 분할 내성|Cassandra, DynamoDB|

## BASE 속성

NoSQL이 ACID 대신 따르는 원칙입니다.

|속성|설명|
|---|---|
|**B**asically Available|가용성 우선 보장|
|**S**oft State|일정 시간 데이터 불일치 허용|
|**E**ventually Consistent|최종적으로 일관성 수렴|

## NoSQL 종류별 비교

|종류|대표 제품|주요 사용처|
|---|---|---|
|Document|MongoDB|콘텐츠, 카탈로그|
|Key-Value|Redis|캐시, 세션|
|Column|Cassandra|로그, 시계열 데이터|
|Graph|Neo4j|SNS, 추천 시스템|

## RDB vs NoSQL

|항목|RDB|NoSQL|
|---|---|---|
|스키마|고정|유연|
|확장|수직 확장|수평 확장 O|
|일관성|ACID O|최종 일관성|
|관계 표현|JOIN|비정규화 / 중첩|
|적합한 데이터|정형 데이터|비정형 대용량|

> 서비스 초기엔 RDB로 시작하고, 트래픽 증가나 비정형 데이터가 많아지면 NoSQL을 도입하는 **혼합 전략**이 일반적입니다.