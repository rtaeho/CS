데이터를 **선입선출(FIFO, First In First Out)** 순서로 삽입·삭제하는 선형 자료구조입니다.

## 핵심 개념

|항목|내용|
|---|---|
|**원리**|가장 먼저 들어온 데이터가 가장 먼저 나감|
|**삽입**|enqueue — 큐의 뒤(rear)에 추가|
|**삭제**|dequeue — 큐의 앞(front)에서 제거|
|**조회**|peek — 앞의 원소를 제거하지 않고 확인|
|**시간 복잡도**|enqueue, dequeue, peek 모두 O(1)|

```
enqueue(1) → enqueue(2) → enqueue(3)

front → │ 1 │ 2 │ 3 │ ← rear

dequeue() → 1 반환 (가장 먼저 들어온 것이 먼저 나감)

front → │ 2 │ 3 │ ← rear
```

## 주요 연산

|연산|설명|시간 복잡도|
|---|---|---|
|`enqueue(item)`|rear에 원소 삽입|O(1)|
|`dequeue()`|front 원소 제거 후 반환|O(1)|
|`peek()` / `front()`|front 원소 확인 (제거 안 함)|O(1)|
|`isEmpty()`|큐가 비었는지 확인|O(1)|
|`size()`|원소 개수 반환|O(1)|

## 큐의 종류

|종류|설명|용도|
|---|---|---|
|**선형 큐**|기본 FIFO 큐|일반적인 대기열|
|**원형 큐 (Circular Queue)**|배열의 끝과 처음이 연결된 형태|배열 공간 재활용|
|**덱 (Deque)**|양쪽 끝에서 삽입·삭제 가능|스택+큐 역할 동시|
|**우선순위 큐 (Priority Queue)**|우선순위가 높은 원소가 먼저 나감|작업 스케줄링, 다익스트라|

## Java 구현

### 1. Java 내장 클래스

```java
// Queue 인터페이스 — LinkedList로 구현
Queue<Integer> queue = new LinkedList<>();
queue.offer(1);     // enqueue
queue.offer(2);
queue.offer(3);
queue.poll();       // dequeue → 1
queue.peek();       // 2 (제거 안 함)
queue.isEmpty();    // false
queue.size();       // 2

// ArrayDeque 사용 (더 빠름, 권장)
Queue<Integer> queue = new ArrayDeque<>();
queue.offer(1);
queue.offer(2);
queue.poll();       // 1
```

|메서드|실패 시 예외|실패 시 null/false 반환|
|---|---|---|
|**삽입**|`add(e)` → IllegalStateException|`offer(e)` → false|
|**삭제**|`remove()` → NoSuchElementException|`poll()` → null|
|**조회**|`element()` → NoSuchElementException|`peek()` → null|

### 2. 배열 기반 원형 큐 구현

```java
public class CircularQueue<E> {
    private Object[] arr;
    private int front;
    private int rear;
    private int size;
    private int capacity;

    public CircularQueue(int capacity) {
        this.capacity = capacity;
        this.arr = new Object[capacity];
        this.front = 0;
        this.rear = -1;
        this.size = 0;
    }

    public void enqueue(E item) {
        if (size == capacity) throw new IllegalStateException("큐가 가득 참");
        rear = (rear + 1) % capacity;  // 원형으로 순환
        arr[rear] = item;
        size++;
    }

    @SuppressWarnings("unchecked")
    public E dequeue() {
        if (size == 0) throw new NoSuchElementException("큐가 비어 있음");
        E item = (E) arr[front];
        arr[front] = null;
        front = (front + 1) % capacity;  // 원형으로 순환
        size--;
        return item;
    }

    @SuppressWarnings("unchecked")
    public E peek() {
        if (size == 0) throw new NoSuchElementException();
        return (E) arr[front];
    }

    public boolean isEmpty() { return size == 0; }
    public int size() { return size; }
}
```

### 3. 연결 리스트 기반 구현

```java
public class LinkedQueue<E> {
    private static class Node<E> {
        E data;
        Node<E> next;
        Node(E data) { this.data = data; }
    }

    private Node<E> front;
    private Node<E> rear;
    private int size;

    public void enqueue(E item) {
        Node<E> newNode = new Node<>(item);
        if (rear != null) rear.next = newNode;
        rear = newNode;
        if (front == null) front = rear;
        size++;
    }

    public E dequeue() {
        if (front == null) throw new NoSuchElementException();
        E item = front.data;
        front = front.next;
        if (front == null) rear = null;
        size--;
        return item;
    }

    public E peek() {
        if (front == null) throw new NoSuchElementException();
        return front.data;
    }

    public boolean isEmpty() { return front == null; }
    public int size() { return size; }
}
```

