[[List]]에서 **인덱스로 원소를 조회**합니다.

## 시그니처

```java
E get(int index)
```

|매개변수|설명|
|---|---|
|`index`|`0` ~ `size() - 1` 범위|

|예외|발생 조건|
|---|---|
|`IndexOutOfBoundsException`|`index < 0` 또는 `index >= size()`|

## 동작 추적

```java
List<Integer> list = new ArrayList<>(Arrays.asList(10, 20, 30));
```

```
[ 초기 상태 ]
list: [10, 20, 30]
       0   1   2
```

```java
list.get(0);    // 10
list.get(1);    // 20
list.get(2);    // 30
list.get(3);    // X IndexOutOfBoundsException
list.get(-1);   // X IndexOutOfBoundsException
```

```
[ 변경 후 ]
list: [10, 20, 30]   ← 변화 없음 (조회만)
```

## ArrayList vs LinkedList 성능

```
[ ArrayList ]
list.get(i) → 내부 배열의 [i] 접근 → O(1)

[ LinkedList ]
list.get(i) → head부터 i번 따라가야 함 → O(i) → 평균 O(n)
```

```java
// X LinkedList에서 for문 + get 조합 → O(n²)
LinkedList<Integer> list = new LinkedList<>();
// ... 데이터 채움
for (int i = 0; i < list.size(); i++) {
    System.out.println(list.get(i));   // 매번 O(i) → 전체 O(n²)
}

// O for-each는 내부적으로 Iterator 사용 → O(n)
for (int x : list) {
    System.out.println(x);
}
```

> **인덱스 조회가 잦으면 ArrayList**. LinkedList는 `get` 사용 자체를 피해야 함.

## 자주 쓰는 패턴

### 정렬 후 끝/앞 원소

```java
List<Integer> nums = new ArrayList<>(Arrays.asList(3, 1, 4, 1, 5));
nums.sort(null);
// [1, 1, 3, 4, 5]

int min = nums.get(0);                    // 1
int max = nums.get(nums.size() - 1);      // 5
```

### List → 배열 변환 (수동)

```java
ArrayList<Integer> list = new ArrayList<>(Arrays.asList(1, 2, 3));

int[] arr = new int[list.size()];
for (int i = 0; i < list.size(); i++) {
    arr[i] = list.get(i);
}
// arr: [1, 2, 3]
```

> 더 깔끔하게는 [[List.toArray]] 또는 Stream의 `mapToInt(Integer::intValue).toArray()`.

### 인접 원소 비교

```java
List<Integer> nums = ...;
nums.sort(null);

for (int i = 1; i < nums.size(); i++) {
    if (nums.get(i).equals(nums.get(i-1))) {
        // 중복 발견
    }
}
```

자세한 패턴은 [[정렬 후 인접 비교]] 참고.

## 주의: Auto-unboxing NPE

```java
List<Integer> list = new ArrayList<>();
list.add(null);

// X Integer가 null이면 int로 언박싱 시 NullPointerException
int val = list.get(0);   // NPE

// O Integer로 받아 null 체크
Integer val = list.get(0);
if (val != null) { ... }
```

## 시간복잡도

|구현체|복잡도|
|---|---|
|[[ArrayList]]|O(1)|
|[[LinkedList]]|O(n) (평균 O(n/2))|
