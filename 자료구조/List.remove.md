[[List]]에서 **원소를 삭제**합니다. 인덱스 또는 값으로 삭제할 수 있습니다.

## 시그니처

```java
E remove(int index)        // 인덱스로 삭제 — 삭제된 값 반환
boolean remove(Object o)   // 값으로 삭제 — 삭제 여부 반환
```

|호출 형태|반환값|
|---|---|
|`remove(int)`|삭제된 원소 (인덱스가 잘못되면 예외)|
|`remove(Object)`|`true`(삭제됨) / `false`(없음)|

## 동작 추적

```java
List<Integer> list = new ArrayList<>(Arrays.asList(10, 20, 30, 20));
```

```
[ 초기 상태 ]
list: [10, 20, 30, 20]
       0   1   2   3
```

### 인덱스로 삭제

```java
Integer removed = list.remove(1);
// removed = 20 (삭제된 값)
```

```
[ 동작 ]
인덱스 1의 20 삭제 → 뒤 원소들이 한 칸씩 앞으로

[ 변경 후 ]
list: [10, 30, 20]
       0   1   2
size: 4 → 3
```

### 값으로 삭제 (첫 번째만)

```java
boolean ok = list.remove(Integer.valueOf(20));
// ok = true
```

```
[ 동작 ]
20을 찾아서 첫 번째 등장 위치 삭제

[ 변경 후 ]
list: [10, 30]   ← 마지막 20은 그대로 (한 번만 삭제)
```

## X Integer 삭제 함정

```java
List<Integer> list = new ArrayList<>(Arrays.asList(10, 20, 30));

list.remove(1);    // 인덱스 1 → 20 삭제 (의도와 다를 수도)
list.remove(Integer.valueOf(1));   // 값 1 삭제 (없으면 false)
```

```
[ 자바의 함정 ]
List<Integer>의 remove는 두 시그니처가 둘 다 적용됨:
  remove(int index)
  remove(Object o)

→ remove(1)은 int 매개변수로 매칭 → 인덱스 1 삭제
→ 값 1을 삭제하려면 Integer.valueOf(1)로 박싱 필수
```

## 자주 쓰는 패턴

### 끝에서 삭제 (스택처럼 사용)

```java
List<Integer> stack = new ArrayList<>();
stack.add(1);
stack.add(2);
stack.add(3);

int top = stack.remove(stack.size() - 1);   // 3 (LIFO)
```

> 스택 용도라면 [[ArrayDeque]] (`push`/`pop`)이 더 명확하고 빠름.

### 순회 중 안전한 삭제

```java
// X for-each 중 list.remove → ConcurrentModificationException
for (Integer n : list) {
    if (n == 0) list.remove(n);   // 예외!
}

// X 일반 for문 + remove도 인덱스 꼬임
for (int i = 0; i < list.size(); i++) {
    if (list.get(i) == 0) list.remove(i);   // i 다음에 i+1 건너뜀
}

// O 뒤에서부터 순회
for (int i = list.size() - 1; i >= 0; i--) {
    if (list.get(i) == 0) list.remove(i);
}

// O Iterator의 remove
Iterator<Integer> it = list.iterator();
while (it.hasNext()) {
    if (it.next() == 0) it.remove();
}

// O Java 8+ removeIf — 가장 깔끔
list.removeIf(n -> n == 0);
```

```
[ removeIf 동작 추적 ]

[ 초기 ]
list: [1, 0, 2, 0, 3, 0]

list.removeIf(n -> n == 0);

[ 변경 후 ]
list: [1, 2, 3]   ← 0인 항목 일괄 삭제
```

### 중간 삭제 비용

```
[ ArrayList ]
remove(0) → 모든 원소를 한 칸씩 앞으로 → O(n)
remove(끝) → 단순히 size 감소 → O(1)

[ LinkedList ]
remove(0) → head 포인터만 갱신 → O(1)
remove(중간) → 인덱스 탐색 + 노드 갱신 → O(n)
```

## 시간복잡도

|연산|[[ArrayList]]|[[LinkedList]]|
|---|---|---|
|`remove(0)` 맨 앞|O(n)|O(1)|
|`remove(끝)` 끝|O(1)|O(1)|
|`remove(중간)`|O(n)|O(n)|
|`remove(Object)`|O(n)|O(n)|
