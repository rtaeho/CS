---
title: "HashMap.keySet"
tags: [해시맵, 해시]
status: published
---

[[HashMap]]에 저장된 **모든 키를 Set 형태로 반환**합니다. 주로 키 순회나 키 집합 연산에 사용됩니다.

## 시그니처

```java
Set<K> keySet()
```

반환되는 Set은 **HashMap의 뷰(view)** 입니다 — 별도 복사본이 아니라 원본을 그대로 들여다보는 창문.

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
Set<String> keys = map.keySet();
// keys = [apple, banana, grape]   (순서 보장 X)
```

```
[ 변경 후 ]
map:  { apple=1000, banana=500, grape=2000 }   ← 변화 없음
keys: [apple, banana, grape]                    ← 뷰 (map과 연동)
```

## 자주 쓰는 패턴

### 조건에 맞는 키 찾기 (완주하지 못한 선수)

```java
Map<String, Integer> map = new HashMap<>();
map.put("mislav", 1);
map.put("stanko", 0);
map.put("ana", 0);
```

```
[ 초기 상태 ]
map: { mislav=1, stanko=0, ana=0 }
```

```java
String answer = "";
for (String key : map.keySet()) {
    if (map.get(key) != 0) {
        answer = key;
        break;
    }
}
```

```
[ 단계별 추적 ]

key = "mislav":
  map.get("mislav") = 1 → 0 아님 → answer = "mislav", break

→ answer = "mislav"
```

> 키와 값을 **둘 다** 쓸 거라면 [[HashMap.entrySet]]이 더 효율적 — `keySet().get()`은 매번 해시 조회를 한 번 더 하기 때문.

### 집합 연산 (교집합 / 차집합)

```java
Map<String, Integer> aMap = new HashMap<>();
aMap.put("apple", 1);
aMap.put("banana", 2);
aMap.put("grape", 3);

Map<String, Integer> bMap = new HashMap<>();
bMap.put("banana", 10);
bMap.put("orange", 20);
```

```
[ 초기 상태 ]
aMap: { apple=1, banana=2, grape=3 }
bMap: { banana=10, orange=20 }
```

```java
// 두 map 모두에 있는 키 (교집합)
Set<String> common = new HashSet<>(aMap.keySet());
common.retainAll(bMap.keySet());
// common = [banana]

// aMap에만 있는 키 (차집합)
Set<String> aOnly = new HashSet<>(aMap.keySet());
aOnly.removeAll(bMap.keySet());
// aOnly = [apple, grape]
```

> `new HashSet<>(...)`로 복사한 이유: keySet()은 뷰라 직접 변경하면 원본 map까지 변경됨.

## 주의: 뷰의 동기화

```
keySet()은 원본 HashMap의 뷰:

Set<String> keys = map.keySet();
map.put("new", 1);          ← 원본 변경
keys.contains("new");       ← true (뷰에도 반영)
```

```
[ 동기화 추적 ]

map:  { a=1, b=2 }
keys: [a, b]   ← 뷰

map.put("c", 3);

map:  { a=1, b=2, c=3 }
keys: [a, b, c]   ← 자동 반영
```

### 순회 중 안전한 삭제

```java
// X for-each 중 map.remove → ConcurrentModificationException
for (String key : map.keySet()) {
    if (조건) map.remove(key);
}

// O Iterator의 remove()
Iterator<String> it = map.keySet().iterator();
while (it.hasNext()) {
    String key = it.next();
    if (조건) it.remove();   // 안전
}
```

## keySet() vs entrySet() vs values()

|메서드|반환|언제 쓰는가|
|---|---|---|
|`keySet()`|`Set<K>`|키만 필요할 때|
|[[HashMap.values]]|`Collection<V>`|값만 필요할 때|
|[[HashMap.entrySet]]|`Set<Map.Entry<K,V>>`|키·값 모두 필요할 때 (가장 효율적)|

## 시간복잡도

|연산|복잡도|
|---|---|
|`keySet()` 호출|O(1) (뷰 반환)|
|순회|O(n)|
|`contains()`|O(1)|
