---
title: "Stream"
tags: [람다, 함수형]
status: published
---

**컬렉션·배열을 함수형 스타일로 처리하는 파이프라인**입니다 (`java.util.stream.Stream`). 필터링·매핑·정렬·집계를 체이닝으로 표현합니다.

## 왜 필요한가?

```
[ 기존 방식 — 명령형 ]
List<Integer> result = new ArrayList<>();
for (int n : list) {
    if (n > 0) {
        result.add(n * 2);
    }
}
Collections.sort(result);

[ Stream 방식 — 선언적 ]
List<Integer> result = list.stream()
    .filter(n -> n > 0)
    .map(n -> n * 2)
    .sorted()
    .collect(Collectors.toList());

→ "무엇을 할지"를 코드로 표현, "어떻게 반복할지"는 Stream이 처리
```

## Stream 생성

```java
// 컬렉션에서
list.stream()                           // List → Stream
set.stream()                            // Set → Stream

// 배열에서
Arrays.stream(arr)                      // Object[] / int[] / long[]
Stream.of(1, 2, 3)                      // 직접 생성

// 무한 스트림
Stream.iterate(0, n -> n + 1)           // 0, 1, 2, 3...
Stream.generate(() -> Math.random())    // 난수 무한 생성
```

## 자주 쓰는 메서드

### 중간 연산 (Stream 반환)

|메서드|용도|
|---|---|
|`filter(predicate)`|조건에 맞는 것만 통과|
|`map(function)`|각 원소를 변환|
|[[Stream.sorted]]|정렬|
|`distinct()`|중복 제거|
|`limit(n)`|앞에서 n개|
|`skip(n)`|앞에서 n개 건너뜀|
|`peek(consumer)`|디버깅용 (각 원소 들여다보기)|

### 종단 연산 (결과 반환)

|메서드|용도|
|---|---|
|`collect(collector)`|컬렉션으로 수집|
|`toList()`|List로 (Java 16+)|
|`forEach(consumer)`|각 원소 소비|
|`count()`|개수|
|`min` / `max`|최솟값 / 최댓값|
|`anyMatch` / `allMatch` / `noneMatch`|조건 검사|
|`findFirst` / `findAny`|첫 원소 / 임의 원소|
|`reduce`|누적 계산 (합, 곱 등)|
|`sum` (IntStream만)|합계|

## 원시 타입 Stream

```java
IntStream.of(1, 2, 3)                  // int 전용
IntStream.range(1, 10)                 // 1..9
IntStream.rangeClosed(1, 10)           // 1..10

LongStream / DoubleStream              // long, double 전용

// Stream<Integer> ↔ IntStream 변환
list.stream().mapToInt(Integer::intValue)   // boxed → primitive
intStream.boxed()                            // primitive → boxed
```

## 사용 시 주의

### 한 번 쓰면 끝

```java
Stream<Integer> s = list.stream();
s.count();            // 사용
s.filter(...);        // X IllegalStateException — 이미 소비됨
```

### 무한 스트림은 limit 필요

```java
// X 무한 루프
Stream.iterate(0, n -> n + 1).forEach(System.out::println);

// O limit으로 끊기
Stream.iterate(0, n -> n + 1).limit(10).forEach(System.out::println);
```

## Stream vs for문

|항목|Stream|for문|
|---|---|---|
|가독성|선언적|명령형|
|성능|약간 느림 (객체 생성 비용)|빠름|
|병렬화|`parallelStream()` 한 줄|수동 처리 복잡|
|디버깅|중간 연산 추적 어려움|쉬움|
|단순 반복|오버킬|적합|

> 코딩테스트에서는 단순 반복은 for문, 복잡한 변환은 Stream이 일반적.

## 핵심 정리

`Stream`은 자바의 **함수형 데이터 처리 파이프라인**으로, 중간 연산(filter, map, sorted)과 종단 연산(collect, count)을 체이닝해서 선언적으로 표현합니다. 가장 자주 쓰는 정렬은 [[Stream.sorted]]이며, 원본을 변경하지 않고 **새 Stream을 반환**합니다. 한 번 소비된 Stream은 재사용 불가하고, 단순 반복에는 for문이, 복잡한 변환에는 Stream이 적합합니다.
