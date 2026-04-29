[[HashMap]]에 **키가 없을 때만 저장**하고, 이미 있으면 기존 값을 유지합니다.

## 시그니처

```java
V putIfAbsent(K key, V value)
```

|상황|동작|반환값|
|---|---|---|
|키 없음|`value` 저장|`null`|
|키 있음|덮어쓰지 않음|기존 값|

## 동작 추적

```java
Map<String, Integer> map = new HashMap<>();
```

```
[ 초기 상태 ]
map: { }
```

### 첫 저장

```java
Integer prev = map.putIfAbsent("apple", 1000);
// prev = null   (키 없었음 → 저장됨)
```

```
[ 변경 후 ]
map: { apple=1000 }
```

### 이미 존재 → 무시

```java
Integer prev = map.putIfAbsent("apple", 9999);
// prev = 1000   (이미 있음 → 무시, 기존 값 반환)
```

```
[ 변경 후 ]
map: { apple=1000 }   ← 9999는 저장 안 됨
```

## put() vs putIfAbsent() 비교

```java
Map<String, Integer> map = new HashMap<>();
map.put("apple", 1000);
```

```
[ 초기 상태 ]
map: { apple=1000 }
```

```java
// put — 항상 덮어씀
map.put("apple", 9999);
```

```
[ put 후 ]
map: { apple=9999 }   ← 1000 사라짐
```

```java
// putIfAbsent — 이미 있으면 무시
map.putIfAbsent("apple", 9999);
```

```
[ putIfAbsent 후 ]
map: { apple=1000 }   ← 1000 유지
```

## 자주 쓰는 패턴

### 첫 등장 인덱스만 기록

```java
String[] arr = {"a", "b", "a", "c", "b"};

Map<String, Integer> firstIndex = new HashMap<>();
for (int i = 0; i < arr.length; i++) {
    firstIndex.putIfAbsent(arr[i], i);
}
```

```
[ 단계별 추적 ]

i=0, "a":
  putIfAbsent("a", 0) → 키 없음 → 저장
       { a=0 }

i=1, "b":
  putIfAbsent("b", 1) → 키 없음 → 저장
       { a=0, b=1 }

i=2, "a" (재등장):
  putIfAbsent("a", 2) → 키 있음 → 무시
       { a=0, b=1 }

i=3, "c":
  putIfAbsent("c", 3) → 키 없음 → 저장
       { a=0, b=1, c=3 }

i=4, "b" (재등장):
  putIfAbsent("b", 4) → 키 있음 → 무시
       { a=0, b=1, c=3 }
```

### 기본값 초기화

```java
// containsKey 체크 + put 패턴을 한 줄로
if (!map.containsKey(key)) {
    map.put(key, new ArrayList<>());
}

// → putIfAbsent 한 줄
map.putIfAbsent(key, new ArrayList<>());
```

## 주의: putIfAbsent의 객체 생성 낭비

```java
// ❌ 매번 ArrayList 객체를 생성하지만, 키가 있으면 버려짐 (GC 부담)
map.putIfAbsent(key, new ArrayList<>());

// ✅ [[HashMap.compute]]의 computeIfAbsent — 없을 때만 람다 실행
map.computeIfAbsent(key, k -> new ArrayList<>()).add(item);
```

```
[ 차이 추적 ]

map: { a=[1,2] }

[ putIfAbsent ]
new ArrayList<>() 생성 ← 매번 생성됨
putIfAbsent("a", 새 리스트)
  → 키 "a" 이미 있음 → 새 리스트 버려짐 (GC 대상)
map: { a=[1,2] }

[ computeIfAbsent ]
키 "a" 있음 → 람다 실행 안 함 → 객체 생성 X
map: { a=[1,2] }
```

## 시간복잡도

|평균|최악|
|---|---|
|O(1)|O(n) / O(log n) (Java 8+ 트리화)|
