---
title: "Set.add"
tags: [자료구조, 컬렉션, Set]
status: published
---

[[Set]]에 원소를 추가합니다. **이미 존재하면 무시**하고, 추가 여부를 boolean으로 반환합니다.

## 시그니처

```java
boolean add(E e)
```

|반환값|의미|
|---|---|
|`true`|새로 추가됨 (Set이 변경됨)|
|`false`|이미 존재 → 무시 (Set 변화 없음)|

## 동작 추적

```java
Set<Integer> set = new HashSet<>();
```

```
[ 초기 상태 ]
set: [ ]
```

### 새 원소 추가

```java
boolean added = set.add(3);
// added = true
```

```
[ 변경 후 ]
set: [3]
```

```java
set.add(1);
set.add(2);
```

```
[ 변경 후 ]
set: [1, 2, 3]   ← 순서는 보장 X (HashSet 기준)
```

### 이미 존재하는 원소 추가

```java
boolean added = set.add(3);
// added = false   ← 무시됨
```

```
[ 변경 후 ]
set: [1, 2, 3]   ← 변화 없음
```

## 자주 쓰는 패턴

### 중복 제거하며 누적 (폰켓몬)

```java
int[] nums = {3, 1, 2, 3, 2};

Set<Integer> set = new HashSet<>();
for (int num : nums) {
    set.add(num);
}
```

```
[ 단계별 추적 ]

초기:                         [ ]

add(3) → true:                [3]
add(1) → true:                [3, 1]
add(2) → true:                [3, 1, 2]
add(3) → false (이미 있음):    [3, 1, 2]   ← 변화 없음
add(2) → false (이미 있음):    [3, 1, 2]   ← 변화 없음

→ set.size() = 3 (고유 종류 수)
```

### 반환값으로 첫 등장 판별 (중복 검사)

```java
Set<String> seen = new HashSet<>();

for (String s : arr) {
    if (!seen.add(s)) {
        // add가 false → 이미 있던 값 = 중복!
        return s;
    }
}
```

```
[ 동작 원리 ]

seen.add("apple")  → true   (새로 추가)   [apple]
seen.add("banana") → true   (새로 추가)   [apple, banana]
seen.add("apple")  → false  (이미 있음 → 중복 발견!)
```

> `contains` 후 `add` 두 번 호출하는 대신 `add`의 반환값 하나로 처리하는 패턴. 해시 조회 한 번만 발생해서 더 효율적.

### 컬렉션 → Set 변환 (생성자 활용)

```java
List<String> list = Arrays.asList("a", "b", "a", "c");
Set<String> unique = new HashSet<>(list);
// 내부적으로 list 순회하며 add 호출 → 중복 자동 제거
```

```
[ 동작 ]
new HashSet<>(list):
  - "a" add → [a]
  - "b" add → [a, b]
  - "a" add → 무시 [a, b]
  - "c" add → [a, b, c]
```

## 객체 저장 시 주의

```java
class User {
    String name;
    User(String n) { name = n; }
}

Set<User> users = new HashSet<>();
users.add(new User("홍길동"));
users.add(new User("홍길동"));

users.size();   // 2 ← 중복으로 판단 안 됨!
```

```
[ 이유 ]
equals/hashCode를 재정의하지 않으면
두 User 객체는 메모리 주소가 다른 별개의 객체로 인식

→ 중복 판단을 위해서는 equals + hashCode 함께 재정의 필수
```

## 시간복잡도

|평균|최악|
|---|---|
|O(1)|O(n) / O(log n) (Java 8+ 트리화)|
