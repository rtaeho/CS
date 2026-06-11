[[Queue]]의 **front(앞) 원소를 제거하고 반환**합니다 (dequeue). 같은 역할의 메서드로 `remove`가 있으며, **빈 큐에서 동작이 다릅니다**.

## 시그니처

```java
E poll()       // 빈 큐면 null 반환
E remove()     // 빈 큐면 NoSuchElementException
```

|메서드|성공|실패 (큐가 빔)|
|---|---|---|
|`poll()`|front 원소 반환|`null` 반환|
|`remove()`|front 원소 반환|`NoSuchElementException`|

> `poll`은 **null로 조용히 실패**, `remove`는 **예외로 명시적 실패**.

## 동작 추적

```java
Queue<Integer> q = new LinkedList<>();
q.add(10); q.add(20); q.add(30);
```

```
[ 초기 상태 ]
q: front → [10, 20, 30] ← rear
```

```java
int x = q.poll();   // 10 반환
```

```
[ 변경 후 ]
q: front → [20, 30] ← rear
x = 10

→ front 원소가 빠지고 그 다음이 새 front가 됨
```

```java
int y = q.poll();   // 20
int z = q.poll();   // 30
int w = q.poll();   // null (빈 큐)
```

```
[ 빈 큐에서 ]
q: front → [] ← rear

q.poll()    → null     (조용한 실패)
q.remove()  → NoSuchElementException
```

## poll vs remove 선택 기준

```java
// while 루프에서 큐를 비우는 표준 패턴
while (!queue.isEmpty()) {
    int x = queue.poll();   // O 안전 — null 안 나옴 (isEmpty 체크했으므로)
    process(x);
}

// 빈 큐 검사 없이 한 번만 꺼낼 때
Integer x = queue.poll();
if (x == null) {
    // 빈 큐 처리
}

// 빈 큐가 절대 안 와야 한다는 보증
int x = queue.remove();   // 빈 큐면 즉시 예외 → 버그 조기 발견
```

> 코딩테스트에서는 `poll`이 일반적. `isEmpty()`로 미리 체크하는 패턴이 표준.

## 자주 쓰는 패턴

### BFS — 큐가 빌 때까지 처리

```java
Queue<Integer> queue = new LinkedList<>();
queue.add(start);

while (!queue.isEmpty()) {
    int cur = queue.poll();   // front 꺼냄
    for (int next : graph[cur]) {
        if (!visited[next]) {
            visited[next] = true;
            queue.add(next);
        }
    }
}
```

### 그룹화 / 묶기 (기능개발 패턴)

```java
while (!q.isEmpty()) {
    int now = q.poll();      // 기준 원소
    int cnt = 1;

    while (!q.isEmpty() && q.peek() <= now) {
        q.poll();             // 같은 그룹이면 함께 제거
        cnt++;
    }
    list.add(cnt);
}
```

```
[ 추적 ]
q: [7, 3, 9]   (예시)

iter1:
  now = q.poll() = 7        → q: [3, 9]
  q.peek()=3 ≤ 7? yes → q.poll(), cnt=2  → q: [9]
  q.peek()=9 ≤ 7? no  → break
  list.add(2)               → list: [2]

iter2:
  now = q.poll() = 9        → q: []
  isEmpty → break
  list.add(1)               → list: [2, 1]
```

### 레벨 순회

```java
while (!queue.isEmpty()) {
    int size = queue.size();
    for (int i = 0; i < size; i++) {
        Node node = queue.poll();   // 현재 레벨 노드들 처리
        // ...
        if (node.left  != null) queue.add(node.left);
        if (node.right != null) queue.add(node.right);
    }
}
```

## Integer 언박싱 주의

```java
Queue<Integer> q = new LinkedList<>();

// 빈 큐에서 poll → null
int x = q.poll();        // X NullPointerException (null → int 언박싱 실패)

Integer x = q.poll();    // O Integer로 받으면 null 허용
```

## 시간복잡도

|구현체|`poll` / `remove`|
|---|---|
|`LinkedList`|O(1)|
|`ArrayDeque`|O(1)|
|`PriorityQueue`|O(log n) — 힙 재구성|
|`ArrayBlockingQueue`|O(1)|

## 핵심 정리

`poll`은 큐의 front 원소를 제거하고 반환하는 표준 dequeue 연산이며, `remove`와 달리 빈 큐에서 **null을 반환**해 안전합니다. BFS, 레벨 순회, 그룹 묶기 등에서 `while(!q.isEmpty()) { q.poll(); ... }` 패턴이 가장 자주 쓰이고, 빈 큐가 보장되지 않는 상황에서는 `Integer`로 받아 NPE를 피해야 합니다.
