[[List]]에서 **특정 원소가 처음 등장하는 인덱스**를 반환합니다. 없으면 `-1`.

## 시그니처

```java
int indexOf(Object o)
int lastIndexOf(Object o)   // 마지막 등장 인덱스
```

|반환값|의미|
|---|---|
|`0` 이상|첫(또는 마지막) 등장 인덱스|
|`-1`|존재하지 않음|

## 동작 추적

```java
List<Integer> list = new ArrayList<>(Arrays.asList(10, 20, 30, 20, 10));
```

```
[ 초기 상태 ]
list: [10, 20, 30, 20, 10]
       0   1   2   3   4
```

```java
list.indexOf(20);       // 1   (첫 등장)
list.indexOf(99);       // -1  (없음)
list.lastIndexOf(20);   // 3   (마지막 등장)
list.lastIndexOf(10);   // 4
```

```
[ 변경 후 ]
list: [10, 20, 30, 20, 10]   ← 변화 없음 (조회만)
```

## indexOf vs contains

```java
list.indexOf("apple") != -1   // true/false
list.contains("apple")        // true/false (내부적으로 indexOf 사용)

// → 단순 존재 확인이면 contains, 위치도 필요하면 indexOf
```

## 비교 기준: equals

contains와 동일하게 **equals로 비교**. 객체를 다룰 때는 equals 재정의 필수.

```java
List<Person> list = ...;
list.indexOf(new Person("Alice"));
// equals 재정의 안 되어 있으면 -1 반환
```

## 자주 쓰는 패턴

### 위치 기반 처리

```java
List<String> menu = Arrays.asList("apple", "banana", "grape");
int idx = menu.indexOf("banana");
if (idx != -1) {
    System.out.println(idx + "번째 메뉴");   // 1번째 메뉴
}
```

### 좌표 압축의 인덱스 매핑

```java
int[] arr = {100, 50, 75, 50, 100};

// 1. 정렬 + 중복 제거
List<Integer> sorted = Arrays.stream(arr).distinct().sorted().boxed()
    .collect(Collectors.toList());
// [50, 75, 100]

// 2. 각 값의 압축된 인덱스
int[] compressed = new int[arr.length];
for (int i = 0; i < arr.length; i++) {
    compressed[i] = sorted.indexOf(arr[i]);
}
// compressed: [2, 0, 1, 0, 2]
```

```
[ 단계별 추적 ]

arr      sorted        compressed
100   →  indexOf(100)  → 2
50    →  indexOf(50)   → 0
75    →  indexOf(75)   → 1
50    →  indexOf(50)   → 0
100   →  indexOf(100)  → 2
```

> 좌표 압축은 큰 값들을 작은 인덱스로 매핑할 때 사용. 큰 데이터에서는 [[HashMap]]으로 매핑이 더 빠름 (O(n) vs O(n²)).

## 시간복잡도

|연산|복잡도|
|---|---|
|`indexOf(o)`|O(n)|
|`lastIndexOf(o)`|O(n)|

> 어떤 List 구현체든 선형 탐색.
