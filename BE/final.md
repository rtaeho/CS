**변수·메서드·클래스에 붙어 "변경 불가"를 선언하는 키워드**입니다.

## final 변수

한 번 할당 후 **재할당 불가**.

```java
// 상수 (관례: 대문자 + 언더스코어)
static final int MAX_SIZE = 100;

// final 지역 변수
final int x = 10;
x = 20;   // ❌ 컴파일 에러

// final 참조 변수 — 참조 자체를 바꿀 수 없을 뿐, 내부 상태는 변경 가능
final List<String> list = new ArrayList<>();
list.add("hello");   // ✅ 내부 상태 변경 가능
list = new ArrayList<>();  // ❌ 참조 재할당 불가
```

## final 메서드

자식 클래스가 **오버라이딩 불가**.

```java
class Parent {
    final void template() {
        step1();
        step2();    // 핵심 흐름 변경 방지
    }

    void step1() {}
    void step2() {}
}

class Child extends Parent {
    // void template() {}  // ❌ 컴파일 에러
    void step1() {}        // ✅ 오버라이딩 가능 (final 아님)
}
```

## final 클래스

**상속 불가**. `String`, `Integer`, `Math` 등이 final 클래스.

```java
final class ImmutablePoint {
    private final int x;
    private final int y;

    ImmutablePoint(int x, int y) {
        this.x = x;
        this.y = y;
    }
}

// class Sub extends ImmutablePoint {}  // ❌ 컴파일 에러
```

> String이 final인 이유: 불변성 보장 → String Pool 공유 가능, 해시코드 캐싱 가능, 보안.

## effectively final (Java 8+)

`final` 키워드 없이도 람다·익명 클래스에서 사용하려면 **사실상 final**이어야 함.

```java
int x = 10;
// x = 20;  // 이 줄이 있으면 아래 람다에서 컴파일 에러

Runnable r = () -> System.out.println(x);  // x가 effectively final이면 OK
```

## static final vs final

| | `final` 인스턴스 변수 | `static final` 상수 |
|---|---|---|
| 메모리 | 인스턴스마다 존재 | 클래스에 1개 |
| 초기화 | 생성자에서 가능 | 선언 시 또는 static 블록 |
| 용도 | 인스턴스 불변 필드 | 전역 상수 |

## 핵심 정리

- `final` 변수: 재할당 불가 (참조 타입은 내부 변경 가능)

- `final` 메서드: 오버라이딩 차단 / `final` 클래스: 상속 차단

- String이 `final class`인 이유 — 불변성을 보장해 String Pool·보안·해시 캐싱에 활용

→ [[불변 객체]] | [[static]]
