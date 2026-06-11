[[Set]]에 저장된 **원소의 개수**를 반환합니다.

## 시그니처

```java
int size()
```

## 동작 추적

```java
Set<Integer> set = new HashSet<>();
```

```
[ 초기 상태 ]
set: [ ]
size = 0
```

```java
set.add(3);
set.add(1);
set.add(2);
```

```
[ 상태 ]
set: [1, 2, 3]
size = 3
```

```java
set.add(3);   // 이미 있음 → 무시
```

```
[ 상태 ]
set: [1, 2, 3]
size = 3   ← 변화 없음 (중복은 카운트 안 됨)
```

```java
set.remove(2);
```

```
[ 상태 ]
set: [1, 3]
size = 2
```

## 자주 쓰는 패턴

### 고유 종류 수 세기 (폰켓몬)

```java
int[] nums = {3, 1, 2, 3};

Set<Integer> set = new HashSet<>();
for (int num : nums) {
    set.add(num);
}

int distinctCount = set.size();
```

```
[ 단계별 추적 ]

초기:           set: [ ],  size = 0

add(3):        set: [3],          size = 1
add(1):        set: [3, 1],       size = 2
add(2):        set: [3, 1, 2],    size = 3
add(3):        set: [3, 1, 2],    size = 3   ← 중복 무시

→ 고유 종류: 3개
```

### 폰켓몬 답 도출

```java
public int solution(int[] nums) {
    Set<Integer> set = new HashSet<>();
    for (int num : nums) set.add(num);

    int r = nums.length / 2;
    int n = set.size();
    return Math.min(r, n);
}
```

```
[ 케이스 1: 종류가 N/2 이상 ]
nums: [3, 1, 2, 3]
N=4, N/2=2, 고유종=3
→ min(2, 3) = 2  (선택 제한이 답)

[ 케이스 2: 종류가 N/2 미만 ]
nums: [3, 3, 3, 2, 2, 4]
N=6, N/2=3, 고유종=3
→ min(3, 3) = 3  (둘 다 가능)

[ 케이스 3: 종류 매우 적음 ]
nums: [1, 1, 1, 1]
N=4, N/2=2, 고유종=1
→ min(2, 1) = 1  (가질 수 있는 종류가 한정됨)
```

### 빈 집합 확인

```java
if (set.size() == 0) { ... }   // X 비효율
if (set.isEmpty())   { ... }   // O 권장 — [[Set.isEmpty]]
```

> 결과는 같지만 `isEmpty()`가 의도가 명확하고 미세하게 더 빠름.

## 시간복잡도

|연산|복잡도|
|---|---|
|`size()`|O(1) — 내부적으로 카운터 변수를 유지|
