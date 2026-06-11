---
title: "HashMap.containsKey"
tags: [해시맵, 해시]
status: published
---

[[HashMap]]에 **특정 키가 존재하는지** 확인합니다. 값이 `null`이어도 키만 있으면 `true`.

## 시그니처

```java
boolean containsKey(Object key)
```

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

### 존재 확인

```java
map.containsKey("apple");    // true
map.containsKey("banana");   // true ← 값이 null이어도 키는 존재
map.containsKey("grape");    // false
```

```
[ 변경 후 ]
map: { apple=1000, banana=null }   ← 변화 없음
```

## 왜 필요한가? — get()의 한계

```
[[HashMap.get]]은 두 경우를 구분하지 못함:
  1. 키가 아예 없음
  2. 키는 있지만 값이 null

map.get("banana") → null
map.get("grape")  → null
                    ↑ 둘 다 같은 결과
```

```java
// containsKey는 "키 자체"의 존재 여부만 정확히 확인
map.containsKey("banana")  // true  ← 키 있음
map.containsKey("grape")   // false ← 키 없음
```

## 자주 쓰는 패턴

### 중복 검사 (전화번호 목록)

```java
String[] phoneBook = {"119", "97674223", "1195524421"};

Map<String, Boolean> map = new HashMap<>();
for (String phone : phoneBook) {
    map.put(phone, true);
}
```

```
[ 초기 상태 ]
map: { 119=true, 97674223=true, 1195524421=true }
```

```java
// "119"가 다른 번호의 접두사인지 검사
for (String phone : phoneBook) {
    for (int i = 1; i < phone.length(); i++) {
        String prefix = phone.substring(0, i);
        if (map.containsKey(prefix)) {
            return false;
        }
    }
}
```

```
[ 단계별 추적 ]

phone = "97674223" 검사:
  prefix="9"        → containsKey? false
  prefix="97"       → containsKey? false
  prefix="976"      → containsKey? false
  ...
  → 통과

phone = "1195524421" 검사:
  prefix="1"        → containsKey? false
  prefix="11"       → containsKey? false
  prefix="119"      → containsKey? true   ← 119가 접두사!
  → return false
```

### 키 존재 시에만 처리

```java
Map<String, Integer> stock = new HashMap<>();
stock.put("apple", 5);
stock.put("banana", 3);

// 재고에 있는 상품만 처리
String item = "apple";
if (stock.containsKey(item)) {
    int count = stock.get(item);
    System.out.println(item + ": " + count + "개");
}
```

## 대안: getOrDefault / putIfAbsent

```java
// containsKey + get 패턴
if (map.containsKey(key)) {
    return map.get(key);
}
return 0;

// → [[HashMap.getOrDefault]] 한 줄
return map.getOrDefault(key, 0);

// containsKey + put 패턴
if (!map.containsKey(key)) {
    map.put(key, 0);
}

// → [[HashMap.putIfAbsent]] 한 줄
map.putIfAbsent(key, 0);
```

## 시간복잡도

|평균|최악|
|---|---|
|O(1)|O(n) / O(log n) (Java 8+ 트리화)|
