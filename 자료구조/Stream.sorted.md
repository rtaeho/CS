[[Stream]]을 **정렬**합니다. 원본을 변경하지 않고 **새 Stream**을 반환하는 점이 다른 정렬 메서드와의 핵심 차이입니다.

## 시그니처

```java
Stream<T> sorted()                            // 자연 순서 (Comparable)
Stream<T> sorted(Comparator<? super T> c)     // 커스텀 정렬
```

## 동작 추적

```java
List<Integer> list = Arrays.asList(3, 1, 4, 1, 5);
```

```
[ 초기 상태 ]
list: [3, 1, 4, 1, 5]   ← 원본
```

### 자연 순서 정렬

```java
List<Integer> sorted = list.stream()
    .sorted()
    .collect(Collectors.toList());
```

```
[ 결과 ]
list:   [3, 1, 4, 1, 5]   ← 변화 없음 (원본 유지!)
sorted: [1, 1, 3, 4, 5]   ← 새 List
```

### 내림차순

```java
List<Integer> desc = list.stream()
    .sorted(Comparator.reverseOrder())
    .collect(Collectors.toList());
```

```
[ 결과 ]
desc: [5, 4, 3, 1, 1]
```

## 다른 정렬 방법과의 핵심 차이

```java
// in-place — 원본 변경
list.sort(null);
Collections.sort(list);
Arrays.sort(arr);

// 새 객체 반환 — 원본 보존
Stream<Integer> sorted = list.stream().sorted();
```

|항목|`Stream.sorted`|`list.sort` / `Collections.sort`|
|---|---|---|
|반환|새 Stream|void|
|원본 변경|❌ 보존|✅ 변경|
|체이닝|✅ filter, map과 결합 가능|❌ 단독 호출|
|비용|새 객체 생성 (약간 느림)|in-place|

## 자주 쓰는 패턴

### 다른 Stream 연산과 체이닝

```java
List<Integer> list = Arrays.asList(3, -1, 4, -1, 5, 9, -2, 6);

List<Integer> result = list.stream()
    .filter(n -> n > 0)        // 양수만
    .map(n -> n * 2)            // 두 배
    .sorted()                   // 정렬
    .limit(3)                   // 상위 3개
    .collect(Collectors.toList());
// result: [6, 8, 10]
```

```
[ 단계별 추적 ]

list:        [3, -1, 4, -1, 5, 9, -2, 6]
filter(>0):  [3, 4, 5, 9, 6]
map(*2):     [6, 8, 10, 18, 12]
sorted():    [6, 8, 10, 12, 18]
limit(3):    [6, 8, 10]
```

### 객체 정렬 + 매핑

```java
class Student { String name; int score; }
List<Student> students = ...;

// 점수 내림차순 → 이름만 추출
List<String> topNames = students.stream()
    .sorted((a, b) -> b.score - a.score)
    .map(s -> s.name)
    .collect(Collectors.toList());
```

### 정렬 후 첫 N개

```java
// 상위 3명
students.stream()
    .sorted(Comparator.comparingInt(Student::getScore).reversed())
    .limit(3)
    .forEach(s -> System.out.println(s.name));
```

## IntStream의 함정

```java
int[] arr = {3, 1, 4};

// ❌ IntStream.sorted()는 Comparator 못 받음
Arrays.stream(arr).sorted(Comparator.reverseOrder());   // 컴파일 에러

// ✅ boxed로 Stream<Integer>로 변환
int[] sorted = Arrays.stream(arr)
    .boxed()
    .sorted(Comparator.reverseOrder())
    .mapToInt(Integer::intValue)
    .toArray();
```

> `IntStream`, `LongStream`, `DoubleStream`은 자연 순서 정렬만 지원. 커스텀이 필요하면 박싱 필수.

## 정렬 시점

```
Stream은 lazy 평가 — 종단 연산이 호출돼야 실제 처리:

list.stream()
    .filter(...)      ┐
    .sorted()         │ 여기까지는 "계획"만 세움
    .map(...)         ┘
    .collect(...)     ← 이 시점에 실제 정렬 발생

→ 종단 연산 없이 sorted()만 호출하면 정렬 안 일어남
```

## 다른 정렬 방법과 비교

|방법|대상|반환|in-place|
|---|---|---|---|
|[[Arrays.sort]]|배열|void|✅|
|[[Collections.sort]]|List|void|✅|
|[[List.sort]]|List|void|✅|
|`Stream.sorted`|모든 컬렉션|새 Stream|❌|
|[[Arrays.parallelSort]]|배열|void|✅|

## 시간복잡도

|평균|최악|공간|
|---|---|---|
|O(n log n)|O(n log n)|O(n) — 새 컬렉션 생성|

> 내부적으로 **팀소트** 사용 — 안정 정렬.
