**배열을 다루는 정적 메서드의 모음**입니다 (`java.util.Arrays`). 정렬·복사·검색·변환을 한 줄로 처리할 수 있습니다.

## 왜 필요한가?

```
Java 배열은 가변 메서드가 거의 없음:
  - int[] arr = new int[5];
  - arr.sort()  X (없음)
  - arr.contains() X (없음)

→ Arrays 유틸리티 클래스가 정적 메서드로 보완:
  - Arrays.sort(arr)
  - Arrays.binarySearch(arr, key)
  - Arrays.copyOf(arr, n)
```

## 자주 쓰는 메서드

|메서드|용도|
|---|---|
|[[Arrays.sort]]|배열 정렬 (오름차순)|
|[[Arrays.parallelSort]]|병렬 정렬 (대용량 배열용)|
|`Arrays.fill`|모든 원소를 특정 값으로 채움|
|`Arrays.copyOf`|길이 지정해서 복사|
|`Arrays.copyOfRange`|구간 복사|
|`Arrays.asList`|배열 → List 변환 (고정 크기)|
|`Arrays.equals`|두 배열의 원소 비교|
|`Arrays.toString`|배열을 문자열로 (디버깅)|
|`Arrays.deepToString`|2차원 배열을 문자열로|
|`Arrays.binarySearch`|이진 탐색 (정렬 전제)|
|`Arrays.stream`|배열 → Stream 변환|

## 정적 메서드인 이유

```
Arrays는 인스턴스를 만들지 않는 유틸리티 클래스:

X Arrays a = new Arrays();        // 사용 X
O Arrays.sort(arr);                // 정적 호출

→ Math, Collections와 같은 패턴 (유틸리티 클래스)
```

## 주의: 원시 타입 vs 객체 타입

```java
int[] arr = {3, 1, 2};
Integer[] boxed = {3, 1, 2};
String[] words = {"b", "a", "c"};

// 원시 타입과 객체 타입에서 동작 차이가 있는 메서드들:
Arrays.sort(arr);     // dual-pivot 퀵소트 (불안정)
Arrays.sort(boxed);   // 팀소트 (안정)
Arrays.sort(words);   // 팀소트 (안정)
```

## 핵심 정리

`Arrays`는 자바 배열을 다루기 위한 **정적 유틸리티 클래스**로, 정렬·복사·변환·검색 메서드를 제공합니다. 가장 자주 쓰는 것은 [[Arrays.sort]]이며, 원시 타입(`int[]`)은 dual-pivot 퀵소트(불안정), 객체 타입(`Integer[]`, `String[]`)은 팀소트(안정)로 동작합니다. 알고리즘 문제에서는 정렬 + `binarySearch`, 또는 `copyOfRange`로 배열 분할 같은 패턴이 자주 등장합니다.
