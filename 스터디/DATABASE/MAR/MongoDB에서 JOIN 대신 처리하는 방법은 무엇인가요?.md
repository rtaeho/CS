MongoDB는 JOIN 대신 **임베딩(Embedding)** 과 **$lookup** 두 가지 방식으로 관계를 처리합니다.

## 1. 임베딩 (Embedding) - 가장 권장

관련 데이터를 **하나의 문서 안에 중첩 저장**하는 방식입니다.

```json
// RDB였다면 user 테이블 + orders 테이블로 분리
// MongoDB는 한 문서에 모두 포함
{
  "_id": 1,
  "name": "kim",
  "email": "kim@test.com",
  "orders": [
    { "product": "상품A", "amount": 10000 },
    { "product": "상품B", "amount": 20000 }
  ]
}
```

```
장점: 단일 조회로 모든 데이터 가져옴 → 매우 빠름
단점: 데이터 중복, 문서 크기 제한 (16MB)
적합: 함께 자주 조회되는 데이터, 1:N 관계
```

## 2. $lookup - SQL JOIN과 유사

컬렉션 간 참조가 필요할 때 **[[Aggregation Pipeline]]**에서 사용합니다.

```javascript
// orders 컬렉션에서 user 정보를 JOIN
db.orders.aggregate([
  {
    $lookup: {
      from: "users",          // 참조할 컬렉션
      localField: "user_id",  // orders의 필드
      foreignField: "_id",    // users의 필드
      as: "user_info"         // 결과 필드명
    }
  },
  {
    $unwind: "$user_info"     // 배열 → 단일 객체로 펼침
  },
  {
    $project: {               // 필요한 필드만 선택
      product: 1,
      "user_info.name": 1,
      "user_info.email": 1
    }
  }
]);

// 결과
{
  "product": "상품A",
  "user_info": { "name": "kim", "email": "kim@test.com" }
}
```

## 3. DBRef - 참조 방식

다른 컬렉션의 문서를 **ID로만 참조**하고, 애플리케이션 레벨에서 조회합니다.

```javascript
// orders 컬렉션
{ "_id": 1, "user_id": ObjectId("abc123"), "product": "상품A" }

// 애플리케이션에서 직접 처리 (Java - Spring Data MongoDB)
@Document(collection = "orders")
public class Order {
    @Id
    private String id;

    @DBRef                  // 참조 관계 선언
    private User user;      // 조회 시 자동으로 users 컬렉션에서 로드

    private String product;
}
```

## 방식 비교

|방식|성능|데이터 중복|적합한 상황|
|---|---|---|---|
|**임베딩**|✅ 매우 빠름|있음|함께 조회되는 데이터, 1:N|
|**$lookup**|🔺 상대적으로 느림|없음|독립적으로 사용되는 데이터|
|**DBRef**|🔺 N+1 위험|없음|단순 참조, 소규모|

## 설계 기준

```
함께 자주 조회되는가?       → 임베딩
독립적으로 사용되는가?      → $lookup 또는 DBRef
데이터 변경이 잦은가?       → $lookup (중복 없음)
읽기 성능이 최우선인가?     → 임베딩
```

> MongoDB 설계의 핵심은 **"어떻게 조회할 것인가"를 먼저 결정하고 스키마를 설계**하는 것입니다. RDB처럼 정규화를 먼저 생각하면 $lookup 남발로 RDB보다 느려질 수 있습니다. ⚠️

---

**분류: DB**