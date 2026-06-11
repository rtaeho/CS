**내부적으로 배열을 사용하지만 크기가 동적으로 확장되는** Java의 [[List]] 구현체입니다.

## 구조

```
capacity: 10 (기본값)
[ 1 | 2 | 3 | 4 | _ | _ | _ | _ | _ | _ ]
  0   1   2   3   ← size: 4, 나머지는 빈 공간
```

|용어|의미|
|---|---|
|**size**|실제 저장된 원소 개수 (`list.size()`)|
|**capacity**|내부 배열의 크기 (외부에서 직접 못 봄)|

## 동적 확장 원리

```java
// 공간이 꽉 차면 내부적으로:
1. 현재 capacity의 1.5배인 새 배열 생성
2. 기존 데이터 전체 복사 → O(n)
3. 새 배열로 교체

// 예시
ArrayList<Integer> list = new ArrayList<>();   // capacity: 10
for (int i = 0; i < 11; i++) list.add(i);      // 11번째에 확장 발생
                                                // capacity: 10 → 15
```

```
[ 확장 추적 ]
초기:     capacity=10, size=0
add 10번: capacity=10, size=10  (꽉 참)
add 1번:  확장 발생!
          capacity=15, size=11
```

> **분할상환 분석**: 매번 add는 O(1)이지만 가끔 O(n) 확장 → n번 누적 시 평균 **O(1)**.

## 초기 capacity 지정

```java
// 데이터 크기를 미리 알면 capacity 지정 → 확장 비용 회피
ArrayList<Integer> list = new ArrayList<>(1000);
for (int i = 0; i < 1000; i++) list.add(i);   // 확장 한 번도 안 일어남
```

## 자주 쓰는 메서드

[[List]] 인터페이스의 메서드를 그대로 사용:

|메서드|용도|시간|
|---|---|---|
|[[List.add]]|원소 추가|O(1) 평균|
|[[List.get]]|인덱스 조회|O(1)|
|[[List.set]]|인덱스 위치 변경|O(1)|
|[[List.remove]]|삭제|O(n)|
|[[List.size]]|개수|O(1)|
|[[List.contains]]|포함 여부|O(n)|
|[[List.toArray]]|배열로 변환|O(n)|

## ArrayList vs [[LinkedList]]

|항목|ArrayList|LinkedList|
|---|---|---|
|내부 구조|배열|이중 연결 리스트|
|조회 (`get`)|O(1) O|O(n) X|
|중간 삽입/삭제|O(n)|O(1) (탐색 후)|
|끝에 추가|O(1) 평균|O(1)|
|메모리|연속|분산 (포인터 오버헤드)|
|캐시 친화성|O 높음|X 낮음|

> **알고리즘 문제에서는 거의 항상 ArrayList**. LinkedList는 큐/덱 용도일 때만 고려 — 그것도 보통 [[ArrayDeque]]가 더 빠름.

## 자주 쓰는 패턴

### 동적 누적 후 배열로 변환

```java
ArrayList<Integer> list = new ArrayList<>();
for (int num : arr) {
    if (조건) list.add(num);
}

// List → int[]
int[] answer = new int[list.size()];
for (int i = 0; i < list.size(); i++) {
    answer[i] = list.get(i);
}

// 또는 Stream으로
int[] answer = list.stream().mapToInt(Integer::intValue).toArray();
```

> `int[]`로 변환할 때 `list.toArray()`는 `Object[]`를 반환해서 캐스팅 못 함. 위 두 방법 중 하나 사용. 자세한 건 [[List.toArray]] 참고.

### 결과 크기를 모를 때

```java
// 답의 크기를 미리 알 수 없을 때 ArrayList로 누적
ArrayList<Integer> result = new ArrayList<>();
for (...) {
    if (조건) result.add(value);
}

// 마지막에 배열로 변환
return result.stream().mapToInt(Integer::intValue).toArray();
```

## 핵심 정리

`ArrayList`는 자바에서 가장 많이 쓰이는 [[List]] 구현체로, 내부적으로 **배열을 1.5배씩 확장**하며 평균 O(1)에 추가가 가능합니다. 인덱스 조회가 O(1)이라 [[LinkedList]]보다 거의 항상 빠르며, 메서드는 [[List]] 인터페이스에 정의된 것을 그대로 씁니다 ([[List.add]], [[List.get]] 등). 알고리즘 문제에서 **결과 크기를 미리 모를 때 누적용**으로 자주 사용되며, 마지막에 [[List.toArray]] 또는 Stream으로 배열 변환합니다.
