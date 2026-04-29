[[HashMap]]에서 키에 대해 **현재 값을 받아 새 값을 계산**하는 메서드들. `compute`, `computeIfAbsent`, `computeIfPresent` 세 가지가 있습니다.

## 시그니처

```java
V compute(K key, BiFunction<K, V, V> remappingFunction)
V computeIfAbsent(K key, Function<K, V> mappingFunction)        // 키 없을 때만
V computeIfPresent(K key, BiFunction<K, V, V> remappingFunction)  // 키 있을 때만
```

## 세 메서드 차이

|메서드|키 있음|키 없음|함수 → null|
|---|---|---|---|
|`compute`|함수 실행 → 갱신|`null`을 받아 함수 실행|키 삭제|
|`computeIfAbsent`|아무 동작 X|함수 실행 → 저장|저장 안 함|
|`computeIfPresent`|함수 실행 → 갱신|아무 동작 X|키 삭제|

## 동작 추적: compute

```java
Map<String, Integer> map = new HashMap<>();
map.put("apple", 100);
```

```
[ 초기 상태 ]
map: { apple=100 }
```

### 키 있음

```java
map.compute("apple", (k, v) -> v + 50);
```

```
[ 동작 ]
v = 100 → 함수 실행: 100 + 50 = 150

[ 변경 후 ]
map: { apple=150 }
```

### 키 없음

```java
map.compute("banana", (k, v) -> (v == null ? 0 : v) + 1);
```

```
[ 동작 ]
v = null (키 없음) → 함수 실행: 0 + 1 = 1

[ 변경 후 ]
map: { apple=150, banana=1 }
```

## 동작 추적: computeIfAbsent — 가장 자주 쓰임

```java
Map<String, List<Integer>> grouped = new HashMap<>();
```

```
[ 초기 상태 ]
grouped: { }
```

### 키 없음 → 람다 실행해서 저장

```java
grouped.computeIfAbsent("even", k -> new ArrayList<>()).add(2);
```

```
[ 동작 ]
"even" 없음 → new ArrayList<>() 실행 → 빈 리스트 저장
반환된 리스트에 2 추가

[ 변경 후 ]
grouped: { even=[2] }
```

### 키 있음 → 람다 실행 안 함

```java
grouped.computeIfAbsent("even", k -> new ArrayList<>()).add(4);
```

```
[ 동작 ]
"even" 이미 있음 → new ArrayList<>() 실행 안 함 (객체 생성 X)
기존 리스트 [2]에 4 추가

[ 변경 후 ]
grouped: { even=[2, 4] }
```

> [[HashMap.putIfAbsent]]와 비교:
> - putIfAbsent는 매번 객체 생성 → 키 있으면 버려짐 (낭비)
> - computeIfAbsent는 없을 때만 람다 실행 → 효율적

```java
// ❌ putIfAbsent — 매번 ArrayList 객체 생성
map.putIfAbsent(key, new ArrayList<>());
map.get(key).add(item);

// ✅ computeIfAbsent — 없을 때만 생성 + 그 값 바로 반환
map.computeIfAbsent(key, k -> new ArrayList<>()).add(item);
```

## 동작 추적: computeIfPresent

```java
Map<String, Integer> map = new HashMap<>();
map.put("apple", 1);
```

```
[ 초기 상태 ]
map: { apple=1 }
```

### 키 있음 → 함수 실행

```java
map.computeIfPresent("apple", (k, v) -> v - 1);
```

```
[ 동작 ]
v = 1 → 함수 실행: 1 - 1 = 0

[ 변경 후 ]
map: { apple=0 }
```

### 0이 되면 삭제

```java
map.computeIfPresent("apple", (k, v) -> {
    int newVal = v - 1;
    return newVal < 0 ? null : newVal;
});
```

```
[ 동작 ]
v = 0 → 함수 실행: -1 < 0 → null 반환 → 삭제

[ 변경 후 ]
map: { }
```

### 키 없음 → 무시

```java
map.computeIfPresent("banana", (k, v) -> v + 1);
```

```
[ 변경 후 ]
map: { }   ← 변화 없음 (banana 키 없으므로 함수 실행 안 함)
```

## 자주 쓰는 패턴

### 그룹핑 — List에 누적 (베스트앨범)

```java
String[] genres = {"classic", "pop", "classic", "classic", "pop"};
int[] plays    = {500, 600, 150, 800, 2500};

Map<String, List<Integer>> playsByGenre = new HashMap<>();
for (int i = 0; i < genres.length; i++) {
    playsByGenre
        .computeIfAbsent(genres[i], k -> new ArrayList<>())
        .add(plays[i]);
}
```

```
[ 단계별 추적 ]

초기:                                       { }

i=0, classic, 500:
  computeIfAbsent → 빈 리스트 생성, [500] 추가
       { classic=[500] }

i=1, pop, 600:
  computeIfAbsent → 빈 리스트 생성, [600] 추가
       { classic=[500], pop=[600] }

i=2, classic, 150:
  computeIfAbsent → 람다 실행 안 함, 기존 리스트에 150 추가
       { classic=[500, 150], pop=[600] }

i=3, classic, 800:
  computeIfAbsent → 800 추가
       { classic=[500, 150, 800], pop=[600] }

i=4, pop, 2500:
  computeIfAbsent → 2500 추가
       { classic=[500, 150, 800], pop=[600, 2500] }
```

### 그룹핑 — Set에 누적

```java
String[] words = {"apple", "ant", "banana", "ant", "apple"};

Map<Integer, Set<String>> bySize = new HashMap<>();
for (String s : words) {
    bySize.computeIfAbsent(s.length(), k -> new HashSet<>()).add(s);
}
```

```
[ 단계별 추적 ]

초기:                              { }

"apple" (5):                       { 5=[apple] }
"ant" (3):                         { 5=[apple], 3=[ant] }
"banana" (6):                      { 5=[apple], 3=[ant], 6=[banana] }
"ant" (3):                         { 5=[apple], 3=[ant], 6=[banana] }   ← Set이라 중복 무시
"apple" (5):                       { 5=[apple], 3=[ant], 6=[banana] }   ← 중복 무시
```

### 메모이제이션 (재귀 + 캐시)

```java
Map<Integer, Long> cache = new HashMap<>();

long fib(int n) {
    if (n < 2) return n;
    return cache.computeIfAbsent(n, k -> fib(k - 1) + fib(k - 2));
}
```

```
[ fib(5) 호출 시 추적 ]

fib(5) → cache 없음 → fib(4) + fib(3) 계산 → 5 저장
  fib(4) → 없음 → fib(3) + fib(2) → 3 저장
    fib(3) → 없음 → fib(2) + fib(1) → 2 저장
      fib(2) → 없음 → fib(1) + fib(0) → 1 저장
    fib(2) → cache hit → 1 (즉시 반환)
  fib(3) → cache hit → 2

cache: { 2=1, 3=2, 4=3, 5=5 }
```

## merge vs compute — 어느 걸 쓸까

```java
// 카운팅 — merge가 더 간결
map.merge(key, 1, Integer::sum);
map.compute(key, (k, v) -> v == null ? 1 : v + 1);

// 컬렉션 누적 — computeIfAbsent가 더 자연스러움
map.computeIfAbsent(key, k -> new ArrayList<>()).add(item);
```

## 시간복잡도

|평균|최악|
|---|---|
|O(1) + 람다 비용|O(n) / O(log n) (Java 8+ 트리화)|
