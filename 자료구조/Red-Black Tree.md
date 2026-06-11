삽입/삭제 후에도 자동으로 균형을 유지하는 **자가 균형 이진 탐색 트리**로, 모든 연산을 O(log n)에 보장합니다.

## 핵심 규칙 (5가지)

1. 모든 노드는 **Red** 또는 **Black**
2. 루트는 항상 **Black**
3. 모든 리프(NIL 노드)는 **Black**
4. **Red 노드의 자식은 반드시 Black** (Red 연속 불가)
5. 임의의 노드에서 리프까지 경로의 **Black 노드 수는 모두 동일**

## 구조

```
        10(B)
       /     \
     5(R)   15(B)
    /   \
  3(B)  7(B)
```

> 5규칙 덕분에 최장 경로 ≤ 최단 경로 × 2 → 트리 높이 O(log n) 보장

## 연산

| 연산 | 복잡도 |
|---|---|
| 탐색 | O(log n) |
| 삽입 | O(log n) |
| 삭제 | O(log n) |

삽입/삭제 후 규칙 위반 시 **회전(Rotation)** 과 **색 변경(Recoloring)** 으로 복구합니다.

## 회전 (Rotation)

균형 복구의 핵심 연산. 트리 구조를 바꾸되 BST 정렬 순서는 유지합니다.

```
[ Left Rotation ]

    x                y
   / \              / \
  A   y    →      x   C
     / \         / \
    B   C       A   B

[ Right Rotation ]

      y            x
     / \          / \
    x   C  →    A   y
   / \              / \
  A   B            B   C
```

## BST vs AVL vs Red-Black Tree

| | BST | AVL Tree | Red-Black Tree |
|---|---|---|---|
| 균형 | X | 엄격 (높이 차 ≤ 1) | 느슨 |
| 탐색 | O(n) 최악 | O(log n) | O(log n) |
| 삽입/삭제 | O(n) 최악 | O(log n), 회전 많음 | O(log n), 회전 적음 |
| 용도 | 단순 구현 | 탐색 빈번 | 삽입/삭제 빈번 |

> AVL은 균형이 더 엄격해 탐색은 빠르지만, 삽입/삭제 시 회전이 더 많이 발생합니다.
> Red-Black Tree는 균형이 느슨한 대신 삽입/삭제가 더 효율적입니다.

## Java에서의 활용

- `TreeMap`, `TreeSet` — Red-Black Tree로 구현
- `HashMap` — 버킷의 체이닝이 8개 초과 시 LinkedList → Red-Black Tree로 전환

→ [[B-Tree]]
