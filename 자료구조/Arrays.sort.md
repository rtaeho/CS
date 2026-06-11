[[Arrays]]의 **배열을 정렬**하는 정적 메서드. 기본은 **오름차순**, `Comparator`를 넘기면 커스텀 정렬 가능합니다.

## 시그니처

```java
// 원시 타입 배열
static void sort(int[] arr)
static void sort(int[] arr, int fromIndex, int toIndex)

// 객체 배열
static <T> void sort(T[] arr)
static <T> void sort(T[] arr, Comparator<? super T> c)
```

## 동작 추적

```java
int[] arr = {3, 1, 4, 1, 5, 9, 2, 6};
```

```
[ 초기 상태 ]
arr: [3, 1, 4, 1, 5, 9, 2, 6]
```

```java
Arrays.sort(arr);
```

```
[ 변경 후 ]
arr: [1, 1, 2, 3, 4, 5, 6, 9]   ← 오름차순 (in-place)
```

> Arrays.sort는 **반환값이 없음** (`void`). 입력 배열을 직접 수정합니다.

## 원시 타입 vs 객체 타입

```java
int[]     primitive = {3, 1, 2};
Integer[] boxed     = {3, 1, 2};
String[]  words     = {"banana", "apple", "cherry"};

Arrays.sort(primitive);   // dual-pivot 퀵소트
Arrays.sort(boxed);       // 팀소트
Arrays.sort(words);       // 팀소트
```

|타입|내부 알고리즘|평균|최악|안정성|
|---|---|---|---|---|
|`int[]`, `long[]` 등|dual-pivot 퀵소트|O(n log n)|O(n²)|X|
|`Object[]`|팀소트|O(n log n)|O(n log n)|O|

## 사전식 정렬 (String 배열)

```java
String[] phoneBook = {"119", "97674223", "1195524421"};
```

```
[ 초기 상태 ]
phoneBook: ["119", "97674223", "1195524421"]
```

```java
Arrays.sort(phoneBook);
```

```
[ 동작 ]
사전식(lexicographic) 비교 — 한 글자씩 ASCII/유니코드 값 비교
'1'(49) < '9'(57) → "119"와 "1195524421"이 "97674223"보다 앞

[ 변경 후 ]
phoneBook: ["119", "1195524421", "97674223"]
                     ↑ 119가 1195524421의 접두사 → 정렬 후 바로 옆에 위치
```

> 사전식 정렬은 **숫자 정렬과 다름**. `"10"`은 `"2"`보다 먼저 옴 (`'1' < '2'`).

## 자주 쓰는 패턴

### 정렬 후 인접 비교

```java
// 중복 검사
int[] arr = {3, 1, 2, 3, 4};
Arrays.sort(arr);
// [1, 2, 3, 3, 4]

for (int i = 1; i < arr.length; i++) {
    if (arr[i] == arr[i-1]) {
        return true;   // 중복 발견
    }
}
```

```
[ 단계별 추적 ]

[1, 2, 3, 3, 4]
 ^  ^                       1 != 2
    ^  ^                    2 != 3
       ^  ^                 3 == 3 → 중복!
```

### 정렬 후 인접 비교 (전화번호 목록)

```java
String[] phoneBook = {"119", "97674223", "1195524421"};
Arrays.sort(phoneBook);

for (int i = 0; i < phoneBook.length - 1; i++) {
    if (phoneBook[i+1].startsWith(phoneBook[i])) {
        return false;
    }
}
```

```
[ 단계별 추적 ]

정렬 후: ["119", "1195524421", "97674223"]

i=0: "1195524421".startsWith("119") → true → return false
```

### 부분 정렬

```java
int[] arr = {5, 4, 3, 2, 1};
Arrays.sort(arr, 1, 4);   // 인덱스 1~3만 정렬
```

```
[ 변경 후 ]
arr: [5, 2, 3, 4, 1]   ← 0과 4는 그대로, 가운데만 정렬
```

### Comparator로 커스텀 정렬

```java
Integer[] arr = {3, 1, 4, 1, 5, 9, 2};

// 내림차순
Arrays.sort(arr, (a, b) -> b - a);
```

```
[ 변경 후 ]
arr: [9, 5, 4, 3, 2, 1, 1]
```

```java
// 문자열 길이 기준
String[] words = {"banana", "apple", "kiwi"};
Arrays.sort(words, (a, b) -> a.length() - b.length());
```

```
[ 변경 후 ]
words: ["kiwi", "apple", "banana"]   ← 길이 4, 5, 6
```

> `int[]`에는 Comparator를 못 씀. 내림차순이나 커스텀 정렬이 필요하면 `Integer[]`로 박싱해야 함.
> Comparator 자세한 내용은 [[Comparator]] 참고.

## 시간복잡도

|배열 타입|평균|최악|공간|
|---|---|---|---|
|`int[]` 등 원시|O(n log n)|O(n²)|O(log n)|
|`Object[]`|O(n log n)|O(n log n)|O(n)|

## 주의: int[] 정렬은 불안정

```java
// int 배열은 안정성 없음 — 같은 값들의 원래 순서가 보장 안 됨
// 하지만 int는 값이 같으면 구별 불가능하므로 보통 문제 안 됨

// 객체 배열은 안정성 보장
Person[] people = ...;
Arrays.sort(people, byAge);    // 같은 나이면 입력 순서 유지
```
