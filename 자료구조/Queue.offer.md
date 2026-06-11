---
title: "Queue.offer"
tags: [큐, BFS]
status: published
---

[[Queue]]의 **rear(뒤)에 원소를 삽입**합니다 (enqueue). 같은 역할의 [[Queue.add]]와 달리 **실패 시 예외 대신 false를 반환**합니다.

## 시그니처

```java
boolean offer(E e)   // 성공: true, 실패: false
boolean add(E e)     // 성공: true, 실패: IllegalStateException
```

## add vs offer

| | `add(e)` | `offer(e)` |
|---|---|---|
| 성공 | `true` | `true` |
| 실패 (큐가 가득 참) | `IllegalStateException` | `false` |
| 권장 상황 | 실패가 절대 없어야 할 때 | 실패를 조건 분기로 처리할 때 |

> `LinkedList`, `ArrayDeque`처럼 용량 제한 없는 큐에서는 둘 다 동일하게 작동.
> `ArrayBlockingQueue`처럼 용량 제한 있는 큐에서만 차이가 드러남.

## 동작 추적

```java
Queue<Integer> q = new LinkedList<>();
```

```
[ 초기 상태 ]
q: front → [] ← rear
```

```java
q.offer(10);
q.offer(20);
q.offer(30);
```

```
q.offer(10): front → [10] ← rear
q.offer(20): front → [10, 20] ← rear
q.offer(30): front → [10, 20, 30] ← rear

→ 항상 rear(뒤)에 추가됨
```

## 선택 기준

```java
// 용량 제한 없는 큐 — 어느 쪽이든 동일
Queue<Integer> q = new LinkedList<>();
q.offer(1);   // O Java 컨벤션상 offer 권장

// 용량 제한 있는 큐 — offer로 조건 분기
Queue<Integer> bq = new ArrayBlockingQueue<>(2);
bq.offer(1);   // true
bq.offer(2);   // true
bq.offer(3);   // false (예외 없이 실패)

if (!bq.offer(value)) {
    // 삽입 실패 처리
}
```

## 자주 쓰는 패턴

### BFS

```java
Queue<Integer> queue = new LinkedList<>();
queue.offer(start);
visited[start] = true;

while (!queue.isEmpty()) {
    int cur = queue.poll();
    for (int next : graph[cur]) {
        if (!visited[next]) {
            visited[next] = true;
            queue.offer(next);
        }
    }
}
```

### 고정 크기 슬라이딩 윈도우

```java
Queue<Integer> q = new LinkedList<>();
for (int i = 0; i < windowSize; i++) q.offer(0);  // 초기화

for (int val : values) {
    sum -= q.poll();
    q.offer(val);
    sum += val;
}
```

## 시간복잡도

| 구현체 | `offer` |
|---|---|
| `LinkedList` | O(1) |
| `ArrayDeque` | O(1) 평균 (확장 시 O(n)) |
| `PriorityQueue` | O(log n) |
| `ArrayBlockingQueue` | O(1) |

## 핵심 정리

`offer`는 큐 rear에 원소를 삽입하는 enqueue 연산이며, `add`와 달리 실패 시 **false를 반환**해 예외 없이 조건 분기가 가능합니다. 용량 제한 없는 큐에서는 `add`와 동일하게 동작하며, Java 컨벤션상 일반적인 상황에서 `offer`가 더 안전한 선택으로 권장됩니다.

→ [[Queue.add]]
