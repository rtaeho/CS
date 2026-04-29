[[Set]]에 **특정 원소가 존재하는지** 확인합니다.

## 시그니처

```java
boolean contains(Object o)
```

## 동작 추적

```java
Set<String> set = new HashSet<>();
set.add("apple");
set.add("banana");
```

```
[ 초기 상태 ]
set: [apple, banana]
```

```java
set.contains("apple");    // true
set.contains("grape");    // false
```

```
[ 변경 후 ]
set: [apple, banana]   ← 변화 없음 (조회만)
```

## 왜 Set인가? — List vs Set

```
[ List에서 contains ]
List<String> list = ...;
list.contains("apple");   // O(n) - 처음부터 끝까지 선형 탐색

[ Set에서 contains ]
Set<String> set = ...;
set.contains("apple");    // O(1) - 해시 조회
```

> **포함 여부를 자주 확인**할 데이터는 List 대신 Set에 저장.

```
n = 100,000 기준:
List: 평균 50,000번 비교
Set:  1번 해시 조회

→ contains를 자주 호출하는 코드에서 1000배+ 빠름
```

## 자주 쓰는 패턴

### 차단/허용 목록 검사

```java
Set<String> blocked = new HashSet<>(Arrays.asList("user1", "user2"));
```

```
[ 초기 상태 ]
blocked: [user1, user2]
```

```java
if (blocked.contains(userId)) {
    throw new AccessDeniedException();
}
```

### 중복 검사

```java
String[] arr = {"a", "b", "a", "c"};

Set<String> seen = new HashSet<>();
for (String s : arr) {
    if (seen.contains(s)) {
        // 중복!
        return s;
    }
    seen.add(s);
}
```

```
[ 단계별 추적 ]

초기:                                   seen: [ ]

"a" → contains? false → add           seen: [a]
"b" → contains? false → add           seen: [a, b]
"a" → contains? true  → 중복 발견!     seen: [a, b]
```

> `contains` + `add` 패턴은 [[Set.add]]의 반환값으로 한 번에 처리 가능 — 그게 더 효율적:
> ```java
> if (!seen.add(s)) { return s; }   // add가 false면 중복
> ```

### 두 컬렉션의 공통 원소 찾기

```java
int[] a = {1, 2, 3, 4, 5};
int[] b = {3, 4, 5, 6, 7};

Set<Integer> setA = new HashSet<>();
for (int n : a) setA.add(n);
```

```
[ 초기 상태 ]
setA: [1, 2, 3, 4, 5]
```

```java
List<Integer> common = new ArrayList<>();
for (int n : b) {
    if (setA.contains(n)) {
        common.add(n);
    }
}
// common: [3, 4, 5]
```

```
[ 단계별 추적 ]

3 → setA.contains? true  → common: [3]
4 → setA.contains? true  → common: [3, 4]
5 → setA.contains? true  → common: [3, 4, 5]
6 → setA.contains? false
7 → setA.contains? false
```

## 시간복잡도

|평균|최악|
|---|---|
|O(1)|O(n) / O(log n) (Java 8+ 트리화)|
