내부적으로 배열을 사용하지만 크기가 동적으로 확장되는 Java의 자료구조입니다.

## 구조

```
capacity: 10 (기본값)
[ 1 | 2 | 3 | 4 | _ | _ | _ | _ | _ | _ ]
  0   1   2   3   ← size: 4, 나머지는 빈 공간
```

## 동적 확장 원리

```java
// 공간이 꽉 차면 내부적으로 아래 과정 수행
1. 현재 크기의 1.5배 새 배열 생성
2. 기존 데이터 전체 복사 → O(n)
3. 새 배열로 교체

// 예시
ArrayList<Integer> list = new ArrayList<>(); // capacity: 10
for (int i = 0; i < 11; i++) list.add(i);   // 11번째에 확장 발생
```

## 핵심 연산

```java
ArrayList<Integer> list = new ArrayList<>();

list.add(1);        // 끝에 추가 - O(1) 평균
list.add(0, 99);    // 중간 삽입 - O(n), 요소 이동 발생
list.get(2);        // 인덱스 접근 - O(1)
list.remove(0);     // 삭제 - O(n), 요소 이동 발생
list.contains(3);   // 탐색 - O(n)
```

## 시간복잡도

|연산|복잡도|이유|
|---|---|---|
|접근|O(1)|인덱스로 직접 접근|
|끝에 삽입|O(1) 평균|확장 시 O(n)|
|중간 삽입/삭제|O(n)|요소 이동 필요|
|탐색|O(n)|순차 탐색|

## ArrayList vs LinkedList

|항목|ArrayList|LinkedList|
|---|---|---|
|접근|O(1) ✓|O(n)|
|중간 삽입/삭제|O(n)|O(n) 탐색 + O(1) 변경|
|메모리|연속 공간, 빈 공간 낭비 가능|포인터 추가 비용|
|캐시 효율|높음 ✓|낮음|

> 대부분의 경우 **ArrayList가 LinkedList보다 유리**합니다. LinkedList는 앞/뒤 삽입·삭제가 매우 빈번할 때 고려합니다.
