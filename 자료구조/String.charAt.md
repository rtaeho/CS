[[String]]의 **i번째 문자(`char`)** 를 반환합니다. 인덱스 기반 문자 접근의 가장 기본 메서드이며, 대부분의 단일 순회 시나리오에서 `toCharArray()`보다 빠릅니다.

## 시그니처

```java
char charAt(int index)
```

|반환|예외|
|---|---|
|해당 위치의 `char`|`StringIndexOutOfBoundsException` (범위 밖)|

## 동작 추적

```java
String s = "hello";
```

```
[ 인덱스 ]
  s:  h  e  l  l  o
      0  1  2  3  4

s.charAt(0);   // 'h'
s.charAt(2);   // 'l'
s.charAt(4);   // 'o'
s.charAt(5);   // X StringIndexOutOfBoundsException
```

## charAt vs toCharArray — 성능 비교

이게 핵심 포인트입니다. **단일 순회에서는 `charAt`이 빠릅니다.**

```java
String s = "...";   // 길이 n

// 방법 1: charAt
for (int i = 0; i < s.length(); i++) {
    char c = s.charAt(i);
    // ...
}

// 방법 2: toCharArray
for (char c : s.toCharArray()) {
    // ...
}
```

|항목|`charAt`|`toCharArray`|
|---|---|---|
|추가 메모리|0|새 `char[n]` 배열 할당|
|초기 비용|0|O(n) — 전체 복사|
|접근 비용|O(1) per call|O(1) per access|
|JIT 최적화|효과적|배열 접근으로 비슷|
|코드 가독성|인덱스 다룰 때 유리|enhanced-for로 깔끔|

```
[ 메모리 동작 비교 ]

charAt:
  s ──→ "hello"   ← 내부 byte[]에 직접 접근

toCharArray:
  s ──→ "hello"
        │
        ▼ (n개 복사)
  char[] ──→ ['h','e','l','l','o']   ← 새 배열 추가 할당

→ 짧은 문자열은 차이 미미하지만, 길거나 호출이 많으면 charAt 우세
```

> Java 9+부터 `String`은 내부적으로 `byte[]` (LATIN1 또는 UTF16 인코딩)으로 저장됩니다.
> `toCharArray`는 항상 `char[]`로 **디코딩 + 복사**를 해야 하므로 추가 비용이 발생.

### toCharArray가 유리한 경우

```java
char[] arr = s.toCharArray();
Arrays.sort(arr);                    // 직접 정렬
String sorted = new String(arr);     // O char[] 자체를 변형해야 할 때
```

> 문자 순서 변경, 정렬, in-place 수정이 필요할 때만 `toCharArray`.
> **단순 읽기용 순회는 `charAt`이 정답.**

## 자주 쓰는 패턴

### 괄호 짝 맞추기 (스택 카운팅)

```java
boolean solution(String s) {
    int count = 0;
    int len = s.length();   // 미리 캐싱

    for (int i = 0; i < len; i++) {
        if (s.charAt(i) == '(') {
            count++;
        } else {
            if (count == 0) return false;
            count--;
        }
    }
    return count == 0;
}
```

```
[ 추적: s = "(())()" ]

i=0: '('  count: 0 → 1
i=1: '('  count: 1 → 2
i=2: ')'  count: 2 → 1
i=3: ')'  count: 1 → 0
i=4: '('  count: 0 → 1
i=5: ')'  count: 1 → 0

return count == 0 → true
```

### 문자 분류 (대문자/소문자/숫자)

```java
for (int i = 0; i < s.length(); i++) {
    char c = s.charAt(i);
    if (Character.isUpperCase(c)) { ... }
    else if (Character.isDigit(c)) { ... }
}
```

### 양 끝에서 비교 (팰린드롬)

```java
boolean isPalindrome(String s) {
    int l = 0, r = s.length() - 1;
    while (l < r) {
        if (s.charAt(l) != s.charAt(r)) return false;
        l++; r--;
    }
    return true;
}
```

> 양 끝 동시 접근이 필요한 경우 인덱스 기반 `charAt`이 enhanced-for로는 표현 불가능.

### 문자 → 숫자 변환

```java
char c = s.charAt(i);
int digit = c - '0';        // '0'~'9' → 0~9
int alpha = c - 'a';        // 'a'~'z' → 0~25
```

## 주의 사항

### 범위 검사

```java
String s = "abc";
s.charAt(3);   // X StringIndexOutOfBoundsException
s.charAt(-1);  // X 동일
```

> 인덱스는 항상 `0 ≤ i < s.length()` 범위.

### length() 캐싱

```java
// X 매 반복마다 length() 호출 — JIT가 보통 최적화하지만
for (int i = 0; i < s.length(); i++) { ... }

// O 명시적 캐싱 — 의도가 더 명확
int len = s.length();
for (int i = 0; i < len; i++) { ... }
```

> 실제 성능 차이는 거의 없지만, 본문에서 length를 여러 번 쓴다면 캐싱이 가독성도 좋음.

### 서로게이트 페어 (이모지 등)

```java
String s = "𝄞abc";   // 첫 글자가 BMP 범위 밖 (U+1D11E)
s.length();           // 5 — char 단위 길이!
s.charAt(0);          // '\uD834' (high surrogate, 깨진 값)
```

> `charAt`은 UTF-16 코드 유닛 기준. 코드 포인트가 필요하면 `s.codePointAt(i)`.
> 일반 ASCII/한글 영역에서는 신경 쓸 필요 없음.

## 시간복잡도

|연산|복잡도|
|---|---|
|`charAt(i)`|O(1)|
|`toCharArray()`|O(n)|

> `charAt` 자체는 매 호출 O(1)이지만, **n번 호출하면 O(n)** — `toCharArray`로 한 번에 복사하는 비용과 동일한 차수.
> 차이는 **상수 항** (배열 할당 + 복사 vs 직접 접근).

## 핵심 정리

`charAt(i)`은 **인덱스 기반 문자 접근**의 표준 메서드로, JIT 최적화와 추가 메모리 할당이 없는 점 덕분에 단일 순회 시나리오에서 거의 항상 `toCharArray()`보다 빠릅니다. `toCharArray`는 **문자 배열 자체를 변형(정렬, in-place 수정)해야 할 때만** 사용하고, 양 끝 인덱스를 동시에 다루는 팰린드롬·투포인터 같은 패턴에서는 `charAt`이 사실상 유일한 선택지입니다.
