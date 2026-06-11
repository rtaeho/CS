---
title: "Set.removeAll"
tags: [자료구조, Set, 컬렉션]
status: published
---

[[Set]]에서 **다른 컬렉션에 포함된 원소를 모두 삭제**합니다. 이는 곧 **차집합** 연산입니다.

## 시그니처

```java
boolean removeAll(Collection<?> c)
```

|반환값|의미|
|---|---|
|`true`|Set이 변경됨 (1개 이상 삭제됨)|
|`false`|c와 겹치는 원소가 없음 → 변화 없음|

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
boolean changed = a.removeAll(b);
// changed = true
```

```
[ 동작 ]
a의 각 원소를 검사 → b에 있으면 삭제:
  1 → b에 없음 → 유지
  2 → b에 없음 → 유지
  3 → b에 있음 → 삭제
  4 → b에 있음 → 삭제

[ 변경 후 ]
a: [1, 2]   ← 차집합 (a - b)
b: [3, 4, 5, 6]   ← 변화 없음 (b는 읽기만)
```

## 차집합 패턴

```java
Set<Integer> a = new HashSet<>(Arrays.asList(1, 2, 3, 4));
Set<Integer> b = new HashSet<>(Arrays.asList(3, 4, 5, 6));

// 원본 보존하면서 차집합 만들기
Set<Integer> diff = new HashSet<>(a);   // a 복사
diff.removeAll(b);                       // b의 원소 제거
// diff: [1, 2]
```

```
[ 동작 추적 ]

new HashSet<>(a):          diff: [1, 2, 3, 4]
removeAll(b):
  1 → b에 없음 → 유지
  2 → b에 없음 → 유지
  3 → b에 있음 → 제거       diff: [1, 2, 4]
  4 → b에 있음 → 제거       diff: [1, 2]
```

## 자주 쓰는 패턴

### 처리하지 않은 항목만 남기기

```java
Set<Integer> all = new HashSet<>(Arrays.asList(1, 2, 3, 4, 5));
Set<Integer> processed = new HashSet<>(Arrays.asList(2, 4));

all.removeAll(processed);
// all: [1, 3, 5]   ← 미처리 항목
```

### 친구 추천 (내 친구 - 이미 친한 사람)

```java
Set<String> potentialFriends = ...;        // [alice, bob, charlie, dave]
Set<String> currentFriends   = ...;        // [bob, charlie]

Set<String> recommendations = new HashSet<>(potentialFriends);
recommendations.removeAll(currentFriends);
// recommendations: [alice, dave]
```

### 특정 항목 일괄 제외

```java
Set<String> tags = new HashSet<>(Arrays.asList("java", "spring", "test", "draft"));
Set<String> excluded = new HashSet<>(Arrays.asList("test", "draft"));

tags.removeAll(excluded);
// tags: [java, spring]
```

> removeAll은 **호출한 Set이 변경됨**. 원본을 유지하려면 `new HashSet<>(...)`로 복사 후 호출.

## 다른 집합 연산과 비교

|메서드|의미|결과|
|---|---|---|
|[[Set.addAll]]`(b)`|합집합|`a ∪ b`|
|[[Set.retainAll]]`(b)`|교집합|`a ∩ b`|
|`removeAll(b)`|차집합|`a - b`|

```
시각화 (a = {1,2,3,4}, b = {3,4,5,6}):

addAll:    [1, 2, 3, 4, 5, 6]   ← 둘을 합침
retainAll: [3, 4]               ← 공통만 남김
removeAll: [1, 2]               ← 겹치는 것 제거
```

## 시간복잡도

|평균|최악|
|---|---|
|O(n) (n = 작은 쪽 크기)|O(n × m)|
