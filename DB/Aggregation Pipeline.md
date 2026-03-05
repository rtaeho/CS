MongoDB에서 데이터를 **여러 단계(Stage)를 순차적으로 거쳐 집계·변환·분석하는 처리 방식**입니다.

## 핵심 개념

```
컬렉션 → [Stage1] → [Stage2] → [Stage3] → 최종 결과
          $match    $group     $sort
         (필터링)   (집계)    (정렬)

각 Stage의 출력이 다음 Stage의 입력이 됨
```

## 주요 Stage

|Stage|SQL 대응|설명|
|---|---|---|
|`$match`|WHERE|조건으로 문서 필터링|
|`$group`|GROUP BY|특정 기준으로 그룹화|
|`$sort`|ORDER BY|정렬|
|`$project`|SELECT|필드 선택/제외/변환|
|`$limit`|LIMIT|결과 수 제한|
|`$lookup`|JOIN|다른 컬렉션 참조|
|`$unwind`|-|배열을 개별 문서로 펼침|

## 예시 - 유저별 총 주문금액 집계

```javascript
db.orders.aggregate([
  // 1단계: 완료 주문만 필터
  { $match: { status: "완료" } },

  // 2단계: 유저별 그룹화
  {
    $group: {
      _id: "$user_id",
      totalAmount: { $sum: "$amount" },
      orderCount:  { $sum: 1 }
    }
  },

  // 3단계: 총액 내림차순 정렬
  { $sort: { totalAmount: -1 } }
]);

// 결과
{ "_id": 1, "totalAmount": 30000, "orderCount": 2 }
{ "_id": 2, "totalAmount": 15000, "orderCount": 1 }
```

## SQL과 비교

```sql
-- SQL
SELECT user_id, SUM(amount) AS totalAmount, COUNT(*) AS orderCount
FROM orders
WHERE status = '완료'
GROUP BY user_id
ORDER BY totalAmount DESC;
```

```javascript
// Aggregation Pipeline - 동일한 동작
db.orders.aggregate([
  { $match: { status: "완료" } },           -- WHERE
  { $group: { _id: "$user_id",              -- GROUP BY
              totalAmount: { $sum: "$amount" },
              orderCount:  { $sum: 1 } } },
  { $sort: { totalAmount: -1 } }            -- ORDER BY
]);
```

## $lookup과의 관계

```javascript
// $lookup도 Pipeline의 Stage 중 하나
db.orders.aggregate([
  { $match: { status: "완료" } },
  {
    $lookup: {                  // JOIN
      from: "users",
      localField: "user_id",
      foreignField: "_id",
      as: "user_info"
    }
  },
  { $unwind: "$user_info" },   // 배열 → 단일 객체
  { $group: { ... } }
]);
```

## 성능 팁

```
✅ $match, $limit은 최대한 앞 단계에 배치
   → 처리할 문서 수를 먼저 줄여야 성능 향상

❌ 나쁜 예
aggregate([ $group → $match ])  // 전체 집계 후 필터링

✅ 좋은 예
aggregate([ $match → $group ])  // 필터링 후 집계
```

> Aggregation Pipeline은 MongoDB에서 **집계, JOIN($lookup), 변환을 모두 처리하는 핵심 프레임워크**입니다. $lookup은 이 Pipeline 안에 속한 하나의 Stage입니다.