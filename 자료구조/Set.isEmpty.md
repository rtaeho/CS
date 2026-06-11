[[Set]]이 **비어있는지** 확인합니다.

## 시그니처

```java
boolean isEmpty()
```

|반환값|의미|
|---|---|
|`true`|원소가 하나도 없음|
|`false`|원소가 1개 이상 있음|

## 동작 추적

```java
Set<Integer> set = new HashSet<>();
```

```
[ 초기 상태 ]
set: [ ]

set.isEmpty();   // true
```

```java
set.add(1);
```

```
[ 변경 후 ]
set: [1]

set.isEmpty();   // false
```

```java
set.remove(1);
```

```
[ 변경 후 ]
set: [ ]

set.isEmpty();   // true
```

## size() == 0 vs isEmpty()

```java
// 둘 다 동일한 결과지만:

if (set.size() == 0) { ... }   // X 의도가 덜 명확
if (set.isEmpty())   { ... }   // O 권장
```

> 모든 컬렉션 인터페이스(List, Set, Map)가 `isEmpty()`를 제공. 동일한 컨벤션이라 일관성 측면에서도 권장됨.

## 자주 쓰는 패턴

### BFS / DFS의 종료 조건

```java
Set<Integer> visited = new HashSet<>();
Queue<Integer> queue = new LinkedList<>();
queue.add(start);

while (!queue.isEmpty()) {   // 큐가 비면 종료
    int cur = queue.poll();
    if (visited.contains(cur)) continue;
    visited.add(cur);
    // ...
}
```

### 작업 큐 처리

```java
Set<String> tasks = new HashSet<>(initialTasks);

while (!tasks.isEmpty()) {
    String task = tasks.iterator().next();
    process(task);
    tasks.remove(task);
}
```

## 시간복잡도

|연산|복잡도|
|---|---|
|`isEmpty()`|O(1)|
