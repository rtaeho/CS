---
title: "PriorityQueue"
tags: [우선순위큐, 힙]
status: published
---

**원소를 우선순위에 따라 꺼내는 큐**로, 내부적으로 **이진 힙(binary heap)** 으로 구현된 자료구조입니다 (`java.util.PriorityQueue`).

## 핵심 특징

- **삽입 순서 무관**: 우선순위가 가장 높은 원소가 항상 먼저 나감
- **내부 구조**: 이진 힙 (배열로 구현된 완전 이진 트리)
- **삽입 / 삭제**: O(log n) — 힙 재정렬 비용
- **조회(`peek`)**: O(1) — 루트만 보면 됨
- **기본값**: 최소 힙 (작은 값이 먼저)
- **최대 힙**: `Comparator.reverseOrder()` 또는 커스텀 [[Comparator]]

```
[ 이진 힙 — 최소 힙 예시 ]

       1
      / \
     3   5
    / \ /
   7  4 9

배열 표현: [1, 3, 5, 7, 4, 9]
부모(i) → 자식(2i+1, 2i+2)
자식(i) → 부모((i-1)/2)

루트 = 항상 최솟값 → peek/poll 시 1이 나옴
```

## 주요 연산

|연산|설명|시간 복잡도|
|---|---|---|
|`offer(e)` / `add(e)`|원소 삽입|O(log n)|
|`poll()`|루트 제거 후 반환 (없으면 null)|O(log n)|
|`peek()`|루트 조회 (없으면 null)|O(1)|
|`size()`|원소 개수|O(1)|
|`isEmpty()`|비었는지 확인|O(1)|
|`contains(e)`|원소 존재 확인|O(n)|
|`remove(e)`|특정 원소 제거|O(n)|

> `contains`, `remove`는 힙 구조상 선형 탐색이 필요 — 자주 쓰지 말 것.

## 기본 사용

### 최소 힙 (기본)

```java
PriorityQueue<Integer> minHeap = new PriorityQueue<>();
minHeap.offer(5);
minHeap.offer(1);
minHeap.offer(3);

minHeap.poll();   // 1
minHeap.poll();   // 3
minHeap.poll();   // 5
```

### 최대 힙

```java
PriorityQueue<Integer> maxHeap = new PriorityQueue<>(Comparator.reverseOrder());
maxHeap.offer(5);
maxHeap.offer(1);
maxHeap.offer(3);

maxHeap.poll();   // 5
```

### 객체 우선순위 큐

```java
class Task {
    int priority;
    String name;
}

// 우선순위 높은(숫자 작은) Task 먼저
PriorityQueue<Task> pq = new PriorityQueue<>(
    Comparator.comparingInt(t -> t.priority)
);
```

## 다중 기준 [[Comparator]]

자주 등장하는 패턴. 1차 기준이 같을 때 2차 기준으로 정렬.

```java
// play 내림차순, 같으면 idx 오름차순
PriorityQueue<Song> pq = new PriorityQueue<>((s1, s2) -> {
    if (s1.play == s2.play) {
        return Integer.compare(s1.idx, s2.idx);
    }
    return Integer.compare(s2.play, s1.play);
});
```

`thenComparing`으로도 동일:

```java
PriorityQueue<Song> pq = new PriorityQueue<>(
    Comparator.comparingInt((Song s) -> s.play).reversed()
        .thenComparingInt(s -> s.idx)
);
```

## PriorityQueue vs 정렬

|상황|선택|이유|
|---|---|---|
|모든 원소를 한 번에 정렬|[[Collections.sort]] / [[List.sort]]|O(n log n) 한 번|
|매번 최솟값/최댓값 꺼내며 원소 추가|**PriorityQueue**|삽입·삭제마다 O(log n)|
|상위 K개만 필요|**PriorityQueue (크기 K 유지)**|O(n log K)|
|범위 검색·중간값 접근|TreeSet / TreeMap|정렬된 트리 구조|

