[[HashMap]]에 저장된 **모든 키-값 쌍을 `Set<Map.Entry>` 형태로 반환**합니다. **키·값을 둘 다 쓸 때 가장 효율적인 순회 방법**입니다.

## 시그니처

```java
Set<Map.Entry<K, V>> entrySet()
```

반환되는 Set은 **HashMap의 뷰(view)** 입니다.

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
for (Map.Entry<String, Integer> e : map.entrySet()) {
    String key = e.getKey();
    int value = e.getValue();
    System.out.println(key + " = " + value);
}
```

```
[ 출력 ]
apple = 1000
banana = 500
grape = 2000
```

```
[ 변경 후 ]
map: { apple=1000, banana=500, grape=2000 }   ← 변화 없음
```

## 왜 entrySet인가? — 성능 차이

```java
// ❌ keySet + get — 매번 해시 조회 한 번 더 발생
for (String key : map.keySet()) {
    int value = map.get(key);   // 또 한 번의 해시 조회
}
```

```
[ 동작 ]
- keySet() 순회: n번
- 각 반복마다 map.get() 호출: 해시 조회 n번
→ 총 2n번의 해시 작업
```

```java
// ✅ entrySet — 한 번에 키·값 모두 가져옴
for (Map.Entry<String, Integer> e : map.entrySet()) {
    int value = e.getValue();   // 추가 해시 조회 없음
}
```

```
[ 동작 ]
- entrySet() 순회: n번
- 각 반복에서 entry로부터 직접 값 추출
→ 총 n번의 해시 작업
```

> 데이터가 많을수록 차이가 커집니다. 키와 값을 둘 다 쓸 거라면 **무조건 entrySet**.

## 자주 쓰는 패턴

### 조건에 맞는 엔트리 찾기 (베스트앨범)

```java
Map<String, Integer> genrePlayCount = new HashMap<>();
genrePlayCount.put("classic", 1450);
genrePlayCount.put("pop", 3100);
genrePlayCount.put("rock", 800);
```

```
[ 초기 상태 ]
genrePlayCount: { classic=1450, pop=3100, rock=800 }
```

```java
// 재생수 1000 이상 장르
for (Map.Entry<String, Integer> e : genrePlayCount.entrySet()) {
    if (e.getValue() >= 1000) {
        System.out.println(e.getKey());   // classic, pop
    }
}
```

### 값 기준 정렬

```java
List<Map.Entry<String, Integer>> list = new ArrayList<>(genrePlayCount.entrySet());
list.sort((a, b) -> b.getValue() - a.getValue());
```

```
[ 정렬 후 ]
list: [(pop, 3100), (classic, 1450), (rock, 800)]   ← 재생수 내림차순
```

```java
// Stream
genrePlayCount.entrySet().stream()
    .sorted(Map.Entry.<String, Integer>comparingByValue().reversed())
    .forEach(e -> System.out.println(e.getKey()));
// pop, classic, rock
```

### 키 기준 정렬

```java
Map<String, Integer> map = new HashMap<>();
map.put("banana", 500);
map.put("apple", 1000);
map.put("grape", 2000);
```

```
[ 초기 상태 ]
map: { banana=500, apple=1000, grape=2000 }   ← 순서 보장 X
```

```java
List<Map.Entry<String, Integer>> list = new ArrayList<>(map.entrySet());
list.sort(Map.Entry.comparingByKey());        // 오름차순
```

```
[ 정렬 후 ]
list: [(apple, 1000), (banana, 500), (grape, 2000)]   ← 사전순
```

```java
// 내림차순
list.sort(Map.Entry.<String, Integer>comparingByKey().reversed());
```

```
[ 정렬 후 ]
list: [(grape, 2000), (banana, 500), (apple, 1000)]
```

```java
// 람다 직접 작성
list.sort((a, b) -> a.getKey().compareTo(b.getKey()));         // 오름차순
list.sort((a, b) -> b.getKey().compareTo(a.getKey()));         // 내림차순
```

### 다중 기준 정렬 (값 우선, 같으면 키)

> Comparator 체이닝, 람다 vs 메서드 레퍼런스, 함정(int 오버플로 등)은 정렬 노트에서 별도로 다룰 예정.

```java
list.sort(
    Map.Entry.<String, Integer>comparingByValue().reversed()
        .thenComparing(Map.Entry.comparingByKey())
);
```

```
[ 베스트앨범 시나리오 — 재생수 내림차순, 같으면 곡명 사전순 ]

입력: { song1=500, song2=500, song3=1000 }
정렬: [(song3, 1000), (song1, 500), (song2, 500)]
                              ↑ 값 같으면 키 사전순
```

### TreeMap으로 자동 정렬 유지

```java
// 항상 키 기준 정렬된 상태로 유지하고 싶다면
Map<String, Integer> map = new TreeMap<>();
map.put("banana", 500);
map.put("apple", 1000);
map.put("grape", 2000);
```

```
[ 상태 (TreeMap은 항상 키 정렬) ]
map: { apple=1000, banana=500, grape=2000 }   ← 자동 사전순

// 순회 시 정렬된 순서로
for (Map.Entry<String, Integer> e : map.entrySet()) {
    // apple → banana → grape
}
```

> 정렬된 순회가 잦다면 매번 List에 담아 정렬하기보다 TreeMap이 효율적. 단, 모든 연산이 O(log n)이라 HashMap의 O(1)보다 느림.

### 엔트리 직접 수정

```java
Map<String, Integer> map = new HashMap<>();
map.put("a", 1);
map.put("b", 2);
map.put("c", 3);
```

```
[ 초기 상태 ]
map: { a=1, b=2, c=3 }
```

```java
for (Map.Entry<String, Integer> e : map.entrySet()) {
    e.setValue(e.getValue() * 2);
}
```

```
[ 변경 후 ]
map: { a=2, b=4, c=6 }   ← setValue가 원본에 반영됨
```

> `Map.Entry.setValue()`는 원본 map에 직접 반영. 이건 안전한 변경(키는 그대로) — 키 변경(remove/put)은 ConcurrentModificationException 발생.

### 조건부 일괄 삭제 (Java 8+)

```java
Map<String, Integer> map = new HashMap<>();
map.put("apple", 1);
map.put("banana", 0);
map.put("grape", 2);
map.put("orange", 0);
```

```
[ 초기 상태 ]
map: { apple=1, banana=0, grape=2, orange=0 }
```

```java
map.entrySet().removeIf(e -> e.getValue() == 0);
```

```
[ 변경 후 ]
map: { apple=1, grape=2 }   ← 0인 항목 일괄 삭제
```

## Java 8+ forEach

```java
map.forEach((key, value) -> {
    System.out.println(key + " = " + value);
});
```

> `forEach`는 entrySet 순회와 동일한 효율. 더 간결.

## keySet() vs entrySet() vs values()

|메서드|반환|언제 쓰는가|
|---|---|---|
|[[HashMap.keySet]]|`Set<K>`|키만 필요할 때|
|[[HashMap.values]]|`Collection<V>`|값만 필요할 때|
|`entrySet()`|`Set<Map.Entry<K,V>>`|키·값 모두 필요할 때 (가장 효율적)|

## 시간복잡도

|연산|복잡도|
|---|---|
|`entrySet()` 호출|O(1) (뷰 반환)|
|순회|O(n)|
