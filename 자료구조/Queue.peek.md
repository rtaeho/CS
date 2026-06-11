[[Queue]]의 **front(앞) 원소를 제거하지 않고 조회**합니다. 같은 역할의 메서드로 `element`가 있으며, **빈 큐에서 동작이 다릅니다**.

## 시그니처

```java
E peek()       // 빈 큐면 null 반환
E element()    // 빈 큐면 NoSuchElementException
```

|메서드|성공|실패 (큐가 빔)|
|---|---|---|
|`peek()`|front 원소 반환|`null` 반환|
|`element()`|front 원소 반환|`NoSuchElementException`|

> 큐 상태를 **변경하지 않음**. 다음에 `poll`로 꺼낼 원소를 미리 확인할 때 사용.

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
int x = q.peek();   // 10 반환
```

```
[ 변경 후 ]
q: front → [10, 20, 30] ← rear   ← 변화 없음!
x = 10

→ poll과 달리 큐는 그대로 유지됨
```

```java
q.poll();              // 10 제거
int y = q.peek();      // 20 (새로운 front)
```

## peek vs poll

```java
Queue<Integer> q = new LinkedList<>();
q.add(1); q.add(2);

q.peek();   // 1 — q: [1, 2]   (그대로)
q.poll();   // 1 — q: [2]      (제거됨)
q.peek();   // 2 — q: [2]      (그대로)
```

|동작|`peek`|`poll`|
|---|---|---|
|반환값|front 원소|front 원소|
|큐 변경|X 변경 안 함|O 제거함|
|빈 큐|null|null|

## 자주 쓰는 패턴

### 조건부 처리 — 다음 원소 미리 보기

```java
while (!q.isEmpty() && q.peek() <= threshold) {
    q.poll();
    cnt++;
}
```

> peek으로 조건 검사 → 만족하면 poll로 실제 제거.
> peek 없이 poll만 쓰면 **꺼낸 원소를 다시 넣어야** 해서 비효율.

### 그룹 묶기 (기능개발 패턴)

```java
while (!q.isEmpty()) {
    int now = q.poll();
    int cnt = 1;

    while (!q.isEmpty() && q.peek() <= now) {   // peek으로 미리 보기
        q.poll();                                // 조건 맞으면 제거
        cnt++;
    }
    list.add(cnt);
}
```

```
[ peek의 역할 ]
"다음 원소가 now 이하면 같은 그룹" 판정을 위해
q.peek()으로 꺼내지 않고 값만 확인 → 조건 만족하면 q.poll()로 제거

만약 peek 없이 짠다면:
  int next = q.poll();     ← 일단 꺼냄
  if (next > now) {
      q.add(next);         ← 다시 넣어야 함 (FIFO 순서 깨짐!)
  }
→ peek이 있으면 이런 복원 필요 없음
```

### BFS 디버깅

```java
while (!queue.isEmpty()) {
    System.out.println("다음 처리할 노드: " + queue.peek());
    int cur = queue.poll();
    // ...
}
```

### 우선순위 큐의 최솟값 확인

```java
PriorityQueue<Integer> pq = new PriorityQueue<>();
pq.offer(30); pq.offer(10); pq.offer(20);

pq.peek();   // 10 (최솟값) — 큐는 그대로
pq.poll();   // 10 (최솟값 제거)
```

> [[PriorityQueue]]의 peek은 항상 우선순위 최상위 원소.

## NullPointerException 주의

```java
Queue<Integer> q = new LinkedList<>();

// 빈 큐에서 peek → null
int x = q.peek();        // X NullPointerException

Integer x = q.peek();    // O
if (x != null) { ... }

// 또는 isEmpty 먼저 체크
if (!q.isEmpty()) {
    int x = q.peek();    // O 안전
}
```

## 형제 메서드 정리

|용도|예외 던짐|null 반환|
|---|---|---|
|삽입|`add(e)`|`offer(e)`|
|제거|`remove()`|`poll()`|
|조회|`element()`|`peek()`|

## 시간복잡도

|구현체|`peek` / `element`|
|---|---|
|`LinkedList`|O(1)|
|`ArrayDeque`|O(1)|
|`PriorityQueue`|O(1) — 힙 루트 조회|
|`ArrayBlockingQueue`|O(1)|

## 핵심 정리

`peek`은 큐의 front 원소를 **꺼내지 않고 들여다보는** 비파괴적 조회로, "다음 원소가 조건에 맞을 때만 제거" 같은 패턴에서 필수입니다. `element`와 달리 빈 큐에서 null을 반환해 안전하며, [[PriorityQueue]]에서는 항상 우선순위 최상위 원소를 보여줍니다. 코딩테스트에서 그룹 묶기, 조건부 dequeue 패턴의 핵심 도구입니다.
