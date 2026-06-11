---
title: "Comparator"
tags: [Java, 정렬]
status: published
---

**두 객체를 비교해서 어느 게 먼저 오는지 결정하는 함수형 인터페이스**입니다 (`java.util.Comparator`). 정렬, TreeSet, TreeMap, PriorityQueue, [[Stream.sorted]] 등에서 순서를 정의하는 데 사용됩니다.

## 시그니처

```java
@FunctionalInterface
public interface Comparator<T> {
    int compare(T a, T b);
}
```

|반환값|의미|
|---|---|
|음수|`a`가 `b`보다 앞|
|0|순서 동일|
|양수|`a`가 `b`보다 뒤|

```
[ 직관 ]
return a - b;   // 오름차순 (a가 작으면 음수 → a가 앞)
return b - a;   // 내림차순 (b가 작으면 음수 → b가 앞)
```

## Comparable vs Comparator

|항목|`Comparable<T>`|`Comparator<T>`|
|---|---|---|
|위치|클래스 자체에 구현|외부에서 정의|
|메서드|`compareTo(T other)`|`compare(T a, T b)`|
|의미|"자연 순서"|"외부에서 부여하는 순서"|
|예|`Integer`, `String` (이미 구현됨)|커스텀 정렬 기준|

```java
// Comparable — 클래스에 자연 순서가 박혀있음
class Student implements Comparable<Student> {
    int score;
    public int compareTo(Student other) {
        return this.score - other.score;
    }
}

// Comparator — 외부에서 다른 기준 부여
Comparator<Student> byName = (a, b) -> a.name.compareTo(b.name);
```

---

## 4가지 작성 방법

### 1. 람다 (Java 8+)

```java
Comparator<Integer> asc = (a, b) -> a - b;
Comparator<Integer> desc = (a, b) -> b - a;

list.sort((a, b) -> a - b);   // 가장 흔한 형태
```

### 2. 메서드 레퍼런스

```java
Comparator<Student> byScore = Comparator.comparingInt(Student::getScore);
Comparator<Student> byName  = Comparator.comparing(Student::getName);

list.sort(Comparator.comparingInt(Student::getScore));
```

### 3. 정적 팩토리 메서드

```java
Comparator<Integer> asc  = Comparator.naturalOrder();
Comparator<Integer> desc = Comparator.reverseOrder();

list.sort(Comparator.naturalOrder());
```

### 4. 익명 클래스 (Java 8 이전 방식)

```java
list.sort(new Comparator<Integer>() {
    @Override
    public int compare(Integer a, Integer b) {
        return a - b;
    }
});

// → 람다로 동일한 의미 한 줄
list.sort((a, b) -> a - b);
```

---

## 다중 기준 정렬 — `thenComparing`

여러 기준으로 정렬할 때, 첫 번째 기준이 같으면 두 번째 기준을 사용.

### 람다 직접 작성

```java
class Student { String name; int score; }
List<Student> students = ...;

// 점수 내림차순, 같으면 이름 오름차순
students.sort((a, b) -> {
    if (a.score != b.score) {
        return Integer.compare(b.score, a.score);   // 점수 내림차순
    }
    return a.name.compareTo(b.name);                // 이름 오름차순
});
```

### thenComparing 체이닝 — 권장

```java
students.sort(
    Comparator.comparingInt(Student::getScore).reversed()
        .thenComparing(Student::getName)
);
```

```
[ 동작 ]
1. comparingInt(Student::getScore)
   → 점수 오름차순 비교 함수 생성

2. .reversed()
   → 그걸 뒤집어서 점수 내림차순으로 변환

3. .thenComparing(Student::getName)
   → 점수 같을 때 이름 오름차순으로 비교
```

### 더 복잡한 예시

```java
// 카테고리 오름차순, 가격 내림차순, 같으면 이름 오름차순
products.sort(
    Comparator.comparing(Product::getCategory)
        .thenComparing(Comparator.comparingInt(Product::getPrice).reversed())
        .thenComparing(Product::getName)
);
```

