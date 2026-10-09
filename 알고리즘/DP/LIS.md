---
title: "LIS"
tags: [DP, 이진탐색]
status: published
---

한 수열에서 순서를 유지하며 값이 계속 증가하는 가장 긴 부분 수열(Longest Increasing Subsequence)을 찾는 문제입니다.

## 동작 과정

### O(N²) DP

`dp[i]` = i번째 원소를 마지막으로 하는 LIS의 길이.

```
A = [10, 20, 10, 30, 20, 50]

i=0 (10): 앞에 없음                      dp[0]=1
i=1 (20): 10 < 20 → dp[0]+1=2            dp[1]=2
i=2 (10): 10 < 10 아님, 20 < 10 아님      dp[2]=1
i=3 (30): 10<30(2), 20<30(3), 10<30(2)    dp[3]=3
i=4 (20): 10<20(2), 10<20(2)              dp[4]=2
i=5 (50): 10(2),20(3),10(2),30(4),20(3)   dp[5]=4

dp = [1, 2, 1, 3, 2, 4]  → 답 = max(dp) = 4
LIS 중 하나: 10 → 20 → 30 → 50
```

### O(N log N) — [[이진 탐색]]

"길이 k인 증가 부분 수열의 **마지막 값 최솟값**"을 배열 `tails`로 관리합니다.

```
A = [10, 20, 10, 30, 20, 50]

10 → tails=[10]                    (새 길이 1)
20 → 20 > 10 이므로 뒤에 붙임
     tails=[10, 20]                (새 길이 2)
10 → 10 이상인 첫 위치(index 0)를 교체
     tails=[10, 20]                (길이 변화 없음, 10으로 갱신)
30 → 30 > 20 이므로 뒤에 붙임
     tails=[10, 20, 30]            (새 길이 3)
20 → 20 이상인 첫 위치(index 1)를 교체
     tails=[10, 20, 30]            (20 → 20, 변화 없음)
50 → 50 > 30 이므로 뒤에 붙임
     tails=[10, 20, 30, 50]        (새 길이 4)

답 = tails.length = 4
```

`tails`는 항상 정렬 상태를 유지하므로 삽입 위치를 [[이진 탐색]]으로 찾을 수 있습니다. **`tails` 자체는 실제 LIS가 아니라 길이만 보장합니다.**

## 구현

```java
// O(N²) — 어떤 LIS인지 복원하기 쉽다
int lisDp(int[] a) {
    int n = a.length;
    int[] dp = new int[n];
    Arrays.fill(dp, 1);

    for (int i = 1; i < n; i++) {
        for (int j = 0; j < i; j++) {
            if (a[j] < a[i]) {
                dp[i] = Math.max(dp[i], dp[j] + 1);
            }
        }
    }
    return Arrays.stream(dp).max().orElse(0);
}
```

```java
// O(N log N) — 길이만 필요할 때
int lisBinarySearch(int[] a) {
    int[] tails = new int[a.length];
    int size = 0;

    for (int x : a) {
        // tails[0..size)에서 x가 들어갈 위치 탐색
        int lo = 0, hi = size;
        while (lo < hi) {
            int mid = (lo + hi) >>> 1;
            if (tails[mid] < x) lo = mid + 1;   // 엄격히 증가
            else hi = mid;
        }
        tails[lo] = x;
        if (lo == size) size++;
    }
    return size;
}
```

`Arrays.binarySearch`는 값이 없을 때 `-(삽입위치)-1`을 주므로 그대로 쓰기 번거롭습니다. 위처럼 lower bound를 직접 구현하는 편이 명확합니다 — [[Arrays]] 참고.

## 복잡도

| 구현 | 시간 | 공간 |
|---|---|---|
| DP | O(N²) | O(N) |
| 이진 탐색 | O(N log N) | O(N) |

N이 1,000 이하면 DP로 충분하고, 100,000 수준이면 이진 탐색이 필요합니다.

## 주의사항

- **증가의 정의**: "엄격히 증가"면 `tails[mid] < x`(lower bound), "증가 또는 같음"이면 `tails[mid] <= x`(upper bound)로 비교를 바꿔야 한다. 문제 문장을 먼저 확인한다
- **`tails`는 LIS가 아니다**: 위 예시에서 결과 `[10,20,30,50]`은 우연히 맞지만, 일반적으로는 길이만 보장하고 내용은 실제 LIS가 아닐 수 있다. 수열 자체가 필요하면 각 원소의 길이를 따로 기록해 역추적한다
- **최장 감소 부분 수열**: 배열을 뒤집거나 부호를 반전해 같은 알고리즘을 그대로 쓴다
- **[[LCS]]와 혼동**: LIS는 한 수열 내부, LCS는 두 수열 사이의 문제다

## 핵심 정리

- 한 수열의 최장 증가 부분 수열
- DP는 O(N²)이고 복원이 쉽다. 이진 탐색은 O(N log N)이고 길이만 보장한다
- 이진 탐색 방식은 "길이 k인 수열의 마지막 값 최솟값"을 관리하는 것이 핵심
- 엄격 증가 / 비감소에 따라 lower bound와 upper bound를 바꿔 쓴다

→ [[동적 계획법]]
