키-값 쌍을 [[HashMap]]에 **저장**합니다. 키가 이미 있으면 값을 **덮어쓰고**, 덮어쓰기 전 값을 반환합니다.

## 시그니처

```java
V put(K key, V value)
```

|반환값|의미|
|---|---|
|이전 값|키가 이미 존재했으면 덮어쓰기 전 값|
|`null`|키가 없었거나, 이전 값이 `null`이었음|

## 동작 추적

```java
Map<String, Integer> map = new HashMap<>();
```

```
[ 초기 상태 ]
map: { }
```

### 새로운 키 저장

```java
Integer prev = map.put("apple", 1000);
```

```
[ 동작 ]
"apple"이라는 키가 없음 → 새로 저장
prev = null  (이전 값 없음)

[ 변경 후 ]
map: { apple=1000 }
```

### 같은 키에 다른 값 저장 (덮어쓰기)

```java
Integer prev = map.put("apple", 2000);
```

```
[ 동작 ]
"apple"이라는 키가 이미 있음 → 값 1000을 2000으로 덮어씀
prev = 1000  (이전 값)

[ 변경 후 ]
map: { apple=2000 }   ← 1000은 사라짐
```

### 다른 키 추가

```java
map.put("banana", 500);
map.put("grape", 3000);
```

```
[ 변경 후 ]
map: { apple=2000, banana=500, grape=3000 }
```

> 순서는 보장되지 않음. 출력 순서는 해시 함수 결과에 따라 달라질 수 있습니다.

## 자주 쓰는 패턴

### 카운팅 (등장 횟수 누적)

```java
String[] participant = {"mislav", "stanko", "mislav", "ana"};

Map<String, Integer> map = new HashMap<>();
for (String name : participant) {
    map.put(name, map.getOrDefault(name, 0) + 1);
}
```

```
[ 단계별 상태 ]

초기:                   { }

"mislav" 처리:
  getOrDefault → 0
  put("mislav", 0+1)    { mislav=1 }

"stanko" 처리:
  getOrDefault → 0
  put("stanko", 0+1)    { mislav=1, stanko=1 }

"mislav" 처리 (두 번째):
  getOrDefault → 1
  put("mislav", 1+1)    { mislav=2, stanko=1 }

"ana" 처리:
  getOrDefault → 0
  put("ana", 0+1)       { mislav=2, stanko=1, ana=1 }
```

### 차감

```java
String[] completion = {"stanko", "ana", "mislav"};

for (String name : completion) {
    map.put(name, map.get(name) - 1);
}
```

```
[ 단계별 상태 ]

시작:                   { mislav=2, stanko=1, ana=1 }

"stanko":
  get("stanko") = 1
  put("stanko", 0)      { mislav=2, stanko=0, ana=1 }

"ana":
  get("ana") = 1
  put("ana", 0)         { mislav=2, stanko=0, ana=0 }

"mislav":
  get("mislav") = 2
  put("mislav", 1)      { mislav=1, stanko=0, ana=0 }

→ "mislav"가 1로 남음 = 완주하지 못한 선수
```

## 주의사항

```
put은 항상 덮어쓴다:
map.put("apple", 1000);
map.put("apple", 999);   // ← 이전 값 1000은 사라짐

→ 기존 값을 보존하려면 [[HashMap.putIfAbsent]] 사용
```

## 시간복잡도

|평균|최악|
|---|---|
|O(1)|O(n) (충돌 많을 때) / O(log n) (Java 8+ 트리화)|
