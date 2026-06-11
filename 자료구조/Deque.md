---
title: "Deque"
tags: [덱, 스택, 큐]
status: published
---

양쪽 끝에서 삽입과 삭제가 모두 가능한 자료구조로, 스택과 큐의 기능을 합친 형태입니다.

## 구조

```
앞(Front)                       뒤(Rear)
  ↓                               ↓
[1] ↔ [2] ↔ [3] ↔ [4] ↔ [5]
 ↑                               ↑
addFirst/removeFirst         addLast/removeLast
```

## 핵심 연산

```java
// 이중 연결 리스트로 구현
class Node {
    int data;
    Node prev, next;
}

// Java에서는 ArrayDeque 사용 권장
Deque<Integer> deque = new ArrayDeque<>();

deque.addFirst(1);   // 앞에 삽입 - O(1)
deque.addLast(2);    // 뒤에 삽입 - O(1)
deque.removeFirst(); // 앞에서 삭제 - O(1)
deque.removeLast();  // 뒤에서 삭제 - O(1)
deque.peekFirst();   // 앞 조회 - O(1)
deque.peekLast();    // 뒤 조회 - O(1)
```

## 시간복잡도

|연산|복잡도|
|---|---|
|앞/뒤 삽입|O(1)|
|앞/뒤 삭제|O(1)|
|중간 접근|O(n)|

## 스택 · 큐 · 덱 비교

|자료구조|삽입|삭제|
|---|---|---|
|스택|뒤만|뒤만 (LIFO)|
|큐|뒤만|앞만 (FIFO)|
|덱|앞 + 뒤|앞 + 뒤|

## 활용

|상황|이유|
|---|---|
|브라우저 앞/뒤로 가기|양방향 이동|
|슬라이딩 윈도우 알고리즘|양끝 삽입/삭제 필요|
|스택/큐 대용|모든 기능 포함|

> Java에서는 `Stack`, `Queue` 대신 **`ArrayDeque`** 사용을 공식적으로 권장합니다.

---

**분류: 자료구조**