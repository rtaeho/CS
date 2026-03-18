각 노드가 데이터와 다음 노드의 참조(포인터)를 함께 저장하는 선형 자료구조입니다.

## 구조

```
[data|next] → [data|next] → [data|next] → null
   head                        tail
```

```java
class Node {
    int data;
    Node next;

    Node(int data) {
        this.data = data;
        this.next = null;
    }
}
```

## 종류

|종류|설명|
|---|---|
|단순 연결 리스트|단방향, next만 존재|
|이중 연결 리스트|양방향, prev + next|
|원형 연결 리스트|tail이 head를 가리킴|

## 핵심 연산

```java
class LinkedList {
    Node head;

    // 삽입 - O(1) (맨 앞)
    void addFirst(int data) {
        Node node = new Node(data);
        node.next = head;
        head = node;
    }

    // 삭제 - O(n) (탐색 후 삭제)
    void delete(int data) {
        if (head.data == data) { head = head.next; return; }
        Node cur = head;
        while (cur.next != null) {
            if (cur.next.data == data) {
                cur.next = cur.next.next;
                return;
            }
            cur = cur.next;
        }
    }

    // 탐색 - O(n)
    Node find(int data) {
        Node cur = head;
        while (cur != null) {
            if (cur.data == data) return cur;
            cur = cur.next;
        }
        return null;
    }
}
```

## [[배열]] vs 링크드 리스트

|항목|배열|링크드 리스트|
|---|---|---|
|접근|O(1)|O(n)|
|삽입/삭제 (앞)|O(n)|O(1)|
|메모리|연속 공간|불연속, 포인터 추가 비용|
|크기|고정|동적 확장|

## Java에서의 LinkedList

```java
LinkedList<Integer> list = new LinkedList<>();

list.addFirst(1);  // O(1)
list.addLast(2);   // O(1)
list.get(1);       // O(n)
list.remove(0);    // O(1)
```

> Java의 `LinkedList`는 이중 연결 리스트로 구현되며, `Deque`도 구현하므로 [[Queue]]/[[Stack]]으로도 활용 가능합니다.