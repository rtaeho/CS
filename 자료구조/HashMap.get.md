---
title: "HashMap.get"
tags: [해시맵, 해시]
status: published
---

[[HashMap]]에서 **키로 값을 조회**합니다. 키가 없으면 `null`을 반환합니다.

## 시그니처

```java
V get(Object key)
```

|반환값|의미|
|---|---|
|값|키가 존재하는 경우|
|`null`|키가 없거나, 저장된 값이 `null`인 경우|

## 동작 추적

```java
Map<String, Integer> map = new HashMap<>();
map.put("apple", 1000);
map.put("banana", null);
```

```
[ 초기 상태 ]
map: { apple=1000, banana=null }
```

### 존재하는 키

```java
Integer val = map.get("apple");
// val = 1000
```

### 존재하지 않는 키

```java
Integer val = map.get("grape");
// val = null
```

```
[ 변경 후 ]
map: { apple=1000, banana=null }   ← 변화 없음 (조회만)
```

> get은 절대 map을 변경하지 않습니다.

## null 반환의 모호성

```
"banana" 키는 존재하지만 값이 null이고
"grape" 키는 아예 없음.
둘 다 get() 결과가 null이라 구분 불가:

map.get("banana") == null   O true
map.get("grape")  == null   O true
```

```java
// 이 둘을 구분하려면 [[HashMap.containsKey]]
if (map.containsKey("banana")) {
    // 키는 있음 (값이 null일 수 있음)
}

// 또는 기본값 처리는 [[HashMap.getOrDefault]]
int count = map.getOrDefault("apple", 0);
```

## 자주 쓰는 패턴

### 차감 (이미 존재한다고 알 때)

```java
Map<String, Integer> map = new HashMap<>();
map.put("mislav", 2);
map.put("stanko", 1);
```

```
[ 초기 상태 ]
map: { mislav=2, stanko=1 }
```

```java
map.put("mislav", map.get("mislav") - 1);
```

```
[ 동작 ]
get("mislav") = 2
put("mislav", 2 - 1)

[ 변경 후 ]
map: { mislav=1, stanko=1 }
```

### 안전한 조회 (null 체크)

```java
Integer val = map.get(key);
if (val != null) {
    // 사용
} else {
    // 키가 없거나 값이 null
}

// 단순히 기본값이 필요하면 [[HashMap.getOrDefault]] 한 줄 처리
int val = map.getOrDefault(key, 0);
```

## 주의: 자동 언박싱과 NullPointerException

```java
Map<String, Integer> map = new HashMap<>();

// X 위험 — 키가 없으면 null이 int로 언박싱되며 NPE
int val = map.get("notExist");   // NullPointerException

// O 안전 — Integer로 받아 null 체크
Integer val = map.get("notExist");
if (val != null) { ... }

// O 안전 — getOrDefault
int val = map.getOrDefault("notExist", 0);
```

## 시간복잡도

|평균|최악|
|---|---|
|O(1)|O(n) / O(log n) (Java 8+ 트리화)|
