**연관된 상수들을 타입 안전하게 묶어서 표현하는 열거형 타입**입니다.

## 기본 사용

```java
// 기본 enum
enum Direction { NORTH, SOUTH, EAST, WEST }

Direction d = Direction.NORTH;
System.out.println(d.name());    // "NORTH"
System.out.println(d.ordinal()); // 0 (선언 순서)

// 모든 값 순회
for (Direction dir : Direction.values()) {
    System.out.println(dir);
}
```

## 필드와 메서드 추가

```java
enum Planet {
    MERCURY(3.303e+23, 2.4397e6),
    VENUS  (4.869e+24, 6.0518e6),
    EARTH  (5.976e+24, 6.37814e6);

    private final double mass;
    private final double radius;
    static final double G = 6.67300E-11;

    Planet(double mass, double radius) {
        this.mass = mass;
        this.radius = radius;
    }

    double surfaceGravity() {
        return G * mass / (radius * radius);
    }
}

Planet.EARTH.surfaceGravity();  // 9.80...
```

## 추상 메서드 — 상수별 동작 정의

```java
enum Operation {
    PLUS("+")  { public int apply(int x, int y) { return x + y; } },
    MINUS("-") { public int apply(int x, int y) { return x - y; } },
    TIMES("*") { public int apply(int x, int y) { return x * y; } };

    private final String symbol;
    Operation(String symbol) { this.symbol = symbol; }

    public abstract int apply(int x, int y);
}

Operation.PLUS.apply(3, 4);  // 7
```

## switch와 함께 사용

```java
// Java 14+ switch expression
int result = switch (day) {
    case MONDAY, TUESDAY -> "평일";
    case SATURDAY, SUNDAY -> "주말";
};
```

## EnumSet / EnumMap

```java
// EnumSet: 비트 벡터 기반 고성능 Set
EnumSet<Direction> horizontal = EnumSet.of(Direction.EAST, Direction.WEST);
EnumSet<Direction> all = EnumSet.allOf(Direction.class);

// EnumMap: enum 키 전용 고성능 Map
EnumMap<Direction, String> labels = new EnumMap<>(Direction.class);
labels.put(Direction.NORTH, "북쪽");
```

## 상수 대비 장점

```java
// X int 상수 (타입 안전성 없음)
static final int RED   = 0;
static final int GREEN = 1;
static final int BLUE  = 2;

void setColor(int color) {}
setColor(999);   // 컴파일 OK, 런타임 오류 가능

// O enum (타입 안전)
enum Color { RED, GREEN, BLUE }
void setColor(Color color) {}
// setColor(999);  // X 컴파일 에러
```

## 핵심 정리

- int 상수보다 타입 안전 — 잘못된 값이 컴파일에서 걸림

- 필드·메서드·추상 메서드 추가로 상수별 데이터와 동작을 함께 캡슐화 가능

- `EnumSet`/`EnumMap`은 일반 Set/Map보다 성능이 우수 — enum 전용 내부 최적화

→ [[static]] | [[인터페이스]]

