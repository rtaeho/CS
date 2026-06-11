**역순(내림차순) 정렬용 [[Comparator]]** 를 반환하는 정적 메서드입니다 ([[Collections]]). 자연 순서의 반대로 비교하는 비교자를 만들어 정렬·우선순위 큐 등에 넘깁니다.

## 시그니처

```java
static <T> Comparator<T> reverseOrder()
```

|반환|제약|
|---|---|
|자연 순서의 역(`Comparator<T>`)|타입 `T`가 `Comparable<T>`를 구현해야 함|

> 자기 자신은 정렬을 수행하지 않음. **비교자만 반환** — 누가 받아서 쓰느냐가 핵심.

## 동작 추적

```java
Comparator<Integer> desc = Collections.reverseOrder();

desc.compare(1, 2);   // 양수 → "1이 2보다 크다고 본다"
desc.compare(2, 1);   // 음수 → "2가 1보다 작다고 본다"

→ 결과적으로 큰 수가 앞으로 옴
```

### 정렬에 적용

```java
List<Integer> list = new ArrayList<>(Arrays.asList(3, 1, 4, 1, 5));

Collections.sort(list, Collections.reverseOrder());
// list: [5, 4, 3, 1, 1]   ← 내림차순
```

### 최대 힙 만들기

```java
PriorityQueue<Integer> maxHeap = new PriorityQueue<>(Collections.reverseOrder());

maxHeap.offer(5);
maxHeap.offer(1);
maxHeap.offer(3);

maxHeap.poll();   // 5 (큰 값부터)
maxHeap.poll();   // 3
maxHeap.poll();   // 1
```

> [[PriorityQueue]]는 기본이 **최소 힙**. `reverseOrder()`를 생성자에 넘기면 **최대 힙**.

## Collections.reverseOrder vs Comparator.reverseOrder

**완전히 동일한 동작.** 둘 다 자연 순서의 역 비교자를 반환합니다.

```java
Collections.reverseOrder()   // 구버전 API (Java 1.0)
Comparator.reverseOrder()    // Java 8+ 인터페이스 정적 메서드

// 결과 동일
new PriorityQueue<>(Collections.reverseOrder());
new PriorityQueue<>(Comparator.reverseOrder());
```

|관점|차이|
|---|---|
|역사|`Collections`이 먼저 (Java 1.0)|
|위치|`Collections` 유틸 vs `Comparator` 인터페이스 정적|
|동작|**동일**|
|관용|Java 8+에서는 `Comparator.reverseOrder()`가 약간 더 권장|

> 어느 쪽을 쓰든 무방. 본인 스타일/팀 컨벤션에 맞춰서.

## 자주 쓰는 패턴

### 최대 힙 (가장 흔한 사용처)

```java
PriorityQueue<Integer> maxHeap = new PriorityQueue<>(Collections.reverseOrder());
for (int x : arr) maxHeap.offer(x);

while (!maxHeap.isEmpty()) {
    System.out.print(maxHeap.poll() + " ");   // 큰 값부터
}
```

### 프로세스 우선순위 큐 (프로그래머스 패턴)

```java
PriorityQueue<Integer> pq = new PriorityQueue<>(Collections.reverseOrder());
for (int p : priorities) pq.offer(p);

// 매 시점의 "가장 높은 우선순위"를 O(1)로 조회
while (!q.isEmpty()) {
    Job cur = q.poll();
    if (cur.priority == pq.peek()) {
        pq.poll();
        // ... 처리
    } else {
        q.add(cur);   // 우선순위 더 높은 게 있으면 뒤로 보냄
    }
}
```

```
[ 핵심 아이디어 ]
- 일반 Queue: 처리 순서 보존 (FIFO)
- 최대 힙 PQ: 현재까지 남은 우선순위 중 최댓값 추적용 비교자

→ Queue에서 꺼낸 작업의 우선순위가 PQ의 peek과 같을 때만 진짜로 처리
```

### List 내림차순 정렬

