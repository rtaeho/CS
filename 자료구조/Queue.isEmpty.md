---
title: "Queue.isEmpty"
tags: [큐, BFS]
status: published
---

[[Queue]]가 **비어있는지** 확인합니다. 큐 처리 루프의 표준 종료 조건이며, `poll`/`peek` 호출 전 안전 검사로 거의 항상 함께 쓰입니다.

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
Queue<Integer> q = new LinkedList<>();
```

```
[ 초기 상태 ]
q: front → [] ← rear

q.isEmpty();   // true
```

```java
q.add(10);
```

```
[ 변경 후 ]
q: front → [10] ← rear

q.isEmpty();   // false
```

```java
q.poll();
```

```
[ 변경 후 ]
q: front → [] ← rear

q.isEmpty();   // true
```

## size() == 0 vs isEmpty()

```java
if (q.size() == 0) { ... }   // X 의도가 덜 명확
if (q.isEmpty())   { ... }   // O 권장
```

> 모든 컬렉션 인터페이스(List, Set, Map, Queue)가 `isEmpty()`를 제공.
> 일부 구현체(연결 리스트 기반)에서 `size()`는 O(n)일 수 있어 `isEmpty()`가 안전.

## 자주 쓰는 패턴

### BFS — 큐가 빌 때까지 처리 (표준 패턴)

```java
Queue<Integer> queue = new LinkedList<>();
queue.add(start);
visited[start] = true;

while (!queue.isEmpty()) {           // 종료 조건
    int cur = queue.poll();
    for (int next : graph[cur]) {
        if (!visited[next]) {
            visited[next] = true;
            queue.add(next);
        }
    }
}
```

### 이중 루프 — 그룹 묶기

```java
while (!q.isEmpty()) {               // 외부: 큐 전체 소진까지
    int now = q.poll();
    int cnt = 1;

    while (!q.isEmpty() && q.peek() <= now) {   // 내부: 같은 그룹 추가 묶음
        q.poll();
        cnt++;
    }
    list.add(cnt);
}
```

```
[ isEmpty의 역할 ]
- 외부 while: 큐가 비면 모든 원소 처리 완료 → 종료
- 내부 while: peek 호출 전 안전 검사 (빈 큐에서 peek은 null → NPE 위험)

→ &&의 단락 평가 덕분에 isEmpty()가 false면 peek() 호출 안 됨
```

### 레벨 단위 BFS

```java
Queue<Node> queue = new LinkedList<>();
queue.add(root);

int level = 0;
while (!queue.isEmpty()) {
    int size = queue.size();
    for (int i = 0; i < size; i++) {
        Node node = queue.poll();
        if (node.left  != null) queue.add(node.left);
        if (node.right != null) queue.add(node.right);
    }
    level++;
}
```

### 안전한 poll — null 가드

```java
// isEmpty 체크가 있으면 int로 받아도 안전
while (!queue.isEmpty()) {
    int x = queue.poll();   // O null 안 나옴
    process(x);
}

// isEmpty 없이 받으면 Integer로
Integer x = queue.poll();
if (x == null) return;
```

## 시간복잡도

|연산|복잡도|
|---|---|
|`isEmpty()`|O(1)|

> 모든 표준 큐 구현체에서 O(1) 보장.

## 핵심 정리

`isEmpty()`는 큐가 비었는지 O(1)에 확인하는 메서드로, **`while (!q.isEmpty())` 패턴은 Queue를 다루는 거의 모든 BFS·작업 큐 코드의 표준 종료 조건**입니다. `peek`/`poll` 호출 전 NPE 방지용 가드로도 함께 쓰이며, `size() == 0`보다 의도가 명확하고 일부 구현체에서 더 빠르므로 항상 `isEmpty`를 우선합니다.
