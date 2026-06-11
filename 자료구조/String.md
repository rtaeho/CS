**문자(char)들의 시퀀스를 다루는 불변(immutable) 객체**입니다. Java에서 가장 많이 쓰이는 클래스 중 하나.

## 불변(Immutable)이란

```
String s = "hello";
s = s + " world";    // 기존 "hello"가 변하는 게 아니라
                     //   새로운 "hello world" 객체가 생성되고
                     //   변수 s가 그쪽을 가리킴

[ 메모리 ]
"hello"            ← 그대로 남음 (다른 곳에서 참조 가능)
"hello world"      ← 새로 생성

→ 문자열을 자주 변경한다면 StringBuilder 사용 (가변)
```

## 자주 쓰는 메서드

|메서드|용도|
|---|---|
|[[String.startsWith]]|특정 문자열로 시작하는지|
|`endsWith`|특정 문자열로 끝나는지|
|[[String.charAt]]|i번째 문자|
|[[String.length]]|문자열 길이|
|`substring(start, end)`|부분 문자열 추출|
|`indexOf` / `lastIndexOf`|특정 문자/문자열의 위치|
|`equals` / `equalsIgnoreCase`|내용 비교|
|`compareTo`|사전식 비교 (정렬용)|
|`split(regex)`|구분자로 분리|
|`replace`|문자/문자열 치환|
|`toCharArray()`|`char[]` 배열로 변환|
|`toLowerCase` / `toUpperCase`|대소문자 변환|
|`trim` / `strip`|앞뒤 공백 제거|
|`contains`|특정 문자열 포함 여부|
|`isEmpty` / `isBlank`|빈 문자열 / 공백만 있는지|

## 정적 메서드

|메서드|용도|
|---|---|
|`String.valueOf(x)`|숫자 등을 문자열로|
|`String.format(fmt, args)`|포맷 문자열 생성|
|`String.join(delim, ...)`|배열/컬렉션 → 문자열|

## 문자열 비교: == vs equals

```java
String a = "hello";
String b = "hello";
String c = new String("hello");

a == b           // true  ← 문자열 풀 (literal pool) 공유
a == c           // false ← 새 객체 생성
a.equals(c)      // true  ← 내용 비교

→ 문자열 비교는 항상 .equals() 사용
```

## 문자열 풀 (String Pool)

```
"hello" 같은 리터럴은 String Pool에 한 번만 생성:

String a = "hello";    ┐
String b = "hello";    ├─ 같은 객체 참조
String c = "hello";    ┘

new String("hello")    ← 풀과 별개로 새 객체 생성

→ 메모리 효율을 위해 리터럴 사용 권장
```

## 자주 쓰는 패턴

### 사전식 정렬 후 인접 비교

```java
String[] arr = {"119", "97674223", "1195524421"};
Arrays.sort(arr);
// ["119", "1195524421", "97674223"]
//   ↑ "119"가 "1195524421"의 접두사 → 인접 위치
```

### 문자별 순회

```java
String s = "hello";

for (int i = 0; i < s.length(); i++) {
    char c = s.charAt(i);
    // ...
}

// 또는 char[] 변환
for (char c : s.toCharArray()) {
    // ...
}
```

### 분리하여 토큰 처리

```java
String csv = "apple,banana,cherry";
String[] tokens = csv.split(",");
// ["apple", "banana", "cherry"]
```

## String vs StringBuilder vs StringBuffer

|항목|String|StringBuilder|StringBuffer|
|---|---|---|---|
|가변성|불변|가변|가변|
|`+` 연산|매번 새 객체 생성|append (in-place)|append (in-place)|
|스레드 안전|O (불변이므로)|X|O (synchronized)|
|반복 누적 시간|O(n²)|O(n)|O(n)|
|언제 쓰는가|짧은 문자열, 비교용|단일 스레드에서 반복 누적|멀티스레드 환경|

> 실무에서는 멀티스레드 환경에서도 문자열 빌더를 지역 변수로 사용하므로 StringBuffer보다 StringBuilder를 압도적으로 많이 씀.

```java
// X 반복문에서 String + 사용 → O(n²)
String result = "";
for (int i = 0; i < n; i++) result += i;

// O StringBuilder 사용 → O(n)
StringBuilder sb = new StringBuilder();
for (int i = 0; i < n; i++) sb.append(i);
String result = sb.toString();
```

## 시간복잡도

|연산|복잡도|
|---|---|
|`charAt(i)`|O(1)|
|`length()`|O(1)|
|`substring`|O(n) — 새 객체 생성 (Java 7+)|
|`equals`|O(n)|
|`indexOf`|O(n × m) (n=긴 쪽, m=찾는 쪽)|
|`startsWith`|O(m) (찾는 쪽 길이만)|
|`+` 연산|O(n)|

## 핵심 정리

`String`은 자바의 **불변 객체**로, 한 번 생성된 문자열은 변경되지 않고 새 객체가 만들어집니다. 비교는 항상 `.equals()`를 사용해야 하며 (`==`은 참조 비교), 반복적으로 문자열을 누적할 때는 시간복잡도 O(n²)를 피하기 위해 StringBuilder를 사용합니다. 알고리즘 문제에서는 `charAt`, `length`, `substring`, `startsWith`, `split`, `toCharArray` 등이 자주 등장합니다.