```java
List<String> words = new ArrayList<>(Arrays.asList("banana", "apple", "cherry"));

words.sort(Collections.reverseOrder());
// ["cherry", "banana", "apple"]
```

### 배열 내림차순 (박싱 필수)

```java
Integer[] arr = {3, 1, 4, 1, 5};   // int[]가 아니라 Integer[]

Arrays.sort(arr, Collections.reverseOrder());
// [5, 4, 3, 1, 1]

// int[]는 직접 안 됨 — Stream 또는 박싱 후 처리
int[] primArr = {3, 1, 4};
int[] sorted = Arrays.stream(primArr).boxed()
    .sorted(Collections.reverseOrder())
    .mapToInt(Integer::intValue)
    .toArray();
```

> `Comparator`는 객체만 비교 — 원시 타입 배열에는 못 씀.

### 다중 기준 정렬에 합치기

```java
// 1차: score 내림차순, 2차: name 오름차순
list.sort(
    Comparator.comparingInt((Student s) -> s.score).reversed()
        .thenComparing(s -> s.name)
);

// reverseOrder()로는 다중 기준 안 됨 — reversed() 또는 직접 비교자 작성
```

## 자주 하는 실수

### 원시 타입 배열에 못 씀

```java
int[] arr = {3, 1, 4};
Arrays.sort(arr, Collections.reverseOrder());   // X 컴파일 에러
```

> `int[]`에는 `Comparator` 적용 불가. `Integer[]`로 박싱하거나 Stream 사용.

### Comparable이 없는 타입

```java
class Job { int priority; }   // Comparable 미구현

PriorityQueue<Job> pq = new PriorityQueue<>(Collections.reverseOrder());
pq.offer(new Job());   // X ClassCastException (런타임)
```

> 객체 클래스에 `implements Comparable<T>`가 없으면 `reverseOrder` 사용 불가.
> 이 경우엔 명시적 비교자 작성: `(a, b) -> Integer.compare(b.priority, a.priority)`

### `b - a` 오버플로의 안전한 대안

```java
// X Integer.MIN_VALUE 근처에서 오버플로
new PriorityQueue<>((a, b) -> b - a);

// O 안전
new PriorityQueue<>(Collections.reverseOrder());
new PriorityQueue<>(Comparator.reverseOrder());
```

> [[PriorityQueue]]의 흔한 실수 항목 참고.

## 형제 메서드

|메서드|용도|
|---|---|
|`Collections.reverseOrder()`|자연 순서 역|
|`Collections.reverseOrder(Comparator<T>)`|주어진 비교자의 역|
|`Comparator.reverseOrder()`|동일 (Java 8+)|
|`Comparator.naturalOrder()`|자연 순서 (기본)|
|`(a, b) -> b - a`|X 비추천 (오버플로 위험)|

### `Collections.reverseOrder(Comparator)` — 비교자 뒤집기

```java
Comparator<String> byLength = Comparator.comparingInt(String::length);
Comparator<String> byLengthDesc = Collections.reverseOrder(byLength);

// 또는 동등하게
Comparator<String> byLengthDesc2 = byLength.reversed();
```

## 시간복잡도

|연산|복잡도|
|---|---|
|`reverseOrder()` 호출 자체|O(1) — 싱글톤 비교자 반환|
|`compare(a, b)` 호출|O(1) (T의 `compareTo` 비용에 따름)|

## 핵심 정리

`Collections.reverseOrder()`는 자연 순서의 역 `Comparator`를 반환하는 정적 메서드로, **`PriorityQueue`를 최대 힙으로 바꾸는 표준 관용구**이며 `Collections.sort` / `Arrays.sort`에서 내림차순 정렬에도 자주 쓰입니다. Java 8+의 `Comparator.reverseOrder()`와 동작이 동일하니 어느 쪽을 써도 무방하고, `b - a` 같은 산술 비교의 오버플로 위험을 피하는 안전한 대안입니다. 원시 타입 배열과 `Comparable` 미구현 객체에는 사용할 수 없는 점이 유일한 제약입니다.