```
[ 정렬 결과 예시 ]
입력:
  ("electronics", 100, "B")
  ("books", 50, "A")
  ("electronics", 200, "C")
  ("books", 50, "B")
  ("electronics", 100, "A")

정렬 후:
  ("books",       50,  "A")    ← 카테고리 1순위
  ("books",       50,  "B")    ← 같은 카테고리, 가격 같음, 이름 오름차순
  ("electronics", 200, "C")    ← 같은 카테고리, 가격 큰 게 먼저
  ("electronics", 100, "A")    ← 가격 100, 이름 A 먼저
  ("electronics", 100, "B")
```

---

## 자주 쓰는 정적 메서드

|메서드|용도|
|---|---|
|`Comparator.naturalOrder()`|자연 순서 (Comparable 사용)|
|`Comparator.reverseOrder()`|자연 순서 역순|
|`Comparator.comparing(keyExtractor)`|키 함수로 비교 (객체)|
|`Comparator.comparingInt(...)`|키 함수로 비교 (int — 박싱 안 함)|
|`Comparator.comparingLong(...)`|long 버전|
|`Comparator.comparingDouble(...)`|double 버전|
|`.reversed()`|기존 Comparator 뒤집기|
|`.thenComparing(...)`|보조 기준 추가|
|`.nullsFirst(c)` / `.nullsLast(c)`|null 처리|

```java
// null 안전 정렬
list.sort(Comparator.nullsLast(Comparator.naturalOrder()));
// null인 원소를 뒤쪽으로 보냄
```

---

## comparingInt vs comparing — 박싱 비용

```java
// comparing: 키가 Integer로 박싱됨 (느림)
list.sort(Comparator.comparing(Student::getScore));

// comparingInt: int 그대로 비교 (빠름)
list.sort(Comparator.comparingInt(Student::getScore));

→ 키가 원시 타입이면 comparingInt/comparingLong/comparingDouble 사용
```

---

## 자주 하는 실수

### `b - a` 오버플로

```java
// X a = Integer.MIN_VALUE, b = Integer.MAX_VALUE
//    → a - b 가 음수로 오버플로 → 잘못된 결과
list.sort((a, b) -> a - b);

// O 안전
list.sort((a, b) -> Integer.compare(a, b));
list.sort(Comparator.naturalOrder());
list.sort(Integer::compare);
```

### thenComparing 타입 추론 실패

```java
// X 컴파일러가 첫 람다의 타입을 추론 못 해 에러
list.sort(
    Comparator.comparing(s -> s.score).reversed()
        .thenComparing(s -> s.name)
);

// O 메서드 레퍼런스 사용 — 타입 추론 잘 됨
list.sort(
    Comparator.comparingInt(Student::getScore).reversed()
        .thenComparing(Student::getName)
);

// O 명시적 타입 지정
list.sort(
    Comparator.<Student>comparingInt(s -> s.score).reversed()
        .thenComparing(s -> s.name)
);
```

### reversed의 위치

```java
// X 두 기준 모두 뒤집힘 (의도와 다름)
Comparator.comparing(Student::getScore)
    .thenComparing(Student::getName)
    .reversed();

// O 점수만 뒤집기
Comparator.comparingInt(Student::getScore).reversed()
    .thenComparing(Student::getName);
```

```
[ reversed의 동작 ]
.reversed()는 호출 시점까지 만들어진 Comparator 전체를 뒤집음

A.thenComparing(B).reversed()  →  (A then B) 전체를 뒤집음
A.reversed().thenComparing(B)  →  A만 뒤집고 B는 그대로
```

### 음수 반환의 함정

```java
// X boolean을 int로 잘못 변환 — 0 또는 1만 나와서 동률 다수 발생
list.sort((a, b) -> a > b ? 1 : 0);    // -1을 안 주면 정렬 깨짐

// O -1, 0, 1 셋 다 가능해야 함
list.sort((a, b) -> a > b ? 1 : (a < b ? -1 : 0));
list.sort((a, b) -> Integer.compare(a, b));   // 권장
```

---

## 사용처

### 1. 정렬

```java
list.sort(comparator);
Collections.sort(list, comparator);
Arrays.sort(arr, comparator);
stream.sorted(comparator).collect(...);
```

자세한 정렬 메서드는 [[정렬]] 허브 참고.

### 2. TreeSet / TreeMap

