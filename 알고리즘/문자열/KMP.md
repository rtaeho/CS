---
title: "KMP"
tags: [문자열, 패턴매칭]
status: published
---

패턴 자신의 접두사-접미사 일치 정보(실패 함수)를 미리 계산해, 불일치가 나도 이미 비교한 문자를 다시 비교하지 않고 문자열에서 패턴을 찾는 알고리즘입니다.

## 동작 과정

### 1단계: 실패 함수(pi 배열) 계산

패턴 자신을 패턴과 비교해, 각 위치에서 "불일치 시 되돌아갈 위치"를 미리 구합니다. `pi[i]`는 `pattern[0..i]`의 접두사와 접미사가 겹치는 최대 길이입니다.

```
pattern = "ABABC"
            0 1 2 3 4

i=0: pi[0] = 0  (정의상 항상 0)

i=1: pattern[1]='B' vs pattern[j=0]='A' → 불일치, j=0 유지
     pi[1] = 0

i=2: pattern[2]='A' vs pattern[j=0]='A' → 일치, j=1
     pi[2] = 1        ("A" 접두사/접미사 겹침)

i=3: pattern[3]='B' vs pattern[j=1]='B' → 일치, j=2
     pi[3] = 2        ("AB" 접두사/접미사 겹침)

i=4: pattern[4]='C' vs pattern[j=2]='A' → 불일치, j = pi[1] = 0 으로 후퇴
     pattern[4]='C' vs pattern[j=0]='A' → 불일치, j=0 유지
     pi[4] = 0

pi = [0, 0, 1, 2, 0]
```

### 2단계: pi 배열로 텍스트 검색

```
text    = "A B A B A B A B C"
index   =  0 1 2 3 4 5 6 7 8
pattern = "A B A B C"   (pi = [0,0,1,2,0])

i=0 'A' vs pattern[j=0]='A' → 일치, j=1
i=1 'B' vs pattern[j=1]='B' → 일치, j=2
i=2 'A' vs pattern[j=2]='A' → 일치, j=3
i=3 'B' vs pattern[j=3]='B' → 일치, j=4
i=4 'A' vs pattern[j=4]='C' → 불일치, j=pi[3]=2 로 후퇴
     재비교: pattern[j=2]='A' vs 'A' → 일치, j=3
i=5 'B' vs pattern[j=3]='B' → 일치, j=4
i=6 'A' vs pattern[j=4]='C' → 불일치, j=pi[3]=2 로 후퇴
     재비교: pattern[j=2]='A' vs 'A' → 일치, j=3
i=7 'B' vs pattern[j=3]='B' → 일치, j=4
i=8 'C' vs pattern[j=4]='C' → 일치, j=5 = pattern.length → 매칭!

시작 위치 = i - m + 1 = 8 - 5 + 1 = 4
→ text[4..8] = "ABABC"
```

`i=4`에서 불일치가 나도 `i`를 되돌리지 않고 `j`만 `pi` 값으로 후퇴시킵니다. 이미 "AB"까지 일치했다는 정보를 버리지 않기 때문에 텍스트 포인터 `i`는 한 번도 뒤로 가지 않습니다.

## 구현

```java
// 실패 함수(pi 배열) 계산 — pattern[0..i] 접두사/접미사 최대 겹침 길이
int[] buildPi(String pattern) {
    int m = pattern.length();
    int[] pi = new int[m];
    int j = 0;

    for (int i = 1; i < m; i++) {
        while (j > 0 && pattern.charAt(i) != pattern.charAt(j)) {
            j = pi[j - 1];
        }
        if (pattern.charAt(i) == pattern.charAt(j)) {
            j++;
        }
        pi[i] = j;
    }
    return pi;
}

// text에서 pattern이 나타나는 모든 시작 인덱스
List<Integer> kmpSearch(String text, String pattern) {
    List<Integer> result = new ArrayList<>();
    int n = text.length(), m = pattern.length();
    if (m == 0) return result;

    int[] pi = buildPi(pattern);
    int j = 0;

    for (int i = 0; i < n; i++) {
        while (j > 0 && text.charAt(i) != pattern.charAt(j)) {
            j = pi[j - 1];
        }
        if (text.charAt(i) == pattern.charAt(j)) {
            j++;
        }
        if (j == m) {
            result.add(i - m + 1);
            j = pi[j - 1];   // 겹치는 다음 매칭을 계속 찾기 위해 후퇴
        }
    }
    return result;
}
```

## 복잡도

| 구분 | 복잡도 | 근거 |
|---|---|---|
| 시간 (전처리) | O(M) | pi 배열 계산 — `j`가 전체 패턴 길이만큼만 증가 가능 |
| 시간 (검색) | O(N) | 텍스트 포인터 `i`가 되돌아가지 않고 한 번씩만 전진 |
| 전체 시간 | O(N + M) | 전처리와 검색을 합친 값 |
| 공간 | O(M) | pi 배열 |

브루트포스로 매 위치에서 패턴을 처음부터 다시 비교하면 최악 O(NM)이지만, KMP는 불일치 지점까지의 일치 정보를 pi 배열에 재사용해 `i`를 되돌리지 않으므로 항상 O(N+M)이 보장됩니다.

## 주의사항

- **`pi[j - 1]`과 `pi[j]`를 혼동하기 쉽다**: 후퇴할 위치는 "현재까지 일치한 길이(`j`)의 접두사/접미사 겹침"이므로 `pi[j - 1]`이다. `pi[j]`로 쓰면 인덱스가 어긋난다
- **매칭 성공 후에도 `j = pi[j - 1]`로 후퇴해야 한다**: 겹치는 occurrence(예: `pattern="AA"`를 `text="AAAA"`에서 찾는 경우)를 놓치지 않으려면 매칭을 찾은 뒤에도 같은 후퇴 로직을 적용해야 한다
- **pi 배열 계산 자체가 검색 로직과 동일한 패턴**: 패턴을 자기 자신과 매칭시키는 구조라는 것을 이해하면 두 코드가 왜 거의 똑같이 생겼는지 알 수 있다
- 해싱으로 패턴을 찾는 라빈-카프는 평균적으로 비슷하게 빠르지만 해시 충돌이 겹치면 최악 O(NM)이 될 수 있는 반면, KMP는 입력에 상관없이 항상 O(N+M)을 보장한다

## 핵심 정리

- 패턴 자신의 접두사-접미사 겹침 정보(실패 함수, pi 배열)를 전처리해 불일치 시 텍스트 포인터를 되돌리지 않는 문자열 검색 알고리즘
- 전처리 O(M) + 검색 O(N) = O(N+M), 항상 이 복잡도를 보장
- 핵심은 "불일치해도 이미 확인한 문자는 다시 비교하지 않는다"는 것 — pi 배열이 "얼마나 되돌아갈지"를 미리 알려준다
