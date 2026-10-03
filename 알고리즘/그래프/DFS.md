---
title: "DFS"
tags: [그래프, 탐색]
status: published
---

그래프나 트리에서 한 경로를 끝까지 탐색한 뒤 더 갈 곳이 없으면 되돌아가 다른 경로를 탐색하는 방식의 순회 알고리즘입니다.

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

DFS(1) 호출 — 재귀 스택 변화:

방문(1) → visited={1}
  방문(2) → visited={1,2}
    방문(4) → visited={1,2,4}
      2 → 이미 방문, 건너뜀
      3 → 미방문 → 방문(3) → visited={1,2,3,4}
        1 → 이미 방문
        4 → 이미 방문
        ← 복귀
      5 → 미방문 → 방문(5) → visited={1,2,3,4,5}
        4 → 이미 방문
        ← 복귀
      ← 복귀
    1 → 이미 방문
    ← 복귀
  3 → 이미 방문
  ← 복귀

방문 순서: 1 → 2 → 4 → 3 → 5
```

## 구현

```java
// 재귀 방식
void dfs(int node, boolean[] visited, List<List<Integer>> graph) {
    visited[node] = true;
    System.out.print(node + " ");

    for (int next : graph.get(node)) {
        if (!visited[next]) {
            dfs(next, visited, graph);
        }
    }
}
```

```java
// 반복 방식 — 명시적 스택 사용
void dfsIterative(int start, List<List<Integer>> graph) {
    boolean[] visited = new boolean[graph.size()];
    Deque<Integer> stack = new ArrayDeque<>();
    stack.push(start);

    while (!stack.isEmpty()) {
        int node = stack.pop();
        if (visited[node]) continue;

        visited[node] = true;
        System.out.print(node + " ");

        for (int next : graph.get(node)) {
            if (!visited[next]) {
                stack.push(next);
            }
        }
    }
}
```

재귀 방식은 함수 호출 스택을, 반복 방식은 [[Stack]]을 직접 사용한다는 점만 다를 뿐 동작 원리는 같습니다.

## 복잡도

| 구분 | 복잡도 | 근거 |
|---|---|---|
| 시간 | O(V + E) | 모든 노드(V)를 한 번씩 방문하고, 각 노드의 인접 리스트(총 E)를 한 번씩 순회 |
| 공간 | O(V) | 방문 배열 + 재귀 호출 스택(또는 명시적 스택)의 최대 깊이 |

## 주의사항

- **방문 배열 누락**: `visited` 체크 없이 탐색하면 사이클이 있는 그래프에서 무한 재귀/루프에 빠짐
- **재귀 깊이**: 노드 수가 매우 많은 그래프에서 재귀 방식은 `StackOverflowError` 위험 — 이 경우 반복 방식(명시적 스택)으로 대체
- **[[BFS]]와의 차이**: DFS는 한 경로를 끝까지 파고드는 반면 BFS는 가까운 노드부터 레벨 단위로 탐색 — 최단 경로가 필요하면 BFS, 모든 경로 탐색이나 연결 요소 판별에는 DFS가 적합

## 핵심 정리

- 한 방향으로 끝까지 탐색 후 되돌아가는(backtrack) 방식 — 재귀 또는 스택으로 구현
- 시간복잡도 O(V + E), 공간복잡도 O(V)
- 사이클 그래프에서는 방문 배열이 필수
- [[백트래킹]]은 DFS에 가지치기를 더한 탐색 방식
