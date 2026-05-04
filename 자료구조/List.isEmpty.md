[[List]]가 **비어있는지** 확인합니다.

## 시그니처

```java
boolean isEmpty()
```

|반환값|의미|
|---|---|
|`true`|원소가 하나도 없음 (size == 0)|
|`false`|원소가 1개 이상 있음|

## 동작 추적

```java
List<Integer> list = new ArrayList<>();
```

```
[ 초기 상태 ]
list: []

list.isEmpty();   // true
```

```java
list.add(10);
```

```
[ 변경 후 ]
list: [10]

list.isEmpty();   // false
```

```java
list.remove(0);
```

```
[ 변경 후 ]
list: []

list.isEmpty();   // true
```

## size() == 0 vs isEmpty()

```java
// 둘 다 동일한 결과지만:

if (list.size() == 0) { ... }   // ❌ 의도가 덜 명확
if (list.isEmpty())   { ... }   // ✅ 권장
```

> `Collection` 인터페이스의 모든 컬렉션(List, Set, Map, Queue)이 `isEmpty()`를 제공. 일관성을 위해 `isEmpty()` 사용 권장.

## 자주 쓰는 패턴

### 결과 처리

```java
List<String> errors = validate(input);
if (!errors.isEmpty()) {
    // 에러가 있으면 처리
    throw new ValidationException(errors);
}
```

### 큐/스택 처리

```java
List<Integer> queue = new ArrayList<>();
queue.add(start);

while (!queue.isEmpty()) {
    int cur = queue.remove(0);
    // ...
}
```

> 실제 BFS/DFS에서는 [[ArrayDeque]]를 쓰는 게 빠름 — `remove(0)`은 O(n)이라 느림.

## 시간복잡도

|연산|복잡도|
|---|---|
|`isEmpty()`|O(1)|
