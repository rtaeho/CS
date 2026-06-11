---
title: "Stream.mapToInt"
tags: [Stream, 자료구조, Java]
status: published
---

[[Stream]]의 각 원소를 **`int`로 변환**해 `IntStream`을 반환합니다. `Stream<Integer>` → `IntStream`으로 **언박싱**하는 핵심 메서드이며, 이후 `sum()`, `average()`, `toArray()` 같은 원시 타입 전용 연산을 쓸 수 있게 해줍니다.

## 시그니처

```java
IntStream mapToInt(ToIntFunction<? super T> mapper)
```

> 비슷한 형제: `mapToLong`, `mapToDouble`, `mapToObj`(역방향).

## 왜 필요한가?

```
[ Stream<Integer>의 한계 ]
list.stream().sum()          // X Stream에는 sum() 없음
list.stream().toArray();     // Object[] 반환 — int[] 못 만듦

[ IntStream으로 바꾸면 ]
list.stream()
    .mapToInt(Integer::intValue)
    .sum();                  // O int 합계
    .toArray();              // O int[] 반환
```

> `Stream<Integer>`는 객체 박싱 비용이 있고, 합계/평균 등 수치 연산이 부족해서 **수치 처리는 IntStream이 표준**.

## 동작 추적

```java
List<Integer> list = Arrays.asList(1, 2, 3, 4);
```

```
[ 초기 상태 ]
list: [1, 2, 3, 4]   (Stream<Integer>)
```

### 항등 매핑 (언박싱만)

```java
int[] arr = list.stream()
    .mapToInt(i -> i)             // Integer → int 자동 언박싱
    .toArray();
```

```
[ 동작 ]
Stream<Integer>  →  IntStream  →  int[]
[1, 2, 3, 4]        [1, 2, 3, 4]   [1, 2, 3, 4]
```

```java
// 메서드 레퍼런스 형태 (관용적)
int[] arr = list.stream()
    .mapToInt(Integer::intValue)
    .toArray();
```

> `i -> i`와 `Integer::intValue`는 같은 결과. 후자가 의도가 더 명확함.

### 변환 매핑

```java
List<String> words = Arrays.asList("a", "bb", "ccc");

int totalLen = words.stream()
    .mapToInt(String::length)     // String → int
    .sum();
// totalLen: 6
```

```
[ 단계별 ]
Stream<String>:  ["a", "bb", "ccc"]
mapToInt(len):   IntStream  [1, 2, 3]
sum():           6
```

## 자주 쓰는 패턴

### List<Integer> → int[]

```java
List<Integer> list = new ArrayList<>(Arrays.asList(1, 3, 0, 1));

int[] arr = list.stream()
    .mapToInt(Integer::intValue)
    .toArray();
// arr: [1, 3, 0, 1]
```

```
[ 추적 ]
누적 list:  [1, 3, 0, 1]   ← ArrayList<Integer> / LinkedList<Integer>
mapToInt:   IntStream      ← 언박싱
toArray:    [1, 3, 0, 1]   ← int[]
```

### 합계 / 평균 / 최댓값

```java
List<Integer> nums = Arrays.asList(3, 1, 4, 1, 5, 9);

int sum  = nums.stream().mapToInt(Integer::intValue).sum();           // 23
double avg = nums.stream().mapToInt(Integer::intValue).average().getAsDouble();  // 3.83
int max  = nums.stream().mapToInt(Integer::intValue).max().getAsInt(); // 9
int min  = nums.stream().mapToInt(Integer::intValue).min().getAsInt(); // 1
```

> `average`, `max`, `min`은 빈 스트림일 수 있어서 `OptionalDouble`/`OptionalInt`로 감싸 반환.

### 객체 필드의 합계

```java
class Student { int score; }
List<Student> students = ...;

int totalScore = students.stream()
    .mapToInt(s -> s.score)
    .sum();
```

### 연속 중복 제거 후 int[] 반환 (코딩테스트 단골)

```java
public int[] solution(int[] arr) {
    LinkedList<Integer> list = new LinkedList<>();
    int last = arr[0];
    list.add(last);

    for (int num : arr) {
        if (num == last) continue;
        list.add(num);
        last = num;
    }

    return list.stream().mapToInt(i -> i).toArray();
}
```

```
[ 추적 ]
입력:        [1, 1, 3, 3, 0, 1, 1]
list 누적:   [1, 3, 0, 1]
mapToInt:    IntStream
toArray:     [1, 3, 0, 1]   ← int[]
```

## IntStream → Stream<Integer> (역방향)

```java
int[] arr = {1, 2, 3};

List<Integer> list = Arrays.stream(arr)   // IntStream
    .boxed()                              // IntStream → Stream<Integer>
    .collect(Collectors.toList());
```

> `boxed()`가 `mapToObj(Integer::valueOf)`의 단축형.

## 흔한 실수

### `Stream<int[]>`에 mapToInt 못 씀

```java
Stream<int[]> s = ...;
// X ToIntFunction<int[]>로 어떻게 변환할지 정의해야 함
s.mapToInt(arr -> arr[0]);   // 의도가 명확할 때만
```

### null 원소

```java
List<Integer> list = Arrays.asList(1, null, 3);

// X NullPointerException — null을 int로 언박싱 못 함
list.stream().mapToInt(Integer::intValue).sum();

// O filter로 걸러내기
list.stream()
    .filter(Objects::nonNull)
    .mapToInt(Integer::intValue)
    .sum();
```

## 형제 메서드

|메서드|반환|용도|
|---|---|---|
|`mapToInt`|`IntStream`|`int`로 변환|
|`mapToLong`|`LongStream`|`long`으로 변환|
|`mapToDouble`|`DoubleStream`|`double`으로 변환|
|`mapToObj`|`Stream<R>`|IntStream → 객체 Stream (역방향)|
|`map`|`Stream<R>`|일반 객체 변환 (박싱 유지)|

## 시간복잡도

|연산|복잡도|
|---|---|
|`mapToInt`|O(n) — 각 원소 1회 변환|
|이후 `sum`/`toArray`|O(n)|

## 핵심 정리

`mapToInt`는 `Stream<T>`를 **`IntStream`으로 바꿔 원시 타입 전용 연산을 쓸 수 있게** 해주는 다리입니다. 가장 자주 쓰는 형태는 `List<Integer> → int[]` 변환 (`list.stream().mapToInt(i -> i).toArray()`)이며, 합계/평균 같은 수치 집계도 박싱 없이 처리할 수 있어 [[Stream]]에서 수치 데이터를 다룰 때 사실상 표준 패턴입니다.