```java
// 자연 순서
TreeSet<Integer> set = new TreeSet<>();

// 커스텀 순서 (생성자에 Comparator)
TreeSet<Student> byScore = new TreeSet<>(
    Comparator.comparingInt(Student::getScore)
);
```

### 3. [[PriorityQueue]]

```java
// 최대 힙
PriorityQueue<Integer> maxHeap = new PriorityQueue<>(Comparator.reverseOrder());

// 객체 우선순위 큐
PriorityQueue<Task> taskQueue = new PriorityQueue<>(
    Comparator.comparingInt(Task::getPriority)
);
```

### 4. Collections.max / min

```java
Student topStudent = Collections.max(students,
    Comparator.comparingInt(Student::getScore)
);
```

---

## 자주 쓰는 패턴

### 정렬 우선순위 명확히

```java
// 가독성 좋음 — 한 줄에 한 기준
products.sort(
    Comparator
        .comparing(Product::getCategory)               // 1. 카테고리 (오름차순)
        .thenComparing(Product::getPrice, Comparator.reverseOrder())  // 2. 가격 내림차순
        .thenComparing(Product::getName)               // 3. 이름 (오름차순)
);
```

### 객체 ↔ 원시 타입 정렬 차이

```java
// int[] — Comparator 못 씀
int[] arr = {3, 1, 2};
Arrays.sort(arr);   // 오름차순만 가능

// 내림차순이 필요하면 Integer[]로 박싱
Integer[] boxed = {3, 1, 2};
Arrays.sort(boxed, Comparator.reverseOrder());

// 또는 Stream으로
Integer[] sortedDesc = Arrays.stream(arr)
    .boxed()
    .sorted(Comparator.reverseOrder())
    .toArray(Integer[]::new);
```

### 문자열 정렬 변형

```java
// 길이 기준
list.sort(Comparator.comparingInt(String::length));

// 길이 기준, 같으면 사전식
list.sort(
    Comparator.comparingInt(String::length)
        .thenComparing(Comparator.naturalOrder())
);

// 대소문자 무시
list.sort(String.CASE_INSENSITIVE_ORDER);
```

### 문자열 연결 비교 — 가장 큰 수 패턴

숫자 배열을 이어붙였을 때 가장 큰 수를 만드는 정렬 순서를 결정할 때 사용.

```java
// a=3, b=30 → "330" vs "303" → "330"이 크므로 3을 앞에
Arrays.sort(strNumbers, (a, b) -> (b + a).compareTo(a + b));
```

```
[ 핵심 아이디어 ]
a와 b 중 어느 것을 앞에 놓을지:
  "ab" > "ba"  →  a를 앞에  →  (b+a).compareTo(a+b) < 0  →  a가 먼저
  "ba" > "ab"  →  b를 앞에  →  (b+a).compareTo(a+b) > 0  →  b가 먼저

예: a="3", b="30"
  b+a = "303"
  a+b = "330"
  "303".compareTo("330") < 0  →  a("3")가 먼저  O
```

```java
// 전체 흐름
int[] numbers = {3, 30, 34, 5, 9};
String[] strs = Arrays.stream(numbers)
    .mapToObj(String::valueOf)
    .toArray(String[]::new);

Arrays.sort(strs, (a, b) -> (b + a).compareTo(a + b));   // 내림차순 연결

// 모두 0인 엣지 케이스
if (strs[0].equals("0")) return "0";

String result = String.join("", strs);   // "9534330"
```

주의: `a - b` 같은 산술 비교 불가 → 자릿수가 다른 숫자를 이어붙인 문자열 비교가 핵심.

---

## 핵심 정리

`Comparator`는 **두 객체 중 어느 게 먼저 오는지를 음수/0/양수로 반환**하는 함수형 인터페이스로, 정렬·트리 자료구조·우선순위 큐 등 순서가 필요한 모든 곳에서 사용됩니다. 람다와 메서드 레퍼런스로 간결하게 작성하고, **다중 기준은 `thenComparing`으로 체이닝**하는 게 권장됩니다. 자주 하는 실수는 `b - a` 오버플로(→ `Integer.compare` 사용)와 `reversed()`의 위치(전체를 뒤집음 vs 일부만)이며, 원시 타입 키에는 `comparingInt/Long/Double`를 써서 박싱 비용을 피합니다.
