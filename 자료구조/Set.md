순서가 없고 중복을 허용하지 않는 자료구조입니다. 고유한 값들의 집합을 관리할 때 사용합니다.

## 특징

|항목|설명|
|---|---|
|순서|없음 (인덱스 없음)|
|중복|허용 안 함|
|크기|가변 (동적)|

## Java에서의 Set

```java
// 인터페이스
Set<String> set;

// 주요 구현체
Set<String> hashSet = new HashSet<>();
Set<String> linkedHashSet = new LinkedHashSet<>();
Set<String> treeSet = new TreeSet<>();
```

## 구현체별 차이

|구현체|순서|정렬|성능|
|---|---|---|---|
|**HashSet**|없음|없음|O(1) 가장 빠름|
|**LinkedHashSet**|삽입 순서 유지|없음|O(1)|
|**TreeSet**|정렬 순서|자동 정렬|O(log n)|

```java
Set<Integer> hashSet = new HashSet<>();
hashSet.add(3); hashSet.add(1); hashSet.add(2);
// [1, 2, 3] or [3, 1, 2] - 순서 보장 안 됨

Set<Integer> linkedHashSet = new LinkedHashSet<>();
linkedHashSet.add(3); linkedHashSet.add(1); linkedHashSet.add(2);
// [3, 1, 2] - 삽입 순서 유지

Set<Integer> treeSet = new TreeSet<>();
treeSet.add(3); treeSet.add(1); treeSet.add(2);
// [1, 2, 3] - 자동 정렬
```

## 기본 사용법

```java
Set<String> names = new HashSet<>();

// 추가
names.add("홍길동");
names.add("김철수");
names.add("홍길동");  // 무시됨 (중복 불가)

// 크기
names.size();  // 2

// 포함 여부
names.contains("홍길동");  // true

// 삭제
names.remove("홍길동");

// 비어있는지
names.isEmpty();
```

## 중복 판단 기준

```java
// equals()와 hashCode()로 판단
class User {
    String name;
    
    @Override
    public boolean equals(Object o) { ... }
    
    @Override
    public int hashCode() { ... }
}

Set<User> users = new HashSet<>();
users.add(new User("홍길동"));
users.add(new User("홍길동"));  // equals/hashCode 재정의 시 중복으로 판단
```

## 집합 연산

```java
Set<Integer> a = new HashSet<>(Arrays.asList(1, 2, 3));
Set<Integer> b = new HashSet<>(Arrays.asList(2, 3, 4));

// 합집합
Set<Integer> union = new HashSet<>(a);
union.addAll(b);  // [1, 2, 3, 4]

// 교집합
Set<Integer> intersection = new HashSet<>(a);
intersection.retainAll(b);  // [2, 3]

// 차집합
Set<Integer> difference = new HashSet<>(a);
difference.removeAll(b);  // [1]
```

## List vs Set

|항목|List|Set|
|---|---|---|
|순서|O|X|
|중복|O|X|
|인덱스 접근|O|X|
|포함 여부 확인|O(n)|O(1)|

## 언제 사용하나?

```java
// 중복 제거
List<String> list = Arrays.asList("a", "b", "a", "c");
Set<String> unique = new HashSet<>(list);  // [a, b, c]

// 포함 여부 빠른 확인
Set<String> blockedUsers = new HashSet<>();
if (blockedUsers.contains(userId)) { ... }

// 고유 값 관리
Set<String> tags = new HashSet<>();
```