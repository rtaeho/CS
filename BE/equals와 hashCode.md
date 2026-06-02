**객체의 동등성(equals)과 해시 기반 자료구조(hashCode)를 위한 Object 핵심 메서드**입니다.

## 기본 동작

```java
// Object의 기본 구현
equals()    → == (참조 비교, 주소가 같을 때만 true)
hashCode()  → 객체의 메모리 주소 기반 정수

String a = new String("hello");
String b = new String("hello");

a == b           // false (다른 객체)
a.equals(b)      // true  (String은 오버라이딩 — 내용 비교)
```

## 계약 (Contract)

```
equals()와 hashCode()는 반드시 함께 오버라이딩해야 하는 이유:

equals()가 true → hashCode()도 반드시 같아야 함
hashCode()가 같다고 equals()가 true일 필요는 없음 (해시 충돌 허용)
```

## HashMap에서의 동작

```
put(key, value) 흐름:
1. key.hashCode() → 버킷 인덱스 계산
2. 해당 버킷에서 key.equals()로 동일 키 확인
3. 없으면 삽입, 있으면 값 교체

hashCode를 오버라이딩하지 않으면:
→ 같은 내용의 객체도 다른 버킷 → get()으로 찾을 수 없음
```

```java
class Point {
    int x, y;
    Point(int x, int y) { this.x = x; this.y = y; }

    // equals만 오버라이딩하고 hashCode 안 하면?
    @Override
    public boolean equals(Object o) {
        Point p = (Point) o;
        return this.x == p.x && this.y == p.y;
    }
}

Map<Point, String> map = new HashMap<>();
map.put(new Point(1, 2), "A");

map.get(new Point(1, 2));  // null ❌ — hashCode 다르면 다른 버킷
```

## equals & hashCode 올바른 구현

```java
class Point {
    private final int x;
    private final int y;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Point)) return false;
        Point p = (Point) o;
        return x == p.x && y == p.y;
    }

    @Override
    public int hashCode() {
        return Objects.hash(x, y);   // 핵심 필드를 모두 포함
    }
}

// 또는 Lombok
@EqualsAndHashCode
class Point {
    int x, y;
}
```

## equals 구현 규칙

```
1. 반사성:  a.equals(a) == true
2. 대칭성:  a.equals(b) == b.equals(a)
3. 추이성:  a==b, b==c → a==c
4. 일관성:  같은 상태면 항상 같은 결과
5. null 비교: a.equals(null) == false
```

## HashSet에서도 동일

```java
Set<Point> set = new HashSet<>();
set.add(new Point(1, 2));
set.contains(new Point(1, 2));  // hashCode 없으면 false
```

## 핵심 정리

- equals()만 오버라이딩하고 hashCode()를 빠뜨리면 HashMap/HashSet에서 객체를 찾지 못함

- hashCode()는 `Objects.hash(필드들)`로 구현 — equals에 쓰인 모든 필드 포함

- equals() true → hashCode() 같음 (역은 성립하지 않아도 됨 — 해시 충돌 허용)

→ [[동등성]] | [[동일성]] | [[HashMap]]