```
[ 정렬 vs 힙의 비용 ]

전체 정렬 후 K개:   O(n log n)
PQ로 K개 유지:     O(n log K)   ← K << n 일 때 유리

n=1억, K=10 →
  정렬:  10⁸ * log(10⁸) ≈ 2.6 * 10⁹
  PQ:    10⁸ * log(10) ≈ 3.3 * 10⁸    (약 8배 빠름)
```

## 주요 활용 패턴

### 1. Top-K (상위 K개 추출)

크기 K짜리 **최소 힙**을 유지하면 항상 루트가 K개 중 가장 작은 값. 새 원소가 그보다 크면 교체.

```java
// 가장 큰 K개 찾기
PriorityQueue<Integer> pq = new PriorityQueue<>();   // 최소 힙
for (int x : arr) {
    pq.offer(x);
    if (pq.size() > k) pq.poll();   // 최소값 버리기
}
// pq에 가장 큰 K개가 남음
```

### 2. 다익스트라 (최단 경로)

매번 **현재까지 거리가 최소인 정점**을 꺼내야 함 → 최소 힙.

```java
PriorityQueue<int[]> pq = new PriorityQueue<>((a, b) -> a[1] - b[1]);
pq.offer(new int[]{start, 0});
// pq에서 거리 최소 정점 꺼내며 갱신
```

### 3. 작업 스케줄링

마감 시간이 가장 빠른 작업, 우선순위가 높은 작업부터 처리.

### 4. 두 힙으로 중간값 유지

최대 힙(왼쪽 절반) + 최소 힙(오른쪽 절반) → 두 루트로 중간값 O(1) 조회.

## 자주 하는 실수

### 정렬된 순회를 보장하지 않음

```java
PriorityQueue<Integer> pq = new PriorityQueue<>(List.of(3, 1, 2));

// X 정렬되어 보이지 않음
for (int x : pq) System.out.println(x);
// 출력 예: 1 3 2  (힙 배열 순서)

// O poll로 꺼내야 정렬 순서
while (!pq.isEmpty()) System.out.println(pq.poll());
// 출력: 1 2 3
```

> **iterator는 힙 배열 그대로 순회** — 정렬된 순서가 아님.

### 원소 변경 후 재정렬 안 됨

```java
PriorityQueue<Task> pq = ...;
Task t = pq.peek();
t.priority = 0;   // 힙은 이걸 모름

// 우선순위 변경하려면 제거 후 다시 삽입
pq.remove(t);
t.priority = 0;
pq.offer(t);
```

### `b - a` 오버플로

```java
// X Integer.MIN/MAX 근처에서 오버플로
new PriorityQueue<>((a, b) -> b - a);

// O 안전
new PriorityQueue<>((a, b) -> Integer.compare(b, a));
new PriorityQueue<>(Comparator.reverseOrder());
```

[[Comparator]]의 자주 하는 실수 항목 참고.

### 초기 용량 vs 크기

```java
new PriorityQueue<>(11);                            // 초기 용량 11 (확장 가능)
new PriorityQueue<>(11, Comparator.reverseOrder()); // 초기 용량 + 비교자
```

용량 제한이 아니라 내부 배열 크기 힌트. 자동 확장됨.

## 시간복잡도 정리

|연산|복잡도|비고|
|---|---|---|
|build (n개 일괄 삽입)|O(n)|`new PriorityQueue<>(collection)` — heapify|
|build (offer 반복)|O(n log n)|하나씩 넣으면 더 느림|
|`offer` / `poll`|O(log n)||
|`peek`|O(1)||
|`contains` / `remove(Object)`|O(n)|선형 탐색|

## 핵심 정리

`PriorityQueue`는 **이진 힙 기반의 우선순위 큐**로, 삽입·삭제 O(log n), 최댓값/최솟값 조회 O(1)을 보장합니다. 기본은 최소 힙이며 [[Comparator]]로 최대 힙 또는 다중 기준 정렬을 만들 수 있습니다. **Top-K, 다익스트라, 작업 스케줄링** 등 "매번 우선순위가 가장 높은 원소를 꺼내야 하는" 문제에서 정렬보다 효율적입니다. 단, 순회 순서가 정렬 순서와 다르고, 원소 내부 값을 바꾸면 힙이 자동 재정렬되지 않으므로 주의해야 합니다.
