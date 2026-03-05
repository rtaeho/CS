네, **외래키 컬럼은 기본적으로 NULL을 허용**합니다.

## NULL 외래키의 의미

```sql
CREATE TABLE orders (
    order_id  BIGINT PRIMARY KEY,
    user_id   BIGINT,  -- NULL 허용 (NOT NULL 미선언)
    product   VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES user(id)
);

-- 비회원 주문 → user_id = NULL 허용
INSERT INTO orders VALUES (1, NULL, '상품A');  -- ✅ 정상 삽입
INSERT INTO orders VALUES (2, 999, '상품B');   -- ❌ FK 제약 위반 (user_id=999 없음)
```

> NULL은 **"참조 대상 없음"** 을 의미하며, FK 제약 조건 검사 자체를 건너뜁니다.

## NULL 허용 vs NOT NULL

|상황|FK 선언|의미|
|---|---|---|
|`user_id BIGINT`|NULL 허용|선택적 관계 (비회원 주문 등)|
|`user_id BIGINT NOT NULL`|NULL 불가|필수 관계 (반드시 참조 존재)|

## JPA에서의 표현

```java
// NULL 허용 (선택적 관계)
@ManyToOne
@JoinColumn(name = "user_id", nullable = true)  // 기본값이 true
private User user;

// NULL 불가 (필수 관계)
@ManyToOne
@JoinColumn(name = "user_id", nullable = false)
private User user;
```

## NULL FK 설계 시 주의점

```sql
-- NULL이 많으면 JOIN 결과에서 누락됨
SELECT o.order_id, u.email
FROM orders o
INNER JOIN user u ON o.user_id = u.id;
-- user_id가 NULL인 비회원 주문은 결과에서 제외됨 ❌

-- 비회원도 포함하려면 LEFT JOIN 사용
SELECT o.order_id, u.email
FROM orders o
LEFT JOIN user u ON o.user_id = u.id;  -- ✅
```

## 결론

> 외래키에 NULL이 **들어올 수 있지만**, 설계 의도에 따라 `NOT NULL` 여부를 명확히 결정해야 합니다.
> 
> - 관계가 **필수** → `NOT NULL`
> - 관계가 **선택적** → `NULL` 허용 + `LEFT JOIN` 주의