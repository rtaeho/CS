내부적으로 **동적 원형 배열**을 사용해 앞뒤 양방향 삽입/삭제를 모두 O(1)에 지원하는 Java의 자료구조입니다.

## 구조

```
capacity = 8, head = 3, tail = 6

index: [ 0 ][ 1 ][ 2 ][ 3 ][ 4 ][ 5 ][ 6 ][ 7 ]
       [ _ ][ _ ][ _ ][ 1 ][ 2 ][ 3 ][ _ ][ _ ]
                        ↑              ↑
                       head           tail
```

## 핵심 연산

```java
Deque<Integer> deque = new ArrayDeque<>();

// 스택처럼 사용
deque.push(1);          // addFirst - O(1)
deque.pop();            // removeFirst - O(1)

// 큐처럼 사용
deque.offer(1);         // addLast - O(1)
deque.poll();           // removeFirst - O(1)

// 덱으로 사용
deque.addFirst(1);      // O(1)
deque.addLast(2);       // O(1)
deque.removeFirst();    // O(1)
deque.removeLast();     // O(1)
deque.peekFirst();      // O(1)
deque.peekLast();       // O(1)
```

## 동적 확장

```
공간이 꽉 차면 2배 크기 배열로 복사 → O(n)
단, 분할상환 O(1)
```

## 시간복잡도

|연산|복잡도|
|---|---|
|addFirst / addLast|O(1) 분할상환|
|removeFirst / removeLast|O(1)|
|peek|O(1)|
|중간 접근|O(n)|

## ArrayDeque vs LinkedList

|항목|ArrayDeque|LinkedList|
|---|---|---|
|내부 구조|원형 배열|이중 연결 리스트|
|캐시 효율|높음 ✓|낮음|
|메모리|빈 공간 낭비 가능|포인터 추가 비용|
|null 허용|❌|✅|
|성능|대부분 빠름 ✓|느림|

> Java 공식 문서는 스택/큐/덱 모두 `Stack`, `Queue` 대신 **`ArrayDeque`** 사용을 권장합니다.