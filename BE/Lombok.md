Java에서 **[[어노테이션]]만으로 보일러플레이트 코드를 컴파일 시점에 자동 생성해주는 라이브러리**입니다.

## 동작 원리

```
[ Lombok 없이 ]
개발자가 직접 작성 → getter, setter, 생성자, equals, hashCode, toString ...

[ Lombok 사용 ]
개발자: 어노테이션만 붙임
            │
            ▼
Person.java (@Data 붙은 소스코드)
            │  javac 컴파일
            ▼
Lombok Annotation Processor 개입
            │  AST(추상 구문 트리)를 조작하여 코드 삽입
            ▼
Person.class (getter, setter, equals 등이 포함된 바이트코드)
```

```
핵심:
소스코드에는 없지만, 컴파일된 .class 파일에는 존재
→ 런타임 리플렉션이 아닌 컴파일 타임 코드 생성
→ 런타임 성능 비용 제로
```

## 주요 어노테이션

### 개별 어노테이션

```java
public class Person {

    @Getter                     // getName(), getAge() 생성
    @Setter                     // setName(), setAge() 생성
    private String name;
    private int age;

    @ToString                   // toString() 생성
    @EqualsAndHashCode          // equals(), hashCode() 생성
    @NoArgsConstructor          // 기본 생성자
    @AllArgsConstructor         // 모든 필드 생성자
    @RequiredArgsConstructor    // final 필드만 받는 생성자
}
```

|어노테이션|생성하는 코드|
|---|---|
|`@Getter`|모든 필드의 getter|
|`@Setter`|모든 필드의 setter|
|`@ToString`|toString()|
|`@EqualsAndHashCode`|equals(), hashCode()|
|`@NoArgsConstructor`|기본 생성자|
|`@AllArgsConstructor`|모든 필드를 받는 생성자|
|`@RequiredArgsConstructor`|final·@NonNull 필드만 받는 생성자|
|`@Data`|Getter + Setter + ToString + EqualsAndHashCode + RequiredArgs|
|`@Value`|불변 버전 @Data (모든 필드 private final)|
|`@Builder`|빌더 패턴|
|`@Slf4j`|Logger 자동 생성|

### 묶음 어노테이션

#### @Data — 가변 객체용

```java
@Data
@AllArgsConstructor
public class Person {
    private String name;
    private int age;
}

// 위 코드가 자동 생성하는 것:
// ✓ getter (getName, getAge)
// ✓ setter (setName, setAge)
// ✓ toString()
// ✓ equals()
// ✓ hashCode()
// ✓ @RequiredArgsConstructor
```

#### @Value — 불변 객체용

```java
@Value
public class Money {
    int amount;        // 자동으로 private final
    String currency;   // 자동으로 private final
}

// 자동 생성:
// ✓ private final 필드
// ✓ getter (setter 없음)
// ✓ 모든 필드 생성자
// ✓ toString(), equals(), hashCode()
// ✓ final class
```

### 자주 쓰이는 조합

#### @Builder — 빌더 패턴

```java
@Builder
@AllArgsConstructor
public class Order {
    private String product;
    private int quantity;
    private int price;
}

// 사용
Order order = Order.builder()
    .product("커피")
    .quantity(2)
    .price(4500)
    .build();
```

Lombok 없이 빌더를 직접 구현하면 다음과 같습니다.

```java
// Lombok 없이 빌더 직접 구현 — 약 30줄
public class Order {
    private String product;
    private int quantity;
    private int price;

    private Order(Builder builder) {
        this.product = builder.product;
        this.quantity = builder.quantity;
        this.price = builder.price;
    }

    public static class Builder {
        private String product;
        private int quantity;
        private int price;

        public Builder product(String product) {
            this.product = product;
            return this;
        }
        public Builder quantity(int quantity) {
            this.quantity = quantity;
            return this;
        }
        public Builder price(int price) {
            this.price = price;
            return this;
        }
        public Order build() {
            return new Order(this);
        }
    }

    public static Builder builder() {
        return new Builder();
    }
}
```

#### @Slf4j — 로거

```java
@Slf4j
@Service
public class UserService {

    public void createUser(String name) {
        log.info("사용자 생성: {}", name);     // log 변수를 자동 생성
        log.error("에러 발생!");
    }
}

// Lombok 없이
private static final Logger log = LoggerFactory.getLogger(UserService.class);
```

## 실무에서 자주 쓰는 조합

### DTO

```java
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    private String name;
    private String email;
    private int age;
}
```

### Entity

```java
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class User {
    @Id @GeneratedValue
    private Long id;
    private String name;
    private String email;
}
```

### 불변 설정 객체

```java
@Value
public class DatabaseConfig {
    String host;
    int port;
    String database;
}
```

## Lombok 주의사항

### 1. @Data를 Entity에 쓰면 위험

```java
// 위험한 사용
@Data
@Entity
public class User {
    @Id
    private Long id;
    private String name;

    @OneToMany
    private List<Order> orders;   // 양방향 관계
}

// @Data가 생성하는 toString(), equals()가
// orders를 포함하여 순환 참조 → StackOverflowError
```

```
User.toString()
  → orders.toString()
    → 각 Order.toString()
      → order.user.toString()
        → orders.toString()    ← 무한 순환
```

### 2. @EqualsAndHashCode 주의

```java
// JPA Entity에서 주의
@EqualsAndHashCode
@Entity
public class User {
    @Id @GeneratedValue
    private Long id;     // DB 저장 전 null, 저장 후 값 생김
}

// 저장 전후로 hashCode가 달라짐
// → HashSet, HashMap에서 찾지 못하는 버그
```

### 3. 권장 사용법

|상황|권장|비권장|
|---|---|---|
|**Entity**|`@Getter` + `@NoArgsConstructor(PROTECTED)`|`@Data`, `@Setter`|
|**DTO**|`@Getter` + `@AllArgsConstructor`|`@Data` (무분별 사용)|
|**불변 객체**|`@Value` 또는 record|`@Data`|
|**빌더**|`@Builder`|직접 구현|

## Lombok vs record vs 직접 작성

|항목|직접 작성|Lombok|record|
|---|---|---|---|
|코드량|많음|적음|최소|
|외부 의존성|없음|Lombok 필요|없음|
|가변/불변|선택 가능|선택 가능|불변만|
|상속|가능|가능|불가|
|JPA Entity|적합|주의 필요|부적합|
|커스터마이징|완전 자유|어노테이션 범위|제한적|

## 핵심 정리

Lombok은 **어노테이션 기반으로 컴파일 시점에 보일러플레이트를 자동 생성**하는 라이브러리입니다. `@Getter`, `@Builder`, `@Slf4j` 등으로 코드량을 대폭 줄여주지만, JPA Entity에서 `@Data`를 사용하면 **순환 참조나 hashCode 불일치** 문제가 발생할 수 있으므로 상황에 맞는 어노테이션을 선택해야 합니다. Java 16+에서 단순 불변 데이터는 record로 대체하는 추세이며, Lombok은 가변 객체·빌더·로거 등 record가 커버하지 못하는 영역에서 여전히 유용합니다.