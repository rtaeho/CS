---
title: "HashMap.remove"
tags: [자료구조, 해시]
status: published
---

[[HashMap]]에서 **키-값 쌍을 삭제**하고, 삭제된 값을 반환합니다.

## 시그니처

```java
V remove(Object key)
boolean remove(Object key, Object value)   // 값까지 일치할 때만
```

|반환값|의미|
|---|---|
|값|삭제된 키의 값|
|`null`|키가 존재하지 않았거나, 저장된 값이 null|

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

### 키 존재 → 삭제

```java
Integer removed = map.remove("apple");
// removed = 1000
```

```
[ 변경 후 ]
map: { banana=500, grape=2000 }   ← apple 사라짐
```

### 키 없음 → 변화 없음

```java
Integer removed = map.remove("orange");
// removed = null
```

```
[ 변경 후 ]
map: { banana=500, grape=2000 }   ← 변화 없음
```

### 값까지 일치할 때만 삭제

```java
boolean ok = map.remove("banana", 500);
// ok = true → 삭제됨
```

```
[ 변경 후 ]
map: { grape=2000 }
```

```java
boolean ok = map.remove("grape", 999);
// ok = false → 값 불일치
```

```
[ 변경 후 ]
map: { grape=2000 }   ← 변화 없음 (값 999가 아니라서)
```

## 자주 쓰는 패턴

### 카운트 차감 후 0 되면 삭제

```java
Map<String, Integer> map = new HashMap<>();
map.put("apple", 2);
map.put("banana", 1);
```

```
[ 초기 상태 ]
map: { apple=2, banana=1 }
```

```java
String[] consumed = {"apple", "banana", "apple"};

for (String key : consumed) {
    int count = map.get(key);
    if (count == 1) {
        map.remove(key);
    } else {
        map.put(key, count - 1);
    }
}
```

```
[ 단계별 추적 ]

"apple" 처리:
  count = 2 → put("apple", 1)
       { apple=1, banana=1 }

"banana" 처리:
  count = 1 → remove("banana")
       { apple=1 }

"apple" 처리:
  count = 1 → remove("apple")
       { }
```

### 순회 중 안전한 삭제

```java
// X for-each 중 map.remove() → ConcurrentModificationException
for (String key : map.keySet()) {
    if (조건) map.remove(key);   // 예외 발생
}

// O Iterator의 remove()
Iterator<Map.Entry<String, Integer>> it = map.entrySet().iterator();
while (it.hasNext()) {
    Map.Entry<String, Integer> e = it.next();
    if (e.getValue() == 0) it.remove();
}

// O Java 8+ removeIf — 가장 깔끔
map.entrySet().removeIf(e -> e.getValue() == 0);
```

```
[ removeIf 동작 추적 ]

[ 초기 ]
map: { apple=1, banana=0, grape=2, orange=0 }

map.entrySet().removeIf(e -> e.getValue() == 0);

[ 변경 후 ]
map: { apple=1, grape=2 }   ← 0인 항목들 일괄 삭제
```

## 시간복잡도

|평균|최악|
|---|---|
|O(1)|O(n) / O(log n) (Java 8+ 트리화)|
