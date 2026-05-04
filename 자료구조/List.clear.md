[[List]]의 **모든 원소를 삭제**합니다. List 자체는 그대로 유지(재사용 가능).

## 시그니처

```java
void clear()
```

## 동작 추적

```java
List<Integer> list = new ArrayList<>(Arrays.asList(1, 2, 3, 4, 5));
```

```
[ 초기 상태 ]
list: [1, 2, 3, 4, 5]
size = 5
```

```java
list.clear();
```

```
[ 변경 후 ]
list: []
size = 0
```

```java
list.add(10);
list.add(20);
```

```
[ 재사용 가능 ]
list: [10, 20]
size = 2
```

## clear() vs 새 객체 생성

```java
// 1. clear — 같은 객체 재사용
List<Integer> list = new ArrayList<>(...);
list.clear();
// 이 list 변수를 다른 곳에 참조시킨 적이 있으면 그쪽에서도 비워진 채로 보임

// 2. 새 객체 — 다른 메모리
List<Integer> list = new ArrayList<>(...);
list = new ArrayList<>();
// 기존 객체는 GC 대상이 됨. 다른 참조에는 영향 없음
```

```
[ 차이점 ]
clear(): 같은 객체의 원소들만 비움 → 외부 참조도 비워진 채로 봄
new ArrayList: 새 객체 → 외부 참조는 기존 객체 그대로 봄
```

## 자주 쓰는 패턴

### 반복문 안에서 List 재사용

```java
List<Integer> buffer = new ArrayList<>();

for (Item item : items) {
    buffer.clear();
    process(item, buffer);
}
```

```
[ 동작 ]
매 iteration마다 buffer 객체를 새로 만들지 않고 재사용
GC 부담 줄임
```

### 일괄 삭제 후 새로 채우기

```java
List<Integer> result = new ArrayList<>();
// ... 결과 누적

if (조건) {
    result.clear();
    // 다른 결과로 다시 채움
}
```

## ArrayList vs LinkedList의 clear

```
[ ArrayList ]
clear() → 내부 배열의 모든 원소 참조를 null로 설정
         (capacity는 줄어들지 않음, 내부 배열 그대로)
시간: O(n)

[ LinkedList ]
clear() → 모든 노드의 참조를 끊음 (head/tail = null)
시간: O(n)
```

> 둘 다 O(n). ArrayList의 capacity는 clear 후에도 줄지 않음 — 메모리 회수가 필요하면 새 ArrayList 생성 권장.

## 시간복잡도

|연산|복잡도|
|---|---|
|`clear()`|O(n)|
