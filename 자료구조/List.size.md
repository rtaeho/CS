[[List]]에 저장된 **원소 개수**를 반환합니다.

## 시그니처

```java
int size()
```

## 동작 추적

```java
List<Integer> list = new ArrayList<>();
```

```
[ 초기 상태 ]
list: []
size = 0
```

```java
list.add(10);
list.add(20);
list.add(30);
```

```
[ 상태 ]
list: [10, 20, 30]
size = 3
```

```java
list.remove(0);
```

```
[ 상태 ]
list: [20, 30]
size = 2
```

## size() vs capacity

```
[ ArrayList의 size와 capacity는 다름 ]

내부 배열: [10 | 20 | 30 | _ | _ | _ | _ | _ | _ | _]
              0    1    2  3  4  5  6  7  8  9
                                   ↑ 빈 공간들

size = 3        ← 실제 들어있는 원소 수 (외부에서 봄)
capacity = 10   ← 내부 배열 크기 (외부에서 직접 못 봄)
```

> `size()`는 항상 실제 원소 수를 반환. capacity는 ArrayList 내부 구현 상세.

## 자주 쓰는 패턴

### for문 순회

```java
for (int i = 0; i < list.size(); i++) {
    System.out.println(list.get(i));
}
```

> 매 반복마다 `size()`를 호출하지만 O(1)이라 성능 손실 거의 없음. 가독성 우선.

### 끝 원소 접근

```java
list.get(list.size() - 1);   // 마지막 원소
```

### 빈 List 처리

```java
if (list.size() == 0) { ... }   // ❌ 의도가 덜 명확
if (list.isEmpty())   { ... }   // ✅ 권장 — [[List.isEmpty]]
```

### 결과 배열 생성

```java
ArrayList<Integer> list = new ArrayList<>();
// ... 데이터 누적

int[] answer = new int[list.size()];   // 정확한 크기로 배열 생성
for (int i = 0; i < list.size(); i++) {
    answer[i] = list.get(i);
}
```

## 시간복잡도

|연산|복잡도|
|---|---|
|`size()`|O(1) — 내부 카운터 유지|

> [[ArrayList]], [[LinkedList]] 모두 O(1). 별도 카운터 변수를 두어 매번 세지 않음.
