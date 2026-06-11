---
title: "List.contains"
tags: [자료구조, List, 컬렉션]
status: published
---

[[List]]에 **특정 원소가 존재하는지** 확인합니다.

## 시그니처

```java
boolean contains(Object o)
```

내부적으로 [[List.indexOf]]가 `-1`을 반환하는지 확인. 즉, **선형 탐색**입니다.

## 동작 추적

```java
List<String> list = new ArrayList<>(Arrays.asList("apple", "banana", "grape"));
```

```
[ 초기 상태 ]
list: [apple, banana, grape]
```

```java
list.contains("apple");    // true
list.contains("orange");   // false
```

```
[ 변경 후 ]
list: [apple, banana, grape]   ← 변화 없음 (조회만)
```

## 비교 기준: equals

```java
class Person {
    String name;
    Person(String n) { name = n; }
}

List<Person> list = new ArrayList<>();
list.add(new Person("Alice"));
list.add(new Person("Bob"));

list.contains(new Person("Alice"));   // false X
                                       // (equals 재정의 안 됨 → 메모리 주소 비교)
```

```java
class Person {
    String name;
    @Override
    public boolean equals(Object o) {
        if (!(o instanceof Person)) return false;
        return name.equals(((Person) o).name);
    }
    @Override
    public int hashCode() { return name.hashCode(); }
}

list.contains(new Person("Alice"));   // true O
```

> 객체를 List에 담아 contains 사용하려면 `equals`를 반드시 재정의.

## List vs Set의 contains

```
[ List에서 contains ]
선형 탐색 → O(n)

[ Set에서 contains ]
해시 조회 → O(1)
```

```java
// X contains를 자주 호출하는데 List 사용
List<Integer> blocked = ...;
for (int id : ids) {
    if (blocked.contains(id)) { ... }   // 매번 O(n) → 전체 O(n²)
}

// O Set 사용
Set<Integer> blocked = new HashSet<>(...);
for (int id : ids) {
    if (blocked.contains(id)) { ... }   // 매번 O(1) → 전체 O(n)
}
```

> 포함 여부 확인이 잦으면 [[Set]]에 저장.

## 자주 쓰는 패턴

### 단순 존재 확인

```java
List<String> tags = ...;
if (tags.contains("important")) {
    // 처리
}
```

### 중복 검사 (작은 입력)

```java
List<Integer> seen = new ArrayList<>();
for (int n : arr) {
    if (seen.contains(n)) {
        return true;   // 중복 발견
    }
    seen.add(n);
}
```

> 큰 입력에서는 [[Set]]을 쓰는 게 훨씬 빠름. seen.add의 반환값으로 한 번에 처리도 가능.

## 시간복잡도

|구현체|복잡도|
|---|---|
|[[ArrayList]]|O(n)|
|[[LinkedList]]|O(n)|

> List는 어떤 구현체든 contains는 O(n). 대규모 데이터의 포함 여부 확인은 [[Set]] 사용.
