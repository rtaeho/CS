---
title: "Set.retainAll"
tags: [집합, 해시]
status: published
---

[[Set]]에서 **다른 컬렉션에 포함된 원소만 남기고 나머지를 삭제**합니다. 이는 곧 **교집합** 연산입니다.

## 시그니처

```java
boolean retainAll(Collection<?> c)
```

|반환값|의미|
|---|---|
|`true`|Set이 변경됨 (1개 이상 삭제됨)|
|`false`|모든 원소가 c에 포함되어 있음 → 변화 없음|

## 동작 추적

```java
Set<Integer> a = new HashSet<>(Arrays.asList(1, 2, 3, 4));
Set<Integer> b = new HashSet<>(Arrays.asList(3, 4, 5, 6));
```

```
[ 초기 상태 ]
a: [1, 2, 3, 4]
b: [3, 4, 5, 6]
```

```java
boolean changed = a.retainAll(b);
// changed = true
```

```
[ 동작 ]
a의 각 원소를 검사 → b에 없으면 삭제:
  1 → b에 없음 → 삭제
  2 → b에 없음 → 삭제
  3 → b에 있음 → 유지
  4 → b에 있음 → 유지

[ 변경 후 ]
a: [3, 4]   ← 교집합 (a ∩ b)
b: [3, 4, 5, 6]   ← 변화 없음 (b는 읽기만)
```

## 교집합 패턴

```java
Set<Integer> a = new HashSet<>(Arrays.asList(1, 2, 3, 4));
Set<Integer> b = new HashSet<>(Arrays.asList(3, 4, 5, 6));

// 원본 보존하면서 교집합 만들기
Set<Integer> intersection = new HashSet<>(a);   // a 복사
intersection.retainAll(b);                       // b에 없는 것 제거
// intersection: [3, 4]
```

```
[ 동작 추적 ]

new HashSet<>(a):          intersection: [1, 2, 3, 4]
retainAll(b):
  1 → b에 없음 → 제거       intersection: [2, 3, 4]
  2 → b에 없음 → 제거       intersection: [3, 4]
  3 → b에 있음 → 유지
  4 → b에 있음 → 유지       intersection: [3, 4]
```

## 자주 쓰는 패턴

### 공통 친구 찾기

```java
Set<String> myFriends    = ...;   // [alice, bob, charlie, dave]
Set<String> yourFriends  = ...;   // [bob, charlie, eve]

Set<String> common = new HashSet<>(myFriends);
common.retainAll(yourFriends);
// common: [bob, charlie]
```

### 두 검색 결과의 공통 항목

```java
Set<Integer> resultA = searchByCategory();   // [1, 2, 3, 4, 5]
Set<Integer> resultB = searchByPrice();      // [3, 4, 5, 6, 7]

resultA.retainAll(resultB);   // 둘 다 만족하는 항목
// resultA: [3, 4, 5]
```

> retainAll은 **호출한 Set이 변경됨**. 원본을 유지하려면 `new HashSet<>(...)`로 복사 후 호출.

## 빈 결과 처리

```java
Set<Integer> a = new HashSet<>(Arrays.asList(1, 2, 3));
Set<Integer> b = new HashSet<>(Arrays.asList(4, 5, 6));

a.retainAll(b);
// a: [ ]   ← 공통 원소 없음 → 빈 Set

if (a.isEmpty()) {
    // 교집합 없음
}
```

## 다른 집합 연산과 비교

|메서드|의미|결과|
|---|---|---|
|[[Set.addAll]]`(b)`|합집합|`a ∪ b`|
|`retainAll(b)`|교집합|`a ∩ b`|
|[[Set.removeAll]]`(b)`|차집합|`a - b`|

## 시간복잡도

|평균|최악|
|---|---|
|O(n) (n = a의 원소 수)|O(n × m)|
