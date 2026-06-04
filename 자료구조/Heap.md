**완전 이진 트리** 기반으로 부모-자식 간 대소 관계를 항상 유지하는 자료구조로, 최솟값/최댓값을 O(log n)에 삽입하고 O(1)에 조회할 수 있습니다.

## 핵심 특징

- **Max Heap**: 부모 ≥ 자식 → 루트가 최댓값
- **Min Heap**: 부모 ≤ 자식 → 루트가 최솟값
- 배열로 구현: `parent = (i-1)/2`, `left = 2i+1`, `right = 2i+2`
- 삽입/삭제 시 **heapify** (재정렬)로 힙 속성 유지

## 구조

```
[ Min Heap ]

        1
       / \
      3    2
     / \  / \
    7   4 5   6

배열: [1, 3, 2, 7, 4, 5, 6]
```

## 주요 연산

| 연산 | 시간복잡도 | 설명 |
|---|---|---|
| peek | O(1) | 루트(최솟값/최댓값) 조회 |
| offer | O(log n) | 삽입 후 위로 heapify |
| poll | O(log n) | 루트 제거 후 아래로 heapify |
| 힙 생성 | O(n) | 배열 → 힙 변환 |

## Java에서의 Heap — PriorityQueue

```java
// Min Heap (기본)
PriorityQueue<Integer> minHeap = new PriorityQueue<>();

// Max Heap
PriorityQueue<Integer> maxHeap = new PriorityQueue<>(Collections.reverseOrder());

minHeap.offer(3);
minHeap.offer(1);
minHeap.offer(2);

minHeap.peek();   // 1 (제거 안 함)
minHeap.poll();   // 1 (제거)
```

## Heap vs 다른 자료구조

| | Heap | 정렬된 배열 | BST |
|---|---|---|---|
| 최솟값 조회 | O(1) | O(1) | O(log n) |
| 삽입 | O(log n) | O(n) | O(log n) |
| 임의 검색 | O(n) | O(log n) | O(log n) |

## 주요 활용

- **[[PriorityQueue]]**: 우선순위 기반 작업 처리 (다익스트라, 작업 스케줄링)
- **힙 정렬**: O(n log n) 정렬
- **K번째 최솟값/최댓값** 추출





