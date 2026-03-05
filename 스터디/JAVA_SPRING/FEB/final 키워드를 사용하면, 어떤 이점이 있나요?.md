변수·메서드·클래스에 **변경 불가(불변) 제약을 걸어** 안전성, 가독성, 성능 최적화를 얻을 수 있는 Java 키워드입니다.

## 적용 대상별 동작

### 1. final 변수 — 값 재할당 금지

```java
// 기본 타입
final int MAX = 100;
MAX = 200;              // 컴파일 에러 ✗

// 참조 타입
final List<String> list = new ArrayList<>();
list.add("hello");      // 내부 조작은 가능 ✓
list = new ArrayList<>(); // 참조 변경은 불가 ✗
```

```
final은 "참조"를 고정하는 것이지 "객체 내부"를 고정하는 것이 아님

final List<String> list ──→ [ "hello" ]
                              ↑ 내부 변경 가능
      list = new ...  ✗       참조 자체 변경 불가
```

|종류|예시|의미|
|---|---|---|
|**지역 변수**|`final int x = 1;`|한 번 할당 후 변경 불가|
|**매개변수**|`void foo(final int x)`|메서드 내에서 재할당 불가|
|**인스턴스 변수**|`final String name;`|생성자에서 반드시 초기화, 이후 불변|
|**static 변수**|`static final int MAX = 100;`|상수 (관례상 대문자)|

### 2. final 메서드 — 오버라이딩 금지

```java
class Parent {
    final void validate() {
        // 핵심 검증 로직 — 자식이 변경하면 안 됨
    }

    void process() {
        // 자식이 재정의 가능
    }
}

class Child extends Parent {
    void validate() { }    // 컴파일 에러 ✗ — final 메서드 오버라이딩 불가
    void process() { }     // 정상 ✓
}
```

### 3. final 클래스 — 상속 금지

```java
final class String {
    // Java의 String은 final 클래스
}

class MyString extends String { }  // 컴파일 에러 ✗ — 상속 불가
```

```
대표적인 final 클래스들:
java.lang.String
java.lang.Integer, Long, Double 등 래퍼 클래스
java.lang.Math
java.lang.System
```

## 적용 대상 요약

|대상|제약|목적|
|---|---|---|
|**변수**|재할당 금지|의도치 않은 값 변경 방지|
|**메서드**|오버라이딩 금지|핵심 로직 보호|
|**클래스**|상속 금지|설계 의도 보존, 불변 객체 보장|

## 이점

### 1. 안전성 — 의도치 않은 변경 방지

```java
// final 없이
void transfer(int amount) {
    amount = amount - fee;     // 실수로 매개변수를 변경
    account.withdraw(amount);  // 잘못된 금액 출금
}

// final 사용
void transfer(final int amount) {
    amount = amount - fee;     // 컴파일 에러 ✗ — 실수 사전 차단
    int netAmount = amount - fee;
    account.withdraw(netAmount);
}
```

### 2. 가독성 — 의도 명시

```java
// final 없이 — 이 값이 나중에 바뀌나?
String status = "ACTIVE";
// ... 100줄의 코드 ...
// status가 여전히 "ACTIVE"인지 확신할 수 없음

// final 사용 — 절대 안 바뀜을 즉시 파악
final String status = "ACTIVE";
// ... 100줄의 코드 ...
// status는 확실히 "ACTIVE"
```

### 3. 스레드 안전성

```java
// final 필드는 생성자 완료 시점에 다른 스레드에게 안전하게 공개됨

class ImmutableConfig {
    private final String host;
    private final int port;

    public ImmutableConfig(String host, int port) {
        this.host = host;
        this.port = port;
    }
    // 생성 완료 후 어떤 스레드에서 읽어도 안전
}
```

```
[ final 없이 ]
스레드 A: 객체 생성 중 (host 할당 완료, port 아직 미할당)
스레드 B: 객체 읽기 시도 → port = 0 (불완전한 상태 관측)

[ final 사용 ]
JMM(Java Memory Model) 보장:
생성자 완료 전까지 final 필드 값이 다른 스레드에 노출되지 않음
스레드 B: 반드시 완전히 초기화된 객체를 봄
```

### 4. 컴파일러·JVM 최적화

```java
// compile-time constant
static final int MAX = 100;

// 컴파일러가 MAX를 사용하는 곳에 직접 100을 삽입 (인라이닝)
if (count > MAX) { ... }
// ↓ 컴파일 후
if (count > 100) { ... }    // 변수 참조 비용 제거
```

```
[ final 메서드 ]
final void validate() { ... }

JVM이 이 메서드는 오버라이딩되지 않음을 확신
→ 가상 메서드 테이블(vtable) 조회 생략
→ 메서드 인라이닝 적극 적용
→ 호출 비용 감소
```

|최적화|설명|
|---|---|
|**상수 인라이닝**|`static final` 값을 사용처에 직접 삽입|
|**메서드 인라이닝**|final 메서드를 호출부에 본문 삽입|
|**vtable 조회 생략**|오버라이딩 불가 → 가상 호출 불필요|
|**Escape Analysis 지원**|불변 객체는 스택 할당 가능성 증가|

### 5. 불변 객체 설계의 기반

```java
// final을 활용한 불변 객체 패턴
public final class Money {                    // 상속 금지
    private final int amount;                  // 값 변경 금지
    private final String currency;             // 값 변경 금지

    public Money(int amount, String currency) {
        this.amount = amount;
        this.currency = currency;
    }

    public Money add(Money other) {
        return new Money(                      // 변경 대신 새 객체 반환
            this.amount + other.amount,
            this.currency
        );
    }

    // setter 없음
}
```

```
불변 객체가 중요한 이유:
✓ 스레드 안전 (동기화 불필요)
✓ 캐싱 가능 (값이 안 바뀌므로)
✓ Map의 key로 안전하게 사용
✓ 사이드 이펙트 없음
```

## 주의할 점

### final ≠ 완전한 불변

```java
final List<String> list = new ArrayList<>();
list.add("A");       // 가능 ✓ — 내부 상태 변경
list.add("B");       // 가능 ✓
list.clear();        // 가능 ✓

// 진짜 불변 리스트를 원하면
final List<String> list = List.of("A", "B");   // Unmodifiable
list.add("C");       // UnsupportedOperationException ✗
```

```
final 변수         → 참조가 불변
Unmodifiable 컬렉션 → 내용이 불변
둘 다 적용해야      → 완전한 불변
```

### Java [[record]] (Java 16+)

```java
// record가 final 불변 객체를 간편하게 만들어줌
record Money(int amount, String currency) { }

// 위 코드는 아래와 동일
final class Money {
    private final int amount;
    private final String currency;
    // 생성자, getter, equals, hashCode, toString 자동 생성
}
```

## 핵심 정리

final은 **변수(재할당 금지), 메서드(오버라이딩 금지), 클래스(상속 금지)**에 불변 제약을 걸어 **안전성, 가독성, 스레드 안전성, JVM 최적화**를 얻는 키워드입니다. 특히 멀티스레드 환경에서는 final 필드의 **JMM 가시성 보장**이 중요하며, 불변 객체 설계의 핵심 도구입니다. 다만 참조 타입에서는 참조만 고정할 뿐 객체 내부는 변경 가능하므로, 완전한 불변을 위해서는 Unmodifiable 컬렉션이나 record를 함께 사용해야 합니다.