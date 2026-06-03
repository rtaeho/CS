**null을 직접 다루는 대신 값이 있을 수도 없을 수도 있음을 명시적으로 표현하는 컨테이너 클래스**입니다 (Java 8+).

## 생성

```java
Optional<String> opt1 = Optional.of("hello");        // 값 있음 (null 전달 시 NPE)
Optional<String> opt2 = Optional.ofNullable(null);   // null 허용
Optional<String> opt3 = Optional.empty();             // 빈 Optional
```

## 값 꺼내기

```java
Optional<String> opt = Optional.of("hello");

// ❌ 나쁜 방법 — isPresent() + get() 조합
if (opt.isPresent()) {
    String val = opt.get();
}

// ✅ 좋은 방법들
opt.orElse("기본값")                    // 없으면 기본값 반환
opt.orElseGet(() -> computeDefault())   // 없으면 공급자 실행 (지연 평가)
opt.orElseThrow(() -> new NoSuchElementException())  // 없으면 예외
opt.ifPresent(val -> System.out.println(val))        // 있으면 실행
opt.ifPresentOrElse(
    val -> System.out.println(val),      // 있을 때
    () -> System.out.println("없음")     // 없을 때
);
```

## 변환

```java
Optional<String> opt = Optional.of("hello");

// map: 값 변환
opt.map(String::toUpperCase);             // Optional<"HELLO">
opt.map(String::length);                  // Optional<5>

// flatMap: Optional을 반환하는 함수 연결 (중첩 제거)
Optional<String> result = opt.flatMap(s -> findUserByName(s));

// filter: 조건 미충족 시 empty
opt.filter(s -> s.length() > 3);          // Optional<"hello"> (5 > 3)
opt.filter(s -> s.length() > 10);         // Optional.empty()
```

## 실제 사용 패턴

```java
// 기존 null 처리
String username = user.getAddress() != null
    ? user.getAddress().getCity()
    : "Unknown";

// Optional 체이닝
String city = Optional.ofNullable(user.getAddress())
    .map(Address::getCity)
    .orElse("Unknown");
```

## 안티패턴

```java
// ❌ 필드로 사용 — 직렬화 불가, 설계 의도에 반함
class User {
    private Optional<String> nickname;
}

// ❌ 메서드 파라미터로 사용
void process(Optional<String> name) {}  // null 넘기면 NPE 발생 가능

// ❌ isPresent() + get() 조합 — 그냥 null 체크와 다를 바 없음
if (opt.isPresent()) { opt.get(); }

// ✅ 반환 타입으로만 사용
Optional<User> findById(Long id) { ... }
```

## orElse vs orElseGet

```java
// orElse: 항상 평가 (값이 있어도 기본값 표현식 실행)
opt.orElse(expensiveOperation());    // 항상 expensiveOperation() 호출

// orElseGet: 없을 때만 평가 (지연 평가)
opt.orElseGet(() -> expensiveOperation());  // opt가 empty일 때만 호출
```

> 기본값 생성 비용이 크다면 `orElseGet` 사용.

## 핵심 정리

- NPE 방지보다 **null 가능성을 타입으로 명시**하는 것이 목적 — API 설계 의도 전달

- `orElse`는 항상 평가, `orElseGet`은 lazy 평가 — 비용 있는 기본값은 `orElseGet`

- 반환 타입으로만 사용 — 필드·파라미터로는 사용 금지

→ [[함수형 프로그래밍]]

