---
title: "List.set"
tags: [컬렉션, 배열]
status: published
---

[[List]]의 **인덱스 위치 값을 변경**하고, **이전 값을 반환**합니다.

## 시그니처

```java
E set(int index, E element)
```

|반환값|의미|
|---|---|
|이전 값|해당 인덱스에 있던 원래 값|

|예외|발생 조건|
|---|---|
|`IndexOutOfBoundsException`|`index < 0` 또는 `index >= size()`|

## 동작 추적

```java
List<Integer> list = new ArrayList<>(Arrays.asList(10, 20, 30));
```

```
[ 초기 상태 ]
list: [10, 20, 30]
       0   1   2
```

```java
Integer prev = list.set(1, 99);
// prev = 20
```

```
[ 변경 후 ]
list: [10, 99, 30]   ← 인덱스 1의 값이 20 → 99로
                      size는 변하지 않음
```

## set() vs add(i, e) 차이

```java
List<Integer> list = new ArrayList<>(Arrays.asList(10, 20, 30));
```

```
[ set — 같은 자리 값 교체 ]
list.set(1, 99);
list: [10, 99, 30]   ← size 그대로 (3)

[ add(i, e) — 자리 끼워넣기 ]
list.add(1, 99);
list: [10, 99, 20, 30]   ← size 1 증가 (4)
                          ← 20, 30이 한 칸씩 뒤로
```

## 자주 쓰는 패턴

### 값 교체

```java
List<String> names = new ArrayList<>(Arrays.asList("Alice", "Bob", "Charlie"));
names.set(0, "Alex");
// names: [Alex, Bob, Charlie]
```

### 카운터 증가 (인덱스가 의미를 가질 때)

```java
List<Integer> count = new ArrayList<>(Collections.nCopies(10, 0));
// [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

count.set(3, count.get(3) + 1);
count.set(7, count.get(7) + 1);
count.set(3, count.get(3) + 1);
```

```
[ 단계별 추적 ]

초기:                          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
set(3, get(3)+1) = set(3, 1):  [0, 0, 0, 1, 0, 0, 0, 0, 0, 0]
set(7, get(7)+1) = set(7, 1):  [0, 0, 0, 1, 0, 0, 0, 1, 0, 0]
set(3, get(3)+1) = set(3, 2):  [0, 0, 0, 2, 0, 0, 0, 1, 0, 0]
```

> 단순 카운팅이라면 `int[]` 배열이나 [[HashMap]]이 더 자연스러움. List.set은 **같은 자리 값을 자주 교체**하는 시뮬레이션 류 문제에서 유용.

## 주의: 길이 확장 안 됨

```java
List<Integer> list = new ArrayList<>();   // []

// X 빈 리스트에 set 호출 → 예외
list.set(0, 100);   // IndexOutOfBoundsException

// O 먼저 add로 자리 만들고 set
list.add(0);
list.set(0, 100);
```

> set은 **이미 존재하는 인덱스만** 변경. 자리를 늘리려면 add 사용.

## 시간복잡도

|구현체|복잡도|
|---|---|
|[[ArrayList]]|O(1)|
|[[LinkedList]]|O(n) (인덱스 탐색 비용)|
