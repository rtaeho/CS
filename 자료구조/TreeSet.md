**내부적으로 [[Red-Black Tree]]로 구현된 정렬된 집합**으로, 삽입/삭제와 동시에 정렬 상태를 유지합니다 (`java.util.TreeSet`).

## 핵심 특징

- **자동 정렬**: 원소가 삽입될 때마다 Red-Black Tree에 배치됨
- **중복 불허**: Set 계약 — 동일 원소 중복 삽입 무시
- **양 끝 접근**: `first()` / `last()` — O(log n)으로 최솟값/최댓값 즉시 접근
- **모든 연산**: O(log n) — Red-Black Tree 높이 보장

## PriorityQueue와 차이

| | PriorityQueue | TreeSet |
|---|---|---|
| 내부 구조 | 이진 힙 | Red-Black Tree |
| 중복 | 허용 | 불허 |
| 최솟값 접근 | `peek()` O(1) | `first()` O(log n) |
| **최댓값 접근** | 별도 최대 힙 필요 | `last()` O(log n) |
| 임의 원소 삭제 | O(n) | O(log n) |

> TreeSet은 **양 끝을 동시에** 효율적으로 다룰 수 있어 이중 우선순위 큐 구현에 적합합니다.

## 주요 API

| 메서드 | 설명 | 복잡도 |
|---|---|---|
| `add(e)` | 삽입 | O(log n) |
| `remove(e)` | 특정 원소 삭제 | O(log n) |
| `first()` | 최솟값 조회 (삭제 안 함) | O(log n) |
| `last()` | 최댓값 조회 (삭제 안 함) | O(log n) |
| `pollFirst()` | 최솟값 제거 후 반환 | O(log n) |
| `pollLast()` | 최댓값 제거 후 반환 | O(log n) |
| `contains(e)` | 존재 확인 | O(log n) |
| `size()` | 원소 개수 | O(1) |
| `isEmpty()` | 비었는지 확인 | O(1) |

## 이중 우선순위 큐 패턴

`TreeSet`의 가장 대표적인 활용 패턴. 최댓값·최솟값 삭제를 동시에 지원해야 할 때 사용.

```java
// 내림차순 Comparator → pollFirst()=max, pollLast()=min
TreeSet<Integer> set = new TreeSet<>((a, b) -> b - a);

set.add(3);
set.add(1);
set.add(5);

set.pollFirst();   // 5 (최댓값 삭제)
set.pollLast();    // 1 (최솟값 삭제)
set.first();       // 3 (최댓값 조회, 삭제 안 함)
set.last();        // 3 (최솟값 조회, 삭제 안 함)
```

> 기본(오름차순) Comparator를 쓰면 `pollFirst()`=min, `pollLast()`=max로 역할이 반대가 됩니다.

### 프로그래머스 — 이중 우선순위 큐

`I x`: x 삽입, `D 1`: 최댓값 삭제, `D -1`: 최솟값 삭제.

```java
TreeSet<Integer> set = new TreeSet<>((a, b) -> b - a);  // 내림차순

for (String s : operations) {
    String[] str = s.split(" ");
    String command = str[0];
    int num = Integer.parseInt(str[1]);

    if (command.equals("I")) {
        set.add(num);
    } else if (!set.isEmpty()) {
        if (num == 1)  set.pollFirst();   // 최댓값 삭제
        else           set.pollLast();    // 최솟값 삭제
    }
}

return set.isEmpty() ? new int[]{0, 0} : new int[]{set.first(), set.last()};
```

## 자주 하는 실수

### `b - a` Comparator 오버플로

```java
// ❌ Integer.MIN_VALUE 근처에서 오버플로
new TreeSet<>((a, b) -> b - a);

// ✅ 안전
new TreeSet<>((a, b) -> Integer.compare(b, a));
new TreeSet<>(Comparator.reverseOrder());
```

### 중복 원소 유실

```java
TreeSet<Integer> set = new TreeSet<>();
set.add(3);
set.add(3);   // 무시됨 — size()는 여전히 1

// 중복 허용이 필요하면 TreeMap<Integer, Integer>으로 빈도 관리
```

## TreeSet vs TreeMap

같은 이중 우선순위 큐를 TreeMap으로 구현하면 **중복 원소를 처리**할 수 있음.

```java
// 중복 허용 이중 우선순위 큐
TreeMap<Integer, Integer> map = new TreeMap<>();  // value = 빈도

// 삽입
map.merge(x, 1, Integer::sum);

// 최댓값 삭제
int max = map.lastKey();
if (map.merge(max, -1, Integer::sum) == 0) map.remove(max);
```

## 핵심 정리

`TreeSet`은 **Red-Black Tree 기반의 정렬된 집합**으로, 양 끝(최솟값·최댓값) 접근·삭제가 모두 O(log n)입니다. `PriorityQueue`가 한쪽 끝만 효율적으로 다루는 것과 달리, TreeSet은 **양 끝을 동시에 다루는 이중 우선순위 큐** 구현에 적합합니다. 단, 중복 원소가 있으면 TreeMap으로 빈도를 관리해야 합니다.

→ [[Red-Black Tree]] | [[PriorityQueue]]
