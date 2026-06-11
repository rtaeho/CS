[[List]]를 **배열로 변환**합니다. 객체 배열은 직접 변환 가능하지만, **원시 타입(`int[]`)으로 변환은 한 단계 더 필요**합니다.

## 시그니처

```java
Object[] toArray()                    // Object[] 반환
<T> T[] toArray(T[] a)                // 지정한 타입 배열 반환
<T> T[] toArray(IntFunction<T[]> f)   // 생성자 함수 (Java 11+)
```

## 동작 추적

```java
List<String> list = new ArrayList<>(Arrays.asList("a", "b", "c"));
```

```
[ 초기 상태 ]
list: [a, b, c]
```

### Object[] 반환 (캐스팅 필요 — 비추천)

```java
Object[] arr = list.toArray();
// arr: [a, b, c]   (타입은 Object[])
```

```
[ 문제점 ]
String[]으로 캐스팅 못 함:
String[] strs = (String[]) list.toArray();   // ClassCastException
```

### 지정한 타입 배열 (권장)

```java
String[] arr = list.toArray(new String[0]);
// arr: [a, b, c]   (타입은 String[])
```

```
[ 동작 ]
new String[0]을 던지면 → toArray 내부에서 적절한 크기의 String[] 생성

참고: new String[list.size()]를 미리 만들어 줘도 되지만,
     벤치마크상 new String[0]이 약간 더 빠름 (JIT 최적화)
```

### 생성자 함수 (Java 11+)

```java
String[] arr = list.toArray(String[]::new);
// arr: [a, b, c]
```

> 가장 깔끔한 방법. Java 11+에서는 이걸 추천.

## X 원시 타입 배열의 함정

```java
List<Integer> list = new ArrayList<>(Arrays.asList(1, 2, 3));

// X int[]로 직접 변환 안 됨
int[] arr = list.toArray();   // 컴파일 에러
int[] arr = list.toArray(new int[0]);   // 컴파일 에러

// 가능한 건 Integer[]만
Integer[] arr = list.toArray(new Integer[0]);
Integer[] arr = list.toArray(Integer[]::new);
```

## O List<Integer> → int[] 변환 방법

### 방법 1: Stream

```java
List<Integer> list = Arrays.asList(1, 2, 3);

int[] arr = list.stream()
    .mapToInt(Integer::intValue)
    .toArray();
// arr: [1, 2, 3]
```

```
[ 동작 ]
Stream<Integer> → IntStream (언박싱) → int[]
```

### 방법 2: 수동 루프

```java
int[] arr = new int[list.size()];
for (int i = 0; i < list.size(); i++) {
    arr[i] = list.get(i);   // Integer → int 자동 언박싱
}
```

> 짧은 코드가 필요하면 Stream, 명시적이고 빠른 게 필요하면 루프.

## 자주 쓰는 패턴

### 결과 누적 후 배열 반환

```java
public int[] solution(int[] arr) {
    ArrayList<Integer> list = new ArrayList<>();
    int lastValue = -1;

    for (int num : arr) {
        if (num != lastValue) {
            list.add(num);
            lastValue = num;
        }
    }

    // List → int[] 변환
    return list.stream().mapToInt(Integer::intValue).toArray();
}
```

```
[ 추적 ]
입력 arr:    [1, 1, 3, 3, 0, 1, 1]
누적 list:   [1, 3, 0, 1]
toArray:     [1, 3, 0, 1]   ← int[]로 변환됨
```

### 객체 List → 객체 배열

```java
List<String> list = ...;
String[] arr = list.toArray(String[]::new);   // Java 11+
// or
String[] arr = list.toArray(new String[0]);
```

## 흔한 실수

### `new int[]` 못 던짐

```java
// X 컴파일 에러 — toArray의 타입 매개변수는 객체만
list.toArray(new int[0]);

// O Stream 사용
list.stream().mapToInt(Integer::intValue).toArray();
```

### Object[] 캐스팅

```java
List<String> list = ...;

// X ClassCastException
String[] arr = (String[]) list.toArray();

// O 타입 매개변수로 지정
String[] arr = list.toArray(new String[0]);
```

## 시간복잡도

|연산|복잡도|
|---|---|
|`toArray()`|O(n)|
|`toArray(T[])`|O(n)|
|Stream `mapToInt(...).toArray()`|O(n)|
