---
title: "비트마스킹 DP"
tags: [DP, 비트연산]
status: published
---

"어떤 원소들을 이미 사용했는가" 같은 집합 상태를 정수의 비트로 표현해 DP 상태로 쓰는 기법입니다.

원소가 N개면 부분집합은 2^N개이고, 각 부분집합을 0 ~ 2^N−1 범위의 정수 하나로 나타낼 수 있습니다. N이 20을 넘기면 상태 수가 100만을 넘어 현실적이지 않습니다.

## 동작 과정

외판원 문제(TSP)로 봅니다. `dp[visited][now]` = `visited` 집합을 방문한 상태로 `now`에 있을 때, 남은 도시를 모두 돌아 출발지로 돌아가는 최소 비용.

```
도시 4개, 비트 표현 (i번 도시 = i번째 비트)

visited = 0b0001 = 1   → {0} 방문
visited = 0b1011 = 11  → {0, 1, 3} 방문
visited = 0b1111 = 15  → 전부 방문 (= (1<<4) - 1)

비트 연산:
  i번 방문했는지    visited & (1 << i)     → 0이 아니면 방문
  i번 방문 처리     visited | (1 << i)
  i번 방문 해제     visited & ~(1 << i)
  방문한 개수       Integer.bitCount(visited)

── 전이 ──
dp[1][0]  (0번만 방문, 0에 있음)
  → 1번으로: dp[0b0011][1] + cost[0][1]
  → 2번으로: dp[0b0101][2] + cost[0][2]
  → 3번으로: dp[0b1001][3] + cost[0][3]
  이 중 최소를 선택

── 종료 ──
visited == 0b1111 이면 출발지로 복귀하는 비용만 남는다
  dp[15][now] = cost[now][0]
```

## 구현

```java
int n;                  // 도시 수
int[][] cost;           // cost[i][j] = i→j 이동 비용
int[][] memo;           // memo[visited][now], -1로 초기화
static final int INF = 1_000_000_000;

int tsp(int visited, int now) {
    if (visited == (1 << n) - 1) {                  // 전부 방문
        return cost[now][0] == 0 ? INF : cost[now][0];
    }
    if (memo[visited][now] != -1) return memo[visited][now];

    int best = INF;
    for (int next = 0; next < n; next++) {
        if ((visited & (1 << next)) != 0) continue;  // 이미 방문
        if (cost[now][next] == 0) continue;          // 길이 없음
        best = Math.min(best, tsp(visited | (1 << next), next) + cost[now][next]);
    }
    return memo[visited][now] = best;
}

// 호출: tsp(1, 0) — 0번 도시를 방문한 상태로 0번에서 시작
```

```java
// 부분집합을 순회하는 관용구
for (int mask = 0; mask < (1 << n); mask++) {
    for (int i = 0; i < n; i++) {
        if ((mask & (1 << i)) != 0) {
            // i가 mask에 포함된 경우의 처리
        }
    }
}

// mask의 부분집합만 순회 (공집합 제외)
for (int sub = mask; sub > 0; sub = (sub - 1) & mask) {
    // sub는 mask의 부분집합
}
```

## 복잡도

| 구분 | 복잡도 | 근거 |
|---|---|---|
| 시간 | O(2^N × N²) | 상태 2^N × N개, 각 상태에서 다음 도시 N개 시도 |
| 공간 | O(2^N × N) | 메모이제이션 표 |

N=16이면 약 1,600만 연산으로 통과하고, N=20이면 4억을 넘겨 어렵습니다. **집합을 상태로 쓰는 DP는 N ≤ 20이 사실상 상한입니다.**

## 주의사항

- **연산자 우선순위**: `visited & (1 << i) != 0`은 `!=`가 먼저 묶여 틀린다. `(visited & (1 << i)) != 0`으로 괄호를 반드시 쓴다
- **`1 << n` 오버플로**: n이 31 이상이면 int를 넘긴다. `1L << n`을 쓰거나 애초에 상태 수를 줄인다
- **메모 초기값과 유효값 충돌**: 비용 0이 정답일 수 있는 문제에서 `memo`를 0으로 초기화하면 계산 안 된 상태와 구분되지 않는다. −1 같은 불가능한 값으로 초기화한다
- **상태 정의가 핵심**: "무엇을 비트로 표현할지"가 정해지면 나머지는 평범한 [[동적 계획법]]이다. 방문 여부, 선택한 원소, 켜진 스위치 등이 흔한 후보다

## 핵심 정리

- 집합 상태를 정수의 비트로 표현해 DP 상태로 사용
- 핵심 연산: 확인 `mask & (1<<i)`, 추가 `mask | (1<<i)`, 제거 `mask & ~(1<<i)`
- 시간 O(2^N × N²) — **N ≤ 20이 상한**
- 외판원 문제, 집합 분할, 원소 짝짓기 같은 "조합을 다 따져야 하는" 문제에 쓰인다
- 괄호 누락과 메모 초기값이 가장 흔한 버그

→ [[동적 계획법]]
