[[Arrays]]의 **배열의 특정 범위를 잘라 새 배열로 반환**하는 정적 메서드입니다.

## 시그니처

```java
int[] Arrays.copyOfRange(int[] original, int from, int to)
```

- `from`: 시작 인덱스 (포함)
- `to`: 끝 인덱스 (미포함)
- 원본 배열은 변경되지 않음
- `to`가 원본 길이를 초과하면 나머지는 기본값(0, null)으로 채움

## 동작 추적

```java
int[] arr = {1, 2, 3, 4, 5};

Arrays.copyOfRange(arr, 1, 4);  // [2, 3, 4]
Arrays.copyOfRange(arr, 0, 3);  // [1, 2, 3]
Arrays.copyOfRange(arr, 2, 7);  // [3, 4, 5, 0, 0] (초과분은 0 채움)
```

## String 배열도 동일

```java
String[] strs = {"a", "b", "c", "d"};
Arrays.copyOfRange(strs, 1, 3);  // ["b", "c"]
```

## 시간복잡도

| 연산 | 복잡도 |
|---|---|
| 복사 | O(n) — 범위 길이만큼 |

## Arrays.copyOf와 비교

| | `copyOf` | `copyOfRange` |
|---|---|---|
| 범위 | 처음부터 지정 길이까지 | 인덱스 범위 지정 |
| 시그니처 | `copyOf(arr, newLength)` | `copyOfRange(arr, from, to)` |

```java
int[] arr = {1, 2, 3, 4, 5};

Arrays.copyOf(arr, 3);           // [1, 2, 3]
Arrays.copyOfRange(arr, 0, 3);   // [1, 2, 3] — 동일
Arrays.copyOfRange(arr, 2, 5);   // [3, 4, 5] — 중간부터 가능
```

→ [[Arrays]]
