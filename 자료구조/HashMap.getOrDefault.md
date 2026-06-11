[[HashMap]]에서 키로 값을 조회하되, **키가 없으면 지정한 기본값을 반환**합니다. 기본값을 반환할 뿐 **HashMap 자체는 변경되지 않습니다**.

## 시그니처

```java
V getOrDefault(Object key, V defaultValue)
```

|상황|반환값|map 변경|
|---|---|---|
|키 존재|저장된 값|X|
|키 없음|`defaultValue`|X (저장하지 않음)|

## 동작 추적

```java
Map<String, Integer> map = new HashMap<>();
map.put("apple", 1000);
```

```
[ 초기 상태 ]
map: { apple=1000 }
```

### 존재하는 키

```java
int val = map.getOrDefault("apple", 0);
// val = 1000
```

```
[ 변경 후 ]
map: { apple=1000 }   ← 변화 없음
```

### 존재하지 않는 키

```java
int val = map.getOrDefault("banana", 0);
// val = 0
```

```
[ 변경 후 ]
map: { apple=1000 }   ← 변화 없음 (banana는 저장 안 됨)
```

> 자주 헷갈림: `getOrDefault`는 **반환만** 함. 기본값으로 저장하려면 [[HashMap.putIfAbsent]].

## get() vs getOrDefault() — 코드 비교

```java
// 기존 방식 — null 체크 필요
Integer count = map.get(key);
if (count == null) count = 0;
map.put(key, count + 1);

// getOrDefault — 한 줄
map.put(key, map.getOrDefault(key, 0) + 1);
```

## 자주 쓰는 패턴

### 카운팅 (등장 횟수 세기)

```java
String[] participant = {"mislav", "stanko", "mislav", "ana"};

Map<String, Integer> map = new HashMap<>();
for (String name : participant) {
    map.put(name, map.getOrDefault(name, 0) + 1);
}
```

```
[ 단계별 추적 ]

초기:  { }

"mislav":
  getOrDefault("mislav", 0) = 0   ← 키 없음 → 0 반환
  put("mislav", 0 + 1)
       { mislav=1 }

"stanko":
  getOrDefault("stanko", 0) = 0
  put("stanko", 0 + 1)
       { mislav=1, stanko=1 }

"mislav" (재등장):
  getOrDefault("mislav", 0) = 1   ← 키 있음 → 1 반환
  put("mislav", 1 + 1)
       { mislav=2, stanko=1 }

"ana":
  getOrDefault("ana", 0) = 0
  put("ana", 0 + 1)
       { mislav=2, stanko=1, ana=1 }
```

> 프로그래머스 **해시 카테고리**의 거의 모든 문제(완주하지 못한 선수, 전화번호 목록, 위장 등)에서 사용되는 기본 패턴입니다.

### 그룹별 개수 세기

```java
String[][] clothes = {
    {"yellow_hat", "headgear"},
    {"blue_sunglasses", "eyewear"},
    {"green_turban", "headgear"}
};

Map<String, Integer> map = new HashMap<>();
for (String[] cloth : clothes) {
    String type = cloth[1];
    map.put(type, map.getOrDefault(type, 0) + 1);
}
```

```
[ 단계별 추적 ]

초기:  { }

"headgear":
  getOrDefault → 0
  put("headgear", 1)
       { headgear=1 }

"eyewear":
  getOrDefault → 0
  put("eyewear", 1)
       { headgear=1, eyewear=1 }

"headgear" (재등장):
  getOrDefault → 1
  put("headgear", 2)
       { headgear=2, eyewear=1 }
```

## 동등한 표현 비교

```java
// 같은 카운팅 동작을 표현하는 4가지 방법

// 1. containsKey + get + put (가장 장황)
if (map.containsKey(key)) {
    map.put(key, map.get(key) + 1);
} else {
    map.put(key, 1);
}

// 2. getOrDefault — 한 줄
map.put(key, map.getOrDefault(key, 0) + 1);

// 3. [[HashMap.merge]] — 더 간결
map.merge(key, 1, Integer::sum);

// 4. [[HashMap.compute]] — 람다로 직접 계산
map.compute(key, (k, v) -> v == null ? 1 : v + 1);
```

## 시간복잡도

|평균|최악|
|---|---|
|O(1)|O(n) / O(log n) (Java 8+ 트리화)|
