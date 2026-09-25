---
title: "BFS"
tags: [그래프, 탐색, 최단경로]
status: published
---

시작 노드에서 가까운 노드부터 레벨 단위로 넓게 퍼져나가며 탐색하는 순회 알고리즘입니다.

## 동작 과정

```
[ 그래프 ]
1 — 2 — 4 — 5
|       |
3 ———————

인접 리스트:
1: [2, 3]
2: [1, 4]
3: [1, 4]
4: [2, 3, 5]
5: [4]

BFS(1) — 큐 변화:

큐=[1]        visited={1}
  1 꺼냄 → 2, 3 삽입
큐=[2, 3]     visited={1,2,3}
  2 꺼냄 → 1(방문), 4 삽입
큐=[3, 4]     visited={1,2,3,4}
  3 꺼냄 → 1(방문), 4(방문)
큐=[4]
  4 꺼냄 → 2(방문), 3(방문), 5 삽입
큐=[5]        visited={1,2,3,4,5}
  5 꺼냄 → 4(방문)
큐=[]         종료

방문 순서: 1 → 2 → 3 → 4 → 5
거리:      0    1    1    2    3
```

레벨이 올라갈 때마다 거리가 1씩 늘어나므로, 큐에서 꺼낸 순서가 곧 시작점에서 가까운 순서입니다.

## 구현

```java
void bfs(int start, List<List<Integer>> graph) {
    boolean[] visited = new boolean[graph.size()];
    Queue<Integer> queue = new ArrayDeque<>();

    queue.offer(start);
    visited[start] = true;  // 큐에 넣는 시점에 방문 처리

    while (!queue.isEmpty()) {
        int node = queue.poll();
        System.out.print(node + " ");

        for (int next : graph.get(node)) {
            if (!visited[next]) {
                visited[next] = true;
                queue.offer(next);
            }
        }
    }
}
```

```java
// 가중치 없는 그래프의 최단 거리
int[] shortestPath(int start, List<List<Integer>> graph) {
    int[] dist = new int[graph.size()];
    Arrays.fill(dist, -1);
    Queue<Integer> queue = new ArrayDeque<>();

    queue.offer(start);
    dist[start] = 0;

    while (!queue.isEmpty()) {
        int node = queue.poll();
        for (int next : graph.get(node)) {
            if (dist[next] == -1) {
                dist[next] = dist[node] + 1;
                queue.offer(next);
            }
        }
    }
    return dist;
}
```

[[Queue]] 구현체로는 `LinkedList`보다 [[ArrayDeque]]가 빠릅니다.

## 복잡도

| 구분 | 복잡도 | 근거 |
|---|---|---|
| 시간 | O(V + E) | 모든 노드를 한 번씩 큐에 넣고 꺼내며, 각 노드의 인접 리스트(총 E)를 한 번씩 순회 |
| 공간 | O(V) | 방문 배열 + 큐에 동시에 들어가는 노드 수(최악의 경우 한 레벨 전체) |

## 주의사항

- **방문 처리 시점**: 큐에서 꺼낼 때 방문 처리하면 같은 노드가 큐에 여러 번 들어가 중복 탐색이 생김. **큐에 넣는 시점**에 처리해야 한다
- **최단 경로 보장 조건**: 간선 가중치가 모두 같을 때만 성립. 가중치가 다르면 [[다익스트라]]를 써야 한다
- **[[DFS]]와의 선택**: 최단 경로·최소 횟수를 구하면 BFS, 모든 경로 탐색이나 연결 요소 판별은 DFS가 간결하다

## 핵심 정리

- 레벨 단위로 퍼져나가는 탐색 — [[Queue]]로 구현
- 시간복잡도 O(V + E), 공간복잡도 O(V)
- **가중치가 없는(또는 모두 동일한) 그래프의 최단 경로**를 구할 수 있다는 점이 DFS와의 결정적 차이
- 방문 처리는 큐에 넣는 시점에