## 선형 큐 vs 원형 큐

```
[선형 큐의 문제]
enqueue(1), enqueue(2), enqueue(3)
│ 1 │ 2 │ 3 │   │   │
  ↑ front       ↑ rear

dequeue() → 1 제거, dequeue() → 2 제거
│   │   │ 3 │   │   │
          ↑ front  ↑ rear

→ 앞의 빈 공간을 재활용할 수 없음 (낭비)

[원형 큐로 해결]
rear가 배열 끝에 도달하면 인덱스 0으로 순환

  인덱스: 0   1   2   3   4
        │   │   │ 3 │   │   │
                  ↑ front

  enqueue(4) → rear = (4+1) % 5 = 0
        │ 4 │   │ 3 │   │   │
          ↑ rear  ↑ front

→ 앞의 빈 공간 재활용 가능!
```

```
원형 큐 시각화:

        [0]
      ↗     ↘
   [4]       [1]
     ↖     ↙
   [3] ← [2]

front과 rear가 원형으로 순환
```

## 덱 (Deque — Double Ended Queue)

양쪽 끝에서 삽입과 삭제가 모두 가능한 큐입니다.

```
       앞(front)              뒤(rear)
삽입 ←──│ 1 │ 2 │ 3 │──→ 삽입
삭제 ←──│   │   │   │──→ 삭제
```

```java
Deque<Integer> deque = new ArrayDeque<>();

// 앞에서 삽입/삭제
deque.offerFirst(1);   // front에 삽입
deque.pollFirst();     // front에서 제거

// 뒤에서 삽입/삭제
deque.offerLast(2);    // rear에 삽입
deque.pollLast();      // rear에서 제거

// 스택처럼 사용
deque.push(1);         // = offerFirst
deque.pop();           // = pollFirst

// 큐처럼 사용
deque.offer(1);        // = offerLast
deque.poll();          // = pollFirst
```

## 우선순위 큐 (Priority Queue)

FIFO가 아니라 **우선순위가 높은 원소**가 먼저 나갑니다.

```java
// 기본: 오름차순 (작은 값이 높은 우선순위)
PriorityQueue<Integer> pq = new PriorityQueue<>();
pq.offer(30);
pq.offer(10);
pq.offer(20);
pq.poll();   // 10 (가장 작은 값)
pq.poll();   // 20
pq.poll();   // 30

// 내림차순 (큰 값이 높은 우선순위)
PriorityQueue<Integer> maxPq = new PriorityQueue<>(Collections.reverseOrder());
maxPq.offer(30);
maxPq.offer(10);
maxPq.offer(20);
maxPq.poll();   // 30 (가장 큰 값)
```

|항목|일반 큐|우선순위 큐|
|---|---|---|
|**순서**|FIFO (삽입 순서)|우선순위 순서|
|**내부 구조**|배열 / 연결 리스트|힙 (Heap)|
|**삽입**|O(1)|O(log n)|
|**삭제**|O(1)|O(log n)|

## 큐의 활용 사례

|활용|설명|
|---|---|
|**BFS (너비 우선 탐색)**|방문할 노드를 큐에 저장|
|**작업 스케줄링**|OS의 프로세스 스케줄링 (Ready Queue)|
|**메시지 큐**|Kafka, RabbitMQ 등 비동기 메시지 처리|
|**버퍼**|I/O 버퍼, 네트워크 패킷 버퍼|
|**프린터 대기열**|인쇄 요청 순서대로 처리|
|**캐시 (LRU)**|최근 사용 기록 관리|

### BFS 예시

```java
public void bfs(int[][] graph, int start) {
    boolean[] visited = new boolean[graph.length];
    Queue<Integer> queue = new ArrayDeque<>();

    visited[start] = true;
    queue.offer(start);

    while (!queue.isEmpty()) {
        int node = queue.poll();       // front에서 꺼냄
        System.out.print(node + " ");

        for (int neighbor : graph[node]) {
            if (!visited[neighbor]) {
                visited[neighbor] = true;
                queue.offer(neighbor); // rear에 추가
            }
        }
    }
}
```

## 스택 vs 큐 비교

|항목|스택 (Stack)|큐 (Queue)|
|---|---|---|
|**원리**|LIFO (후입선출)|FIFO (선입선출)|
|**삽입**|push (top에)|enqueue (rear에)|
|**삭제**|pop (top에서)|dequeue (front에서)|
|**비유**|접시 쌓기|줄 서기|
|**활용**|함수 호출, DFS, Undo|BFS, 작업 큐, 버퍼|
|**Java 권장**|`ArrayDeque`|`ArrayDeque` 또는 `LinkedList`|
