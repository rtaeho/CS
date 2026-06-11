[[List]]의 **인스턴스 메서드로 정렬**합니다. Java 8+ 도입. `Collections.sort()` 대신 권장되는 방식입니다.

## 시그니처

```java
default void sort(Comparator<? super E> c)
```

|매개변수|동작|
|---|---|
|`null`|자연 순서 (Comparable 사용) — 오름차순|
|`Comparator`|커스텀 정렬|

## 동작 추적

```java
List<Integer> list = new ArrayList<>(Arrays.asList(3, 1, 4, 1, 5));
```

```
[ 초기 상태 ]
list: [3, 1, 4, 1, 5]
```

### null로 자연 순서 정렬

```java
list.sort(null);
```

```
[ 변경 후 ]
list: [1, 1, 3, 4, 5]   ← 오름차순 (Comparable 사용)
```

### Comparator로 커스텀 정렬

```java
list.sort(Comparator.reverseOrder());
```

```
[ 변경 후 ]
list: [5, 4, 3, 1, 1]
```

```java
list.sort((a, b) -> b - a);          // 내림차순 (람다)
list.sort(Comparator.naturalOrder()); // 오름차순 (명시적)
```

## list.sort() vs Collections.sort()

```java
// 동일한 동작 — 둘 다 가능
list.sort(null);
Collections.sort(list);

// Java 8 소스코드:
public static <T extends Comparable<? super T>> void sort(List<T> list) {
    list.sort(null);   // ← 내부적으로 list.sort() 호출
}
```

|항목|`list.sort()`|`Collections.sort()`|
|---|---|---|
|호출 방식|인스턴스 메서드|정적 메서드|
|등장|Java 8|Java 1.2|
|구현체별 최적화|O 가능 (오버라이드)|X 어려움|
|선호도|**Java 8+ 권장**|기존 코드 호환용|

> 메서드 호출이 한 단계 짧고, List 구현체가 자체 최적화 가능 (예: ArrayList는 내부 배열 직접 정렬).

## 자주 쓰는 패턴

### 객체 List 정렬 (Comparator 체이닝)

```java
class Student { String name; int score; }
List<Student> students = ...;

// 점수 내림차순, 같으면 이름 오름차순
students.sort(
    Comparator.comparingInt(Student::getScore).reversed()
        .thenComparing(Student::getName)
);
```

### 정렬 후 첫/끝 원소

```java
List<Integer> nums = new ArrayList<>(Arrays.asList(3, 1, 4, 1, 5));
nums.sort(null);
int min = nums.get(0);                    // 1
int max = nums.get(nums.size() - 1);      // 5
```

### 부분 정렬 — 직접 지원 안 함

```java
// X List.sort에는 fromIndex/toIndex 버전 없음

// O subList로 부분 정렬 (subList는 원본의 뷰)
List<Integer> list = new ArrayList<>(Arrays.asList(5, 4, 3, 2, 1));
list.subList(1, 4).sort(null);
// list: [5, 2, 3, 4, 1]
```

```
[ 동작 추적 ]
list: [5, 4, 3, 2, 1]
list.subList(1, 4)            ← 인덱스 1~3 뷰: [4, 3, 2]
.sort(null)                    ← 뷰를 정렬 → [2, 3, 4]
                                  원본도 변경됨 (뷰는 같은 메모리)
list: [5, 2, 3, 4, 1]
```

## 자주 하는 실수

### 변경 불가능한 List

```java
List<Integer> list = List.of(3, 1, 2);
list.sort(null);   // UnsupportedOperationException
```

### Arrays.asList()의 함정

```java
// Arrays.asList는 고정 크기지만 정렬은 가능
List<Integer> list = Arrays.asList(3, 1, 2);
list.sort(null);   // O 동작
list.add(4);       // X UnsupportedOperationException
```

## 다른 정렬 방법과 비교

|방법|대상|반환|in-place|
|---|---|---|---|
|[[Arrays.sort]]|배열|void|O|
|[[Collections.sort]]|List|void|O|
|`List.sort`|List|void|O|
|[[Stream.sorted]]|모든 컬렉션|새 Stream|X|
|[[Arrays.parallelSort]]|배열|void|O|

## 시간복잡도

|평균|최악|공간|
|---|---|---|
|O(n log n)|O(n log n)|O(n)|

> 내부적으로 **팀소트(Tim Sort)** 사용 — 안정 정렬.
