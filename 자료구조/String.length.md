[[String]]의 **문자 개수(UTF-16 코드 유닛 수)** 를 반환합니다. `String`이 내부적으로 길이를 저장하고 있어 O(1)에 즉시 반환됩니다.

## 시그니처

```java
int length()
```

## 동작 추적

```java
"hello".length();    // 5
"".length();         // 0
"가나다".length();    // 3 (한글도 BMP 내 1 char)
"abc 123".length();  // 7 (공백, 숫자 모두 포함)
```

## 비슷해 보이는 length들

|대상|길이 확인 방법|
|---|---|
|`String`|`s.length()` ← **메서드**|
|배열 (`int[]`, `char[]` 등)|`arr.length` ← **필드, 괄호 없음**|
|`List`, `Set`, `Map`|`.size()` ← 메서드 이름이 다름|

```java
String s = "abc";
int[] arr = {1, 2, 3};
List<Integer> list = List.of(1, 2, 3);

s.length();      // O 메서드 (괄호 있음)
arr.length;      // O 필드 (괄호 없음)
list.size();     // O size, length 아님

s.length;        // X 컴파일 에러
arr.length();    // X 컴파일 에러
```

> 자바에서 가장 자주 헷갈리는 부분. **String은 메서드, 배열은 필드, 컬렉션은 size**.

## 자주 쓰는 패턴

### 인덱스 순회의 종료 조건

```java
String s = "hello";

for (int i = 0; i < s.length(); i++) {
    char c = s.charAt(i);
    // ...
}
```

### length 캐싱 (가독성 + 미세 최적화)

```java
int len = s.length();
for (int i = 0; i < len; i++) {
    if (s.charAt(i) == '(') count++;
    else count--;
}
```

> JIT가 보통 인라인하므로 성능 차이는 미미.
> 본문에서 length를 여러 번 참조하면 변수로 빼는 게 가독성 측면에서 좋음.

### 빈 문자열 검사

```java
if (s.length() == 0) { ... }    // 동작은 같지만
if (s.isEmpty())     { ... }    // O 의도가 명확

if (s.isBlank())     { ... }    // 공백만 있어도 true (Java 11+)
```

|메서드|true 반환 조건|
|---|---|
|`isEmpty()`|길이 0|
|`isBlank()`|길이 0 또는 공백 문자만|

### 양 끝 인덱스 (투포인터)

```java
int l = 0, r = s.length() - 1;   // 마지막 인덱스
while (l < r) {
    if (s.charAt(l) != s.charAt(r)) return false;
    l++; r--;
}
```

### null 안전 길이

```java
int len = (s == null) ? 0 : s.length();   // null이면 0
```

> Java 자체에는 안전 length 메서드 없음. Apache Commons의 `StringUtils.length(s)`는 null 안전.

## 서로게이트 페어 주의

```java
String s = "𝄞";    // U+1D11E (BMP 범위 밖)
s.length();         // 2 ← 코드 유닛 기준!

// 실제 글자 수 (코드 포인트)
s.codePointCount(0, s.length());   // 1
```

> `length`는 UTF-16 **코드 유닛** 수. 이모지·고대 문자는 1글자가 2 코드 유닛.
> ASCII/한글 영역만 다룬다면 신경 쓸 필요 없음 (모두 1 코드 유닛).

## 시간복잡도

|연산|복잡도|
|---|---|
|`length()`|O(1)|

> 내부 필드를 읽기만 함. 매번 호출해도 거의 무료.

## 핵심 정리

`String.length()`는 문자 개수를 O(1)에 반환하는 메서드로, **String은 메서드 호출(괄호 필요), 배열은 필드 접근(괄호 없음), 컬렉션은 size()** 라는 차이를 외워두어야 합니다. 빈 문자열 검사는 `isEmpty()`가 더 명확하고, 이모지를 포함하지 않는 일반 문자열에서는 `length`가 실제 글자 수와 일치한다고 가정해도 됩니다.
