**원형 배열 기반** 덱은 인덱스 계산 공식으로 임의의 위치를 O(1)에 바로 찾을 수 있기 때문입니다.

## 핵심 원리: 인덱스 계산 공식

```
실제 위치 = (head + i) % capacity
```

```
capacity = 8, head = 5

index: [ 0 ][ 1 ][ 2 ][ 3 ][ 4 ][ 5 ][ 6 ][ 7 ]
       [ C ][ D ][ _ ][ _ ][ _ ][ A ][ B ][ _ ]
                                  ↑
                                 head

논리적 index 0 → (5 + 0) % 8 = 5 → arr[5] = A O
논리적 index 1 → (5 + 1) % 8 = 6 → arr[6] = B O
논리적 index 2 → (5 + 2) % 8 = 7 → arr[7] = ? (wrap around)
논리적 index 2 → (5 + 2) % 8 = 0 → arr[0] = C O
논리적 index 3 → (5 + 3) % 8 = 1 → arr[1] = D O
```

## 구현

```java
class CircularDeque {
    int[] arr;
    int head, size, capacity;

    // Random Access - O(1)
    int get(int i) {
        return arr[(head + i) % capacity]; // 한 번의 계산으로 바로 접근
    }
}
```

## 연결 리스트와 비교

```
LinkedList 기반 덱 - O(n)
head → [A] → [B] → [C] → [D]
index 3에 접근하려면 A → B → C → D 순차 탐색 필요

원형 배열 기반 덱 - O(1)
(head + 3) % capacity 한 번의 계산으로 바로 접근
```

## Java ArrayDeque의 한계

```java
ArrayDeque<Integer> deque = new ArrayDeque<>();
deque.addLast(1);
deque.addLast(2);
deque.addLast(3);

// ArrayDeque는 get(index) 미제공 X
// deque.get(1) → 컴파일 에러

// 내부적으로는 O(1) 접근 가능하나 외부에 노출하지 않음
// Random Access가 필요하면 ArrayList 사용 권장
```

## 자료구조별 Random Access 비교

|자료구조|Random Access|이유|
|---|---|---|
|배열 / ArrayList|O(1)|연속 메모리, 직접 주소 계산|
|원형 배열 덱|O(1)|`(head + i) % capacity` 공식|
|LinkedList 덱|O(n)|순차 탐색 필요|

> 결국 Random Access O(1)의 본질은 **배열의 특성**입니다. 원형 배열은 나머지 연산(%)으로 wrap around를 처리할 뿐, 실제 접근은 배열의 인덱스 접근과 동일합니다.