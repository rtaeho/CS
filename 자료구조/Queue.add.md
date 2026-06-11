---
title: "Queue.add"
tags: [큐, BFS]
status: published
---

[[Queue]]의 **rear(뒤)에 원소를 삽입**합니다 (enqueue). 같은 역할의 메서드로 `offer`가 있으며, **실패 시 동작이 다릅니다**.

## 시그니처

```java
boolean add(E e)     // 실패 시 IllegalStateException
boolean offer(E e)   // 실패 시 false 반환
```

|메서드|성공|실패 (큐가 가득 참)|
|---|---|---|
|`add(e)`|true|`IllegalStateException`|
|`offer(e)`|true|false|

> 용량 제한이 없는 큐(`LinkedList`, `ArrayDeque`)에서는 둘 다 동일하게 작동.
> `ArrayBlockingQueue`처럼 용량 제한이 있는 큐에서만 차이가 드러남.

## 동작 추적

```java
Queue<Integer> q = new LinkedList<>();
```

```
[ 초기 상태 ]
q: front → [] ← rear
```

```java
q.add(10);
q.add(20);
q.add(30);
```

```
[ 단계별 추적 ]

q.add(10):  front → [10] ← rear
q.add(20):  front → [10, 20] ← rear
q.add(30):  front → [10, 20, 30] ← rear

→ 항상 rear(뒤)에 추가됨
```

## add vs offer 선택 기준

```java
// 용량 제한 없는 큐 — 둘 다 동일
Queue<Integer> q = new LinkedList<>();
q.add(1);     // OK
q.offer(1);   // OK

// 용량 제한 있는 큐
Queue<Integer> bq = new ArrayBlockingQueue<>(2);
bq.add(1); bq.add(2);
bq.add(3);     // X IllegalStateException
bq.offer(3);   // O false 반환 (조용히 실패)
```

> 일반적인 코딩테스트/BFS에서는 `add`/`offer` 어느 쪽을 써도 됨.
> Java 컨벤션상 **`offer`가 더 안전한 선택**으로 권장됨.

## 자주 쓰는 패턴

### BFS — 인접 노드 큐에 추가

```java
Queue<Integer> queue = new LinkedList<>();
queue.add(start);
visited[start] = true;

while (!queue.isEmpty()) {
    int cur = queue.poll();
    for (int next : graph[cur]) {
        if (!visited[next]) {
            visited[next] = true;
            queue.add(next);   // rear에 추가
        }
    }
}
```

### 작업 단위 누적 (기능개발 패턴)

```java
Queue<Integer> q = new LinkedList<>();

for (int i = 0; i < progresses.length; i++) {
    int remain = 100 - progresses[i];
    int day = (remain + speeds[i] - 1) / speeds[i];   // 올림 나눗셈
    q.add(day);                                        // 완료 예상일 누적
}
```

```
[ 추적 ]
progresses: [93, 30, 55]
speeds:     [1, 30, 5]

i=0: remain=7, day=⌈7/1⌉=7   → q: [7]
i=1: remain=70, day=⌈70/30⌉=3 → q: [7, 3]
i=2: remain=45, day=⌈45/5⌉=9  → q: [7, 3, 9]
```

### 레벨 단위 BFS

```java
Queue<Node> queue = new LinkedList<>();
queue.add(root);

while (!queue.isEmpty()) {
    int size = queue.size();   // 현재 레벨 노드 수 고정
    for (int i = 0; i < size; i++) {
        Node node = queue.poll();
        if (node.left != null)  queue.add(node.left);
        if (node.right != null) queue.add(node.right);
    }
}
```

## List.add와 혼동 주의

`Queue<Integer> q = new LinkedList<>()`로 선언했을 때 `q.add(1, 99)`는 사용할 수 없습니다.

```java
Queue<Integer> q = new LinkedList<>();
q.add(99);          // O Queue.add — rear에 삽입
q.add(0, 99);       // X 컴파일 에러 — Queue 인터페이스에 없음

LinkedList<Integer> ll = new LinkedList<>();
ll.add(0, 99);      // O List.add — 인덱스 삽입 가능 (LinkedList는 List도 구현)
```

> 선언 타입(`Queue` vs `LinkedList`)에 따라 호출 가능한 메서드가 달라짐.

## 시간복잡도

|구현체|`add` / `offer`|
|---|---|
|`LinkedList`|O(1)|
|`ArrayDeque`|O(1) 평균 (확장 시 O(n))|
|`PriorityQueue`|O(log n)|
|`ArrayBlockingQueue`|O(1) (가득 차면 예외)|

## 핵심 정리

`add`는 큐의 rear에 원소를 삽입하는 표준 enqueue 연산이며, 형제 메서드 `offer`와의 차이는 **용량 초과 시 예외 vs false 반환**입니다. `LinkedList`/`ArrayDeque`처럼 용량 제한이 없는 구현체에서는 동작이 동일하며, 코딩테스트에서 BFS·작업 큐·레벨 순회의 출발점으로 가장 자주 쓰입니다.

→ [[Queue.offer]]
