Java 14에서 도입된 **불변 데이터 객체를 간결하게 정의하기 위한 클래스 형태**입니다.

## 기존 방식 vs record

### 기존 — [[보일러플레이트]]가 많음

```java
public final class Person {
    private final String name;
    private final int age;

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public String name() { return name; }
    public int age() { return age; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Person p)) return false;
        return age == p.age && Objects.equals(name, p.name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, age);
    }

    @Override
    public String toString() {
        return "Person[name=" + name + ", age=" + age + "]";
    }
}
```

### record — 한 줄로 동일한 결과

```java
public record Person(String name, int age) { }
```

이 한 줄이 위의 **모든 코드를 자동 생성**합니다.

## record가 자동 생성하는 것

```
record Person(String name, int age) { }
                │           │
                ▼           ▼
┌─────────────────────────────────────┐
│  ✓ private final String name;       │
│  ✓ private final int age;           │
│  ✓ 모든 필드를 받는 생성자            │
│  ✓ name(), age() 접근자 메서드       │
│  ✓ equals()   — 모든 필드 비교       │
│  ✓ hashCode() — 모든 필드 기반       │
│  ✓ toString() — "Person[name=Kim, age=25]" │
│  ✓ final class (상속 불가)           │
└─────────────────────────────────────┘
```

|자동 생성 항목|설명|
|---|---|
|**private final 필드**|모든 컴포넌트가 불변|
|**Canonical 생성자**|모든 필드를 매개변수로 받는 생성자|
|**접근자 메서드**|`getName()`이 아닌 `name()` 형태|
|**equals()**|모든 필드 값이 같으면 동등|
|**hashCode()**|모든 필드 기반 해시|
|**toString()**|`클래스명[필드=값, ...]` 형태|
|**final class**|상속 불가|

## 사용 예시

### 기본 사용

```java
record Point(int x, int y) { }

Point p1 = new Point(1, 2);
Point p2 = new Point(1, 2);

p1.x();              // 1        — 접근자
p1.y();              // 2
p1.equals(p2);       // true     — 값 기반 비교
p1.hashCode();       // p2와 동일
System.out.println(p1); // "Point[x=1, y=2]"
```

### 커스텀 생성자 (유효성 검증)

```java
record Age(int value) {
    // Compact Constructor — this.value = value 자동 수행
    Age {
        if (value < 0 || value > 150) {
            throw new IllegalArgumentException("잘못된 나이: " + value);
        }
    }
}

new Age(25);   // 정상 ✓
new Age(-1);   // IllegalArgumentException ✗
```

### 커스텀 메서드 추가

```java
record Money(int amount, String currency) {

    Money add(Money other) {
        if (!this.currency.equals(other.currency)) {
            throw new IllegalArgumentException("통화 불일치");
        }
        return new Money(this.amount + other.amount, this.currency);
    }

    String display() {
        return amount + " " + currency;
    }
}

Money a = new Money(1000, "KRW");
Money b = new Money(2000, "KRW");
Money c = a.add(b);
c.display();  // "3000 KRW"
```

### 인터페이스 구현 가능

```java
interface Printable {
    String display();
}

record Product(String name, int price) implements Printable {
    @Override
    public String display() {
        return name + ": " + price + "원";
    }
}
```

## record의 제약

|제약|이유|
|---|---|
|**상속 불가**|암묵적으로 `final class`|
|**다른 클래스 상속 불가**|암묵적으로 `extends Record`|
|**필드 변경 불가**|모든 필드가 `private final`|
|**setter 없음**|불변 설계 강제|
|**인스턴스 필드 추가 불가**|컴포넌트 외 별도 필드 선언 불가|

```java
record Person(String name, int age) {
    private String nickname;      // 컴파일 에러 ✗ — 필드 추가 불가
    void setName(String name) { } // setter 의미 없음 — final 필드
}
```

## record vs 일반 클래스 vs Lombok]]

|항목|일반 클래스|Lombok @Value|record|
|---|---|---|---|
|보일러플레이트|많음|적음|없음|
|불변 보장|개발자 책임|어노테이션 기반|언어 수준 보장|
|외부 의존성|없음|Lombok 필요|없음 (JDK 내장)|
|상속|가능|설정 가능|불가|
|필드 추가|자유|자유|불가|
|적합한 용도|범용|범용 DTO|순수 데이터 운반|

## 실무 활용 사례

### DTO (Data Transfer Object)

```java
// API 응답
record ApiResponse<T>(int status, String message, T data) { }

// 사용
return new ApiResponse<>(200, "성공", userList);
```

### 값 객체 (Value Object)

```java
record Address(String city, String street, String zipCode) { }
record DateRange(LocalDate from, LocalDate to) {
    DateRange {
        if (from.isAfter(to)) {
            throw new IllegalArgumentException("시작일이 종료일 이후");
        }
    }
}
```

### 패턴 매칭 (Java 21+)

```java
sealed interface Shape permits Circle, Rectangle { }
record Circle(double radius) implements Shape { }
record Rectangle(double width, double height) implements Shape { }

double area(Shape shape) {
    return switch (shape) {
        case Circle(var r)         -> Math.PI * r * r;
        case Rectangle(var w, var h) -> w * h;
    };
}
```

### Map 키로 활용

```java
record CacheKey(String endpoint, Map<String, String> params) { }

Map<CacheKey, String> cache = new HashMap<>();
CacheKey key = new CacheKey("/api/users", Map.of("page", "1"));
cache.put(key, responseBody);

// equals·hashCode가 값 기반이므로 같은 내용이면 같은 키
```

## 언제 record를 쓰고, 언제 안 쓰는가

|상황|선택|이유|
|---|---|---|
|순수 데이터 운반 (DTO, VO)|**record**|불변·간결|
|불변 설정 객체|**record**|변경 불가 보장|
|비즈니스 로직이 많은 엔티티|**일반 클래스**|상태 변경·상속 필요|
|JPA Entity|**일반 클래스**|JPA는 기본 생성자·setter 필요|
|상속이 필요한 경우|**일반 클래스**|record는 상속 불가|

## 핵심 정리

record는 **불변 데이터 클래스를 한 줄로 정의**할 수 있는 Java 문법으로, 생성자·접근자·equals·hashCode·toString을 자동 생성합니다. 모든 필드가 `private final`이므로 **불변이 언어 수준에서 보장**되며, DTO, 값 객체, 캐시 키 등 **데이터를 담아 전달하는 용도**에 최적입니다. 다만 필드 추가·상속·setter가 불가하므로, 상태 변경이 필요한 JPA Entity나 복잡한 도메인 객체에는 일반 클래스를 사용해야 합니다.