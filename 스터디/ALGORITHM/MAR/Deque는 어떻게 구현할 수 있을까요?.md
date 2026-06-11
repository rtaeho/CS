앞뒤 양방향 O(1) 연산을 보장하기 위해 **이중 연결 리스트** 또는 **원형 배열**로 구현할 수 있습니다.

## 1. 이중 연결 리스트로 구현

앞뒤 포인터(prev, next)를 모두 가져 양방향 O(1) 삽입/삭제가 가능합니다.

```
head                              tail
 ↓                                 ↓
[1] ↔ [2] ↔ [3] ↔ [4] ↔ [5]
```

```java
class LinkedDeque {
    private static class Node {
        int data;
        Node prev, next;
        Node(int data) { this.data = data; }
    }

    Node head, tail;
    int size;

    void addFirst(int data) {       // O(1)
        Node node = new Node(data);
        if (head == null) { head = tail = node; }
        else {
            node.next = head;
            head.prev = node;
            head = node;
        }
        size++;
    }

    void addLast(int data) {        // O(1)
        Node node = new Node(data);
        if (tail == null) { head = tail = node; }
        else {
            tail.next = node;
            node.prev = tail;
            tail = node;
        }
        size++;
    }

    int removeFirst() {             // O(1)
        int data = head.data;
        head = head.next;
        if (head != null) head.prev = null;
        else tail = null;
        size--;
        return data;
    }

    int removeLast() {              // O(1)
        int data = tail.data;
        tail = tail.prev;
        if (tail != null) tail.next = null;
        else head = null;
        size--;
        return data;
    }
}
```

---

## 2. 원형 배열로 구현

front, rear를 양방향으로 이동시켜 O(1)을 유지합니다.

```
capacity = 7, front=3, rear=5

index: [0][1][2][3][4][5][6]
             [_][1][2][3][_]
                 ↑       ↑
               front    rear
```

```java
class CircularDeque {
    int[] arr;
    int front, rear, size, capacity;

    CircularDeque(int capacity) {
        this.capacity = capacity;
        arr = new int[capacity];
        front = capacity / 2;   // 중간에서 시작 (양방향 확장 여유)
        rear = front;
    }

    void addFirst(int data) {           // O(1)
        front = (front - 1 + capacity) % capacity;
        arr[front] = data;
        size++;
    }

    void addLast(int data) {            // O(1)
        arr[rear] = data;
        rear = (rear + 1) % capacity;
        size++;
    }

    int removeFirst() {                 // O(1)
        int data = arr[front];
        front = (front + 1) % capacity;
        size--;
        return data;
    }

    int removeLast() {                  // O(1)
        rear = (rear - 1 + capacity) % capacity;
        size--;
        return arr[rear];
    }

    int peekFirst() { return arr[front]; }
    int peekLast()  { return arr[(rear - 1 + capacity) % capacity]; }
    boolean isEmpty() { return size == 0; }
    boolean isFull()  { return size == capacity; }
}
```

---

## 두 구현 방식 비교

|항목|이중 연결 리스트|원형 배열|
|---|---|---|
|addFirst/Last|O(1)|O(1)|
|removeFirst/Last|O(1)|O(1)|
|메모리|포인터 추가 비용|연속 공간, 빈 공간 낭비 가능|
|캐시 효율|낮음|높음 O|
|크기 제한|없음 O|고정 (확장 필요)|

## Java의 [[ArrayDeque]]

```java
// Java의 ArrayDeque는 원형 배열로 구현
// 공간 부족 시 2배 확장 (동적 원형 배열)
Deque<Integer> deque = new ArrayDeque<>();

deque.addFirst(1);   // O(1)
deque.addLast(2);    // O(1)
deque.removeFirst(); // O(1)
deque.removeLast();  // O(1)
```

> Java 공식 문서는 스택/큐 모두 `ArrayDeque` 사용을 권장합니다. 원형 배열 기반이라 캐시 효율이 높고, 연결 리스트 기반보다 실제 성능이 우수합니다.