[[Collections]]의 **List를 정렬**하는 정적 메서드. 기본은 **오름차순**(자연 순서), `Comparator`를 넘기면 커스텀 정렬 가능합니다.

## 시그니처

```java
static <T extends Comparable<? super T>> void sort(List<T> list)
static <T> void sort(List<T> list, Comparator<? super T> c)
```

## 동작 추적

```java
List<Integer> list = new ArrayList<>(Arrays.asList(3, 1, 4, 1, 5));
```

```
[ 초기 상태 ]
list: [3, 1, 4, 1, 5]
```

```java
Collections.sort(list);
```

```
[ 변경 후 ]
list: [1, 1, 3, 4, 5]   ← 오름차순 (in-place)
```

> 반환값 없음 (`void`). 입력 List를 직접 수정합니다.

## list.sort() vs Collections.sort()

```java
// 같은 동작 — 둘 다 가능
Collections.sort(list);
list.sort(null);

// Collections.sort는 내부적으로 list.sort를 호출 (Java 8+)
public static <T extends Comparable<? super T>> void sort(List<T> list) {
    list.sort(null);
}
```

|항목|`Collections.sort(list)`|`list.sort(null)`|
|---|---|---|
|등장 시기|Java 1.2|Java 8|
|선호도|기존 코드와 호환|**Java 8+ 권장**|
|동작|내부적으로 `list.sort()` 호출|직접 호출|

> Java 8 이후로는 [[List.sort]] 사용을 권장.

## Comparator로 커스텀 정렬

```java
List<Integer> list = new ArrayList<>(Arrays.asList(3, 1, 4, 1, 5));

// 내림차순
Collections.sort(list, (a, b) -> b - a);
Collections.sort(list, Comparator.reverseOrder());
```

```
[ 변경 후 ]
list: [5, 4, 3, 1, 1]
```

## 자주 쓰는 패턴

### 객체 List 정렬

```java
class Student { String name; int score; }
List<Student> students = new ArrayList<>(...);

// 점수 오름차순
Collections.sort(students, (a, b) -> a.score - b.score);

// 점수 내림차순, 같으면 이름 오름차순
Collections.sort(students, (a, b) -> {
    if (a.score != b.score) return Integer.compare(b.score, a.score);
    return a.name.compareTo(b.name);
});
```

### 정렬 후 인접 비교

```java
List<Integer> list = new ArrayList<>(Arrays.asList(3, 1, 2, 3, 4));
Collections.sort(list);
// [1, 2, 3, 3, 4]

for (int i = 1; i < list.size(); i++) {
    if (list.get(i).equals(list.get(i-1))) {
        return true;   // 중복 발견
    }
}
```

자세한 패턴은 [[정렬 후 인접 비교]] 참고.

## 자주 하는 실수

### 변경 불가능한 List

```java
// ❌ List.of() 는 진짜 불변 — 정렬 불가
List<Integer> list = List.of(3, 1, 2);
Collections.sort(list);   // UnsupportedOperationException

// ❌ Arrays.asList()는 고정 크기지만 정렬은 가능
List<Integer> list = Arrays.asList(3, 1, 2);
Collections.sort(list);   // ✅ 동작함

// ✅ 안전: 새 ArrayList로 감싸기
List<Integer> list = new ArrayList<>(List.of(3, 1, 2));
Collections.sort(list);
```

### `b - a` 오버플로

```java
// ❌ a=Integer.MIN_VALUE, b=Integer.MAX_VALUE면 오버플로
Collections.sort(list, (a, b) -> a - b);

// ✅ 안전
Collections.sort(list, (a, b) -> Integer.compare(a, b));
Collections.sort(list, Comparator.naturalOrder());
```

## 다른 정렬 방법과 비교

|방법|대상|반환|in-place|
|---|---|---|---|
|[[Arrays.sort]]|배열|void|✅|
|`Collections.sort`|List|void|✅|
|[[List.sort]]|List|void|✅|
|[[Stream.sorted]]|모든 컬렉션|새 Stream|❌|
|[[Arrays.parallelSort]]|배열|void|✅|

## 시간복잡도

|평균|최악|공간|
|---|---|---|
|O(n log n)|O(n log n)|O(n)|

> 내부적으로 **팀소트(Tim Sort)** 사용 — 안정 정렬.
