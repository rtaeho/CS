---
title: "HashMap.values"
tags: [해시맵, 해시]
status: published
---

[[HashMap]]에 저장된 **모든 값을 Collection 형태로 반환**합니다.

## 시그니처

```java
Collection<V> values()
```

반환되는 Collection은 **HashMap의 뷰(view)** 입니다.

## 동작 추적

```java
Map<String, Integer> map = new HashMap<>();
map.put("apple", 1000);
map.put("banana", 500);
map.put("grape", 2000);
```

```
[ 초기 상태 ]
map: { apple=1000, banana=500, grape=2000 }
```

```java
Collection<Integer> values = map.values();
// values = [1000, 500, 2000]   (순서 보장 X, 중복 가능)
```

```
[ 변경 후 ]
map:    { apple=1000, banana=500, grape=2000 }   ← 변화 없음
values: [1000, 500, 2000]                         ← 뷰
```

## 자주 쓰는 패턴

### 합계 (베스트앨범 — 장르별 재생수 합계)

```java
Map<String, Integer> playCount = new HashMap<>();
playCount.put("classic", 1450);    // 500 + 150 + 800
playCount.put("pop", 3100);        // 600 + 2500
```

```
[ 초기 상태 ]
playCount: { classic=1450, pop=3100 }
```

```java
int total = 0;
for (int count : playCount.values()) {
    total += count;
}
// total = 4550
```

```java
// Stream으로
int total = playCount.values().stream()
    .mapToInt(Integer::intValue)
    .sum();
```

### 최댓값 / 최솟값

```java
int max = Collections.max(playCount.values());   // 3100
int min = Collections.min(playCount.values());   // 1450
```

### 특정 값의 존재 확인

```java
Map<String, String> map = new HashMap<>();
map.put("apple", "red");
map.put("banana", "yellow");
```

```java
map.values().contains("red");      // true   ← O(n) 선형 탐색
map.values().contains("blue");     // false
```

> 값 기준 조회가 잦다면 HashMap 구조가 부적합. 키-값을 뒤집은 reverseMap을 따로 만들거나 다른 자료구조 고려.

## 주의: 중복 가능

```
keySet():  Set         ← 키는 중복 없음
values():  Collection  ← 값은 중복 가능 (Set이 아님)
```

```java
Map<String, Integer> map = new HashMap<>();
map.put("a", 1);
map.put("b", 1);
map.put("c", 1);
```

```
[ 상태 ]
map: { a=1, b=1, c=1 }

map.values()    → [1, 1, 1]   ← 같은 값 3번 (Collection)
map.keySet()    → [a, b, c]   ← Set이라 항상 unique
```

## 뷰의 동기화

```
values()도 keySet()처럼 뷰:

map: { a=1, b=2 }
Collection<Integer> v = map.values();
map.put("c", 3);

map:  { a=1, b=2, c=3 }
v:    [1, 2, 3]   ← 자동 반영
```

## keySet() vs entrySet() vs values()

|메서드|반환|언제 쓰는가|
|---|---|---|
|[[HashMap.keySet]]|`Set<K>`|키만 필요할 때|
|`values()`|`Collection<V>`|값만 필요할 때|
|[[HashMap.entrySet]]|`Set<Map.Entry<K,V>>`|키·값 모두 필요할 때 (가장 효율적)|

## 시간복잡도

|연산|복잡도|
|---|---|
|`values()` 호출|O(1) (뷰 반환)|
|순회|O(n)|
|`contains()`|O(n) ← 키와 다르게 선형 탐색|
