---
title: "Set.addAll"
tags: [자료구조, Set, 컬렉션]
status: published
---

[[Set]]에 다른 컬렉션의 원소들을 **모두 추가**합니다. 이는 곧 **합집합** 연산입니다.

## 시그니처

```java
boolean addAll(Collection<? extends E> c)
```

|반환값|의미|
|---|---|
|`true`|Set이 변경됨 (1개 이상 추가됨)|
|`false`|모든 원소가 이미 존재 → 변화 없음|

## 동작 추적

```java
Set<Integer> a = new HashSet<>(Arrays.asList(1, 2, 3));
Set<Integer> b = new HashSet<>(Arrays.asList(2, 3, 4));
```

```
[ 초기 상태 ]
a: [1, 2, 3]
b: [2, 3, 4]
```

```java
boolean changed = a.addAll(b);
// changed = true
```

```
[ 동작 ]
a에 b의 원소 하나씩 add:
  add(2) → false (이미 있음)
  add(3) → false (이미 있음)
  add(4) → true  (새로 추가)

[ 변경 후 ]
a: [1, 2, 3, 4]   ← 합집합
b: [2, 3, 4]      ← 변화 없음 (b는 읽기만)
```

## 합집합 패턴

```java
Set<Integer> a = new HashSet<>(Arrays.asList(1, 2, 3));
Set<Integer> b = new HashSet<>(Arrays.asList(2, 3, 4));

// 원본 보존하면서 합집합 만들기
Set<Integer> union = new HashSet<>(a);   // a 복사
union.addAll(b);                          // b의 원소 추가
```

```
[ 동작 추적 ]

new HashSet<>(a):              union: [1, 2, 3]   (a 복사)
union.addAll(b):
  add(2) 무시
  add(3) 무시
  add(4) 추가                  union: [1, 2, 3, 4]

a, b는 변경되지 않음.
```

## 자주 쓰는 패턴

### List를 Set으로 변환 (중복 제거)

```java
List<String> list = Arrays.asList("a", "b", "a", "c");
Set<String> unique = new HashSet<>();
unique.addAll(list);
// unique: [a, b, c]

// 또는 더 간단하게 — 생성자로
Set<String> unique = new HashSet<>(list);
```

### 여러 Set 병합

```java
Set<Integer> result = new HashSet<>();
for (Set<Integer> s : sets) {
    result.addAll(s);
}
```

```
[ 단계별 추적 ]

sets = [{1,2}, {2,3}, {3,4}]

result: [ ]

addAll({1,2}):    result: [1, 2]
addAll({2,3}):    result: [1, 2, 3]   (2는 무시)
addAll({3,4}):    result: [1, 2, 3, 4]  (3은 무시)
```

### 권한 누적

```java
Set<String> userPermissions = new HashSet<>();
userPermissions.addAll(rolePermissions);
userPermissions.addAll(groupPermissions);
userPermissions.addAll(individualPermissions);
```

## 다른 집합 연산과 비교

|메서드|의미|결과|
|---|---|---|
|`addAll(b)`|합집합|`a ∪ b`|
|[[Set.retainAll]]`(b)`|교집합|`a ∩ b`|
|[[Set.removeAll]]`(b)`|차집합|`a - b`|

```java
Set<Integer> a = new HashSet<>(Arrays.asList(1, 2, 3));
Set<Integer> b = new HashSet<>(Arrays.asList(2, 3, 4));

// 합집합
Set<Integer> u = new HashSet<>(a);
u.addAll(b);       // [1, 2, 3, 4]

// 교집합
Set<Integer> i = new HashSet<>(a);
i.retainAll(b);    // [2, 3]

// 차집합
Set<Integer> d = new HashSet<>(a);
d.removeAll(b);    // [1]
```

## 시간복잡도

|평균|최악|
|---|---|
|O(m) (m = 추가할 원소 수)|O(n × m)|
