---
title: "LCS"
tags: [DP, 문자열]
status: published
---

두 수열에서 순서를 유지하면서 양쪽에 공통으로 등장하는 가장 긴 부분 수열(Longest Common Subsequence)을 찾는 문제입니다.

연속이어야 하는 부분 **문자열**(substring)과 달리, 부분 **수열**(subsequence)은 중간을 건너뛸 수 있습니다. `ACAYKP`와 `CAPCAK`의 LCS는 `ACAK`로 길이 4입니다.

## 동작 과정

`dp[i][j]` = A의 앞 i글자와 B의 앞 j글자의 LCS 길이.

```
A = "ACAYKP", B = "CAPCAK"

        ""  C  A  P  C  A  K
    "" [ 0  0  0  0  0  0  0 ]
    A  [ 0  0  1  1  1  1  1 ]
    C  [ 0  1  1  1  2  2  2 ]
    A  [ 0  1  2  2  2  3  3 ]
    Y  [ 0  1  2  2  2  3  3 ]
    K  [ 0  1  2  2  2  3  4 ]
    P  [ 0  1  2  3  3  3  4 ]
                            ↑ 답 = 4

칸을 채우는 규칙:
  A[i] == B[j]  → dp[i][j] = dp[i-1][j-1] + 1      (대각선 + 1)
  A[i] != B[j]  → dp[i][j] = max(dp[i-1][j], dp[i][j-1])  (위 또는 왼쪽 중 큰 값)

예: i=3(A), j=5(A) → 문자 일치
    dp[3][5] = dp[2][4] + 1 = 2 + 1 = 3

예: i=4(Y), j=5(A) → 불일치
    dp[4][5] = max(dp[3][5], dp[4][4]) = max(3, 2) = 3
```

문자가 같으면 양쪽에서 한 글자씩 소비해 LCS를 1 늘리고, 다르면 한쪽만 한 글자 포기했을 때의 더 좋은 쪽을 가져옵니다.

## 구현

```java
int lcs(String a, String b) {
    int n = a.length(), m = b.length();
    int[][] dp = new int[n + 1][m + 1];

    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= m; j++) {
            if (a.charAt(i - 1) == b.charAt(j - 1)) {
                dp[i][j] = dp[i - 1][j - 1] + 1;
            } else {
                dp[i][j] = Math.max(dp[i - 1][j], dp[i][j - 1]);
            }
        }
    }
    return dp[n][m];
}
```

```java
// LCS 문자열 자체를 복원 — 표의 오른쪽 아래에서 거꾸로 추적
String reconstruct(String a, String b, int[][] dp) {
    StringBuilder sb = new StringBuilder();
    int i = a.length(), j = b.length();

    while (i > 0 && j > 0) {
        if (a.charAt(i - 1) == b.charAt(j - 1)) {
            sb.append(a.charAt(i - 1));   // 대각선에서 왔다 = LCS에 포함
            i--; j--;
        } else if (dp[i - 1][j] >= dp[i][j - 1]) {
            i--;                          // 위에서 왔다
        } else {
            j--;                          // 왼쪽에서 왔다
        }
    }
    return sb.reverse().toString();
}
```

## 복잡도

| 구분 | 복잡도 | 근거 |
|---|---|---|
| 시간 | O(NM) | 표의 모든 칸을 한 번씩 채움 |
| 공간 | O(NM) | 2차원 표. 길이만 필요하면 두 행만 번갈아 써서 O(min(N,M))으로 줄일 수 있다 |

## 주의사항

- **인덱스 오프셋**: `dp`는 1부터 쓰고 문자열은 0부터 접근하므로 `charAt(i-1)`이다. 여기서 한 칸 밀리는 실수가 가장 흔하다
- **부분 문자열과 혼동**: 연속 구간을 요구하는 문제라면 점화식이 다르다(불일치 시 0으로 초기화). 문제가 "부분 수열"인지 "부분 문자열"인지 먼저 확인한다
- **복원하려면 표가 필요**: 공간을 O(N)으로 줄이면 길이만 알 수 있고 LCS 문자열은 복원할 수 없다
- **[[LIS]]와 다른 문제**: LIS는 한 수열 안에서의 증가 부분 수열이고, LCS는 두 수열의 공통 부분 수열이다

## 핵심 정리

- 두 수열의 공통 부분 수열 중 최장 길이 — 순서만 지키면 건너뛰기 가능
- 점화식: 일치하면 대각선 +1, 불일치하면 위·왼쪽 중 max
- 시간 O(NM), 공간 O(NM) (길이만 필요하면 O(min(N,M)))
- 표를 거꾸로 추적하면 LCS 문자열 자체를 복원할 수 있다

→ [[동적 계획법]]
