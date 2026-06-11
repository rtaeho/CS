---
title: "List.add"
tags: [자료구조, List, 컬렉션]
status: published
---

[[List]]에 원소를 추가합니다. 끝에 추가하거나 특정 인덱스에 삽입할 수 있습니다.

## 시그니처

```java
boolean add(E e)              // 끝에 추가
void add(int index, E e)      // index 위치에 삽입
boolean addAll(Collection<? extends E> c)              // 컬렉션 전체 끝에 추가
boolean addAll(int index, Collection<? extends E> c)   // index 위치부터 삽입
```

## 동작 추적

```java
List<Integer> list = new ArrayList<>();
```

```
[ 초기 상태 ]
list: []
```

### 끝에 추가

```java
list.add(10);
list.add(20);
list.add(30);
```

```
[ 변경 후 ]
list: [10, 20, 30]
```

### 특정 위치에 삽입

```java
list.add(1, 99);   // 인덱스 1에 99 삽입
```

```
[ 동작 ]
인덱스 1부터 끝까지 한 칸씩 뒤로 밀고, 그 자리에 99 삽입

[ 변경 후 ]
list: [10, 99, 20, 30]
       0   1   2   3
```

### 컬렉션 전체 추가

```java
List<Integer> a = new ArrayList<>(Arrays.asList(1, 2, 3));
List<Integer> b = Arrays.asList(4, 5);

a.addAll(b);
```

```
[ 변경 후 ]
a: [1, 2, 3, 4, 5]
```

```java
a.addAll(1, b);   // 인덱스 1부터 b 삽입
```

```
[ 변경 후 ]
a: [1, 4, 5, 2, 3]   ← 1 뒤에 4, 5 끼워넣음
   0  1  2  3  4
```

## ArrayList vs LinkedList 비교

|동작|[[ArrayList]]|[[LinkedList]]|
|---|---|---|
|`add(e)` 끝에 추가|O(1) 평균 (확장 시 O(n))|O(1)|
|`add(i, e)` 중간 삽입|O(n) — 뒤 원소 이동|O(n) — 인덱스 탐색|
|`add(0, e)` 맨 앞 삽입|O(n)|O(1)|

## 자주 쓰는 패턴

### 조건부 누적 (연속 중복 제거)

```java
int[] arr = {1, 1, 3, 3, 0, 1, 1};
ArrayList<Integer> list = new ArrayList<>();
int lastValue = -1;

for (int num : arr) {
    if (num != lastValue) {
        list.add(num);
        lastValue = num;
    }
}
```

```
[ 단계별 추적 ]

초기:                       list: [],         lastValue=-1

num=1, !=lastValue → 추가:   list: [1],        lastValue=1
num=1, ==lastValue → 무시:   list: [1],        lastValue=1
num=3, !=lastValue → 추가:   list: [1, 3],     lastValue=3
num=3, ==lastValue → 무시:   list: [1, 3],     lastValue=3
num=0, !=lastValue → 추가:   list: [1, 3, 0],  lastValue=0
num=1, !=lastValue → 추가:   list: [1, 3, 0, 1], lastValue=1
num=1, ==lastValue → 무시:   list: [1, 3, 0, 1], lastValue=1
```

### 동적 결과 누적

```java
ArrayList<int[]> answers = new ArrayList<>();

for (int n : input) {
    if (조건1(n)) {
        answers.add(new int[]{n, calc(n)});
    }
}

// 끝에서 배열로 변환 (List.toArray 참고)
```

### 이미 있는 List에 원소들 합치기

```java
List<String> users = new ArrayList<>();
users.addAll(adminUsers);
users.addAll(memberUsers);
users.addAll(guestUsers);
```

## 주의: 반환값

```
add(E e)         → boolean (List는 항상 true)
add(int i, E e)  → void (반환값 없음)
addAll(...)      → boolean (변경됐으면 true)
```

```java
list.add(10);              // 반환 true (무시)
boolean changed = list.addAll(other);   // other가 비었으면 false
```

## 시간복잡도 (ArrayList 기준)

|연산|평균|최악|
|---|---|---|
|`add(e)` 끝에|O(1)|O(n) (확장 시)|
|`add(i, e)` 중간|O(n)|O(n)|
|`addAll(c)` 끝에|O(m) (m=c 크기)|O(n+m) (확장 시)|
