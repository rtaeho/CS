[[Set]]에서 **원소를 삭제**하고, 삭제 여부를 boolean으로 반환합니다.

## 시그니처

```java
boolean remove(Object o)
```

|반환값|의미|
|---|---|
|`true`|원소가 있어서 삭제됨|
|`false`|원소가 없어서 변화 없음|

## 동작 추적

```java
Set<String> set = new HashSet<>();
set.add("apple");
set.add("banana");
set.add("grape");
```

```
[ 초기 상태 ]
set: [apple, banana, grape]
```

### 존재하는 원소 삭제

```java
boolean removed = set.remove("apple");
// removed = true
```

```
[ 변경 후 ]
set: [banana, grape]
```

### 없는 원소 삭제 시도

```java
boolean removed = set.remove("orange");
// removed = false
```

```
[ 변경 후 ]
set: [banana, grape]   ← 변화 없음
```

## 자주 쓰는 패턴

### 처리한 항목 제거 (방문 처리)

```java
Set<Integer> remaining = new HashSet<>(Arrays.asList(1, 2, 3, 4, 5));
```

```
[ 초기 상태 ]
remaining: [1, 2, 3, 4, 5]
```

```java
int[] processed = {2, 4};
for (int n : processed) {
    remaining.remove(n);
}
```

```
[ 단계별 추적 ]

remove(2) → true   →  remaining: [1, 3, 4, 5]
remove(4) → true   →  remaining: [1, 3, 5]
```

### 순회 중 안전한 삭제

```java
// X for-each 중 set.remove → ConcurrentModificationException
for (String s : set) {
    if (조건) set.remove(s);   // 예외 발생
}

// O Iterator의 remove()
Iterator<String> it = set.iterator();
while (it.hasNext()) {
    String s = it.next();
    if (조건) it.remove();
}

// O Java 8+ removeIf — 가장 깔끔
set.removeIf(s -> 조건);
```

```
[ removeIf 동작 추적 ]

[ 초기 ]
set: [apple, banana, cherry, durian]

set.removeIf(s -> s.startsWith("c"));

[ 변경 후 ]
set: [apple, banana, durian]   ← cherry 일괄 삭제
```

### clear() — 전체 삭제

```java
set.clear();
```

```
[ 변경 후 ]
set: [ ]   ← 모든 원소 삭제
```

## 시간복잡도

|평균|최악|
|---|---|
|O(1)|O(n) / O(log n) (Java 8+ 트리화)|
