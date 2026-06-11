**순서가 없고 중복을 허용하지 않는** 자료구조입니다. 고유한 값들의 집합을 관리할 때 사용합니다.

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
Set<String> hashSet       = new HashSet<>();
Set<String> linkedHashSet = new LinkedHashSet<>();
Set<String> treeSet       = new TreeSet<>();
```

## 구현체별 차이

|구현체|순서|성능|용도|
|---|---|---|---|
|**HashSet**|없음|O(1)|기본 선택|
|**LinkedHashSet**|삽입 순서|O(1)|순서 유지가 필요할 때|
|**TreeSet**|정렬 순서|O(log n)|정렬된 상태가 필요할 때|

```java
Set<Integer> hashSet = new HashSet<>();
hashSet.add(3); hashSet.add(1); hashSet.add(2);
// [1, 2, 3] or [3, 1, 2] - 순서 보장 X

Set<Integer> linkedHashSet = new LinkedHashSet<>();
linkedHashSet.add(3); linkedHashSet.add(1); linkedHashSet.add(2);
// [3, 1, 2] - 삽입 순서 유지

Set<Integer> treeSet = new TreeSet<>();
treeSet.add(3); treeSet.add(1); treeSet.add(2);
// [1, 2, 3] - 자동 정렬
```

## 자주 쓰는 메서드

|메서드|용도|시간|
|---|---|---|
|[[Set.add]]|원소 추가|O(1)|
|[[Set.contains]]|원소 존재 확인|O(1)|
|[[Set.remove]]|원소 삭제|O(1)|
|[[Set.size]]|원소 개수|O(1)|
|[[Set.isEmpty]]|비었는지 확인|O(1)|
|[[Set.addAll]]|합집합 (병합)|O(m)|
|[[Set.retainAll]]|교집합|O(n)|
|[[Set.removeAll]]|차집합|O(m)|

## 중복 판단 기준

```java
// equals()와 hashCode() 두 개 모두로 판단
class User {
    String name;

    @Override
    public boolean equals(Object o) { ... }

    @Override
    public int hashCode() { ... }
}

Set<User> users = new HashSet<>();
users.add(new User("홍길동"));
users.add(new User("홍길동"));   // equals/hashCode 재정의 시 중복으로 판단

users.size();   // 1
```

> 두 메서드는 반드시 **함께** 재정의. `equals`만 재정의하면 다른 버킷에 들어가서 중복 검출 실패.

## List vs Set

|항목|List|Set|
|---|---|---|
|순서|O|X|
|중복|O|X|
|인덱스 접근|O|X|
|포함 여부 확인|O(n)|O(1)|

## 자주 쓰는 패턴

### 중복 제거

```java
List<String> list = Arrays.asList("a", "b", "a", "c");
Set<String> unique = new HashSet<>(list);
// unique: [a, b, c]
```

### 고유 종류 수 세기 (폰켓몬)

```java
int[] nums = {3, 1, 2, 3};

Set<Integer> set = new HashSet<>();
for (int num : nums) {
    set.add(num);
}

int distinctCount = set.size();   // 3
```

### 빠른 포함 여부 확인

```java
Set<String> blocked = new HashSet<>(Arrays.asList("user1", "user2"));

if (blocked.contains(userId)) {   // O(1)
    // ...
}
```

### 집합 연산

```java
Set<Integer> a = new HashSet<>(Arrays.asList(1, 2, 3));
Set<Integer> b = new HashSet<>(Arrays.asList(2, 3, 4));

// 합집합
Set<Integer> union = new HashSet<>(a);
union.addAll(b);             // [1, 2, 3, 4]

// 교집합
Set<Integer> intersection = new HashSet<>(a);
intersection.retainAll(b);   // [2, 3]

// 차집합
Set<Integer> difference = new HashSet<>(a);
difference.removeAll(b);     // [1]
```

## 시간복잡도 (HashSet 기준)

|연산|평균|최악|
|---|---|---|
|`add`|O(1)|O(n) / O(log n) (Java 8+ 트리화)|
|`contains`|O(1)|O(n) / O(log n)|
|`remove`|O(1)|O(n) / O(log n)|
|`size`|O(1)|O(1)|

## 핵심 정리

Set은 **중복을 허용하지 않는 집합 자료구조**로, 가장 자주 쓰이는 구현체는 [[HashMap]]을 내부적으로 사용하는 **HashSet**입니다. 평균 O(1)에 추가·조회·삭제가 가능하고, 알고리즘에서는 **중복 제거 / 빠른 포함 여부 확인 / 집합 연산**에 자주 사용됩니다. 객체를 저장할 때는 `equals()`와 `hashCode()`를 함께 재정의해야 중복 판정이 정확하게 동작합니다. 순서가 필요하면 LinkedHashSet, 정렬 상태가 필요하면 TreeSet을 사용합니다.
