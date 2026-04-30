[[Arrays]]의 **배열을 멀티스레드로 병렬 정렬**하는 정적 메서드. 대용량 배열에서 [[Arrays.sort]]보다 빠릅니다.

## 시그니처

```java
// 원시 타입
static void parallelSort(int[] arr)
static void parallelSort(int[] arr, int fromIndex, int toIndex)

// 객체 타입
static <T extends Comparable<T>> void parallelSort(T[] arr)
static <T> void parallelSort(T[] arr, Comparator<? super T> c)
```

## 동작 추적

```java
int[] arr = new int[10_000_000];
// ... 데이터 채움
```

```
[ 동작 ]
1. 배열을 여러 부분으로 분할
2. 각 부분을 별도 스레드가 병렬로 정렬 (ForkJoinPool 사용)
3. 정렬된 부분들을 병합

→ 멀티코어 CPU 자원을 활용해 시간 단축
```

```java
Arrays.parallelSort(arr);
```

```
[ 변경 후 ]
arr: 정렬된 상태   ← in-place
```

## sort() vs parallelSort() 성능

```
n=1,000      → sort가 더 빠름 (스레드 오버헤드 > 이점)
n=100,000    → 비슷하거나 parallelSort 약간 빠름
n=1,000,000  → parallelSort가 명확히 빠름
n=10,000,000 → parallelSort가 압도적으로 빠름

→ 작은 배열은 오히려 느림 — 스레드 생성·동기화 비용 때문에
→ 수십만 개 이상일 때만 효과적
```

## 자주 쓰는 패턴

### 대용량 배열 정렬

```java
int[] huge = new int[10_000_000];
// 1천만 개 데이터

Arrays.parallelSort(huge);   // sort()보다 2~4배 빠름 (코어 수에 따라)
```

### Comparator 사용 (객체 배열)

```java
Student[] students = new Student[1_000_000];

Arrays.parallelSort(students,
    Comparator.comparingInt(Student::getScore).reversed()
);
```

## 내부 동작 — Fork/Join

```
[ 분할 정복으로 병렬화 ]

전체 배열
   ↓ 스레드 1개당 충분히 작아질 때까지 분할
[부분1] [부분2] [부분3] [부분4]
   ↓ 각 부분을 다른 스레드가 sort()로 정렬 (병렬)
[정렬됨] [정렬됨] [정렬됨] [정렬됨]
   ↓ 인접한 정렬된 부분들을 병합
[정렬됨] [정렬됨]
   ↓
[전체 정렬됨]

내부 풀: ForkJoinPool.commonPool()
→ 기본 병렬도: 시스템 CPU 코어 수 - 1
```

## 사용 시 주의

### 작은 배열에는 비효율

```java
int[] small = {3, 1, 4, 1, 5};
Arrays.parallelSort(small);   // 오히려 느림 — sort() 사용
```

### 멀티스레드 환경의 부담

```
parallelSort는 여러 스레드를 사용:
- 다른 스레드 작업과 CPU 경쟁
- 서버 환경에서 전역 ForkJoinPool 점유 → 다른 작업에 영향

→ 코딩테스트나 개인 작업에서는 안전, 운영 서버에서는 신중히
```

### 부동소수점 NaN 처리

```java
double[] arr = {1.0, Double.NaN, 2.0};
Arrays.parallelSort(arr);    // NaN을 끝으로 보냄 (sort와 동일)
```

## 다른 정렬 방법과 비교

|방법|대상|반환|in-place|언제 쓰나|
|---|---|---|---|---|
|[[Arrays.sort]]|배열|void|✅|기본 선택|
|[[Collections.sort]]|List|void|✅|List 정렬|
|[[List.sort]]|List|void|✅|Java 8+ 권장|
|[[Stream.sorted]]|모든 컬렉션|새 Stream|❌|원본 보존|
|`Arrays.parallelSort`|배열|void|✅|**대용량 (10만+)**|

## 시간복잡도

|평균|최악|공간|
|---|---|---|
|O(n log n / p)|O(n log n)|O(n)|

> p = 사용 가능한 코어 수. 이론적으로 코어 수만큼 빨라지지만, 실제로는 분할/병합 오버헤드로 그보다 적게 빨라짐.
