---
title: "String.startsWith"
tags: [문자열, 탐색]
status: published
---

[[String]]이 **특정 문자열로 시작하는지** 확인합니다.

## 시그니처

```java
boolean startsWith(String prefix)
boolean startsWith(String prefix, int offset)   // offset 위치부터 검사
```

|반환값|의미|
|---|---|
|`true`|`prefix`로 시작함|
|`false`|시작하지 않음|

## 동작 추적

```java
String s = "1195524421";
```

```
[ 상태 ]
s: "1195524421"
```

```java
s.startsWith("119");      // true   ← "119"로 시작
s.startsWith("1195");     // true   ← "1195"로 시작
s.startsWith("11955");    // true
s.startsWith("123");      // false  ← "12..."로 시작 안 함
s.startsWith("");         // true   ← 빈 문자열은 항상 true
s.startsWith("11955244210"); // false ← prefix가 더 김
```

```
[ 변경 후 ]
s: "1195524421"   ← 변화 없음 (조회만)
```

## offset 버전

```java
String s = "abc123def";
```

```java
s.startsWith("123", 3);    // true   ← 인덱스 3부터 "123"으로 시작
s.startsWith("def", 6);    // true   ← 인덱스 6부터 "def"로 시작
s.startsWith("123", 0);    // false  ← 인덱스 0은 "abc..."
```

```
[ 시각화 ]

s = "abc123def"
     0123456789
       ↑ offset=3
       │
       ↓
       "123def"  ← 이 부분이 "123"으로 시작? → true
```

## 자주 쓰는 패턴

### 정렬 후 인접 접두사 검사 (전화번호 목록)

```java
String[] phoneBook = {"119", "97674223", "1195524421"};
Arrays.sort(phoneBook);
```

```
[ 정렬 후 ]
phoneBook: ["119", "1195524421", "97674223"]
```

```java
for (int i = 0; i < phoneBook.length - 1; i++) {
    if (phoneBook[i+1].startsWith(phoneBook[i])) {
        return false;
    }
}
return true;
```

```
[ 단계별 추적 ]

i=0:
  phoneBook[1].startsWith(phoneBook[0])
  "1195524421".startsWith("119")
  → true → return false
```

### 접두사로 필터링

```java
List<String> emails = Arrays.asList(
    "alice@gmail.com", "bob@naver.com", "charlie@gmail.com"
);

List<String> gmail = emails.stream()
    .filter(e -> e.endsWith("@gmail.com"))
    .collect(Collectors.toList());

// 또는 시작 문자열로 필터
List<String> startsWithA = emails.stream()
    .filter(e -> e.startsWith("a"))
    .collect(Collectors.toList());
```

### URL 라우팅

```java
String path = "/api/users/123";

if (path.startsWith("/api/")) {
    // API 요청 처리
} else if (path.startsWith("/static/")) {
    // 정적 파일 처리
}
```

## 다른 방법과의 비교

```java
String s = "1195524421";
String prefix = "119";

// 1. startsWith — 가장 명확
s.startsWith(prefix);    // true, O(prefix.length)

// 2. substring + equals — 비효율적 (새 객체 생성)
s.substring(0, prefix.length()).equals(prefix);   // 같은 결과지만 객체 1번 더 생성

// 3. indexOf — 의미 다름 (어디든 포함)
s.indexOf(prefix) == 0;  // 같은 의미지만 전체 스캔할 수도 있음
```

## 시간복잡도

|연산|복잡도|
|---|---|
|`startsWith(prefix)`|O(m) (m = prefix 길이)|
|`startsWith(prefix, offset)`|O(m)|

> 전체 문자열을 스캔하지 않음 — prefix 길이만큼만 비교 후 차이 발견 시 즉시 반환.
