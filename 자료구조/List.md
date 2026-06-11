---
title: "List"
tags: [컬렉션, 배열]
status: published
---

**순서가 있고 중복을 허용하는** 자료구조입니다. 인덱스로 요소에 접근할 수 있습니다.

## 특징

|항목|설명|
|---|---|
|순서|유지됨 (인덱스 존재)|
|중복|허용|
|크기|가변 (동적)|

## Java에서의 List

```java
// 인터페이스
List<String> list;

// 주요 구현체
List<String> arrayList  = new ArrayList<>();
List<String> linkedList = new LinkedList<>();
```

## 구현체 비교

|항목|[[ArrayList]]|[[LinkedList]]|
|---|---|---|
|내부 구조|배열|노드 연결|
|조회|O(1) 빠름|O(n) 느림|
|삽입/삭제 (중간)|O(n) 느림|O(1) 빠름|
|메모리|연속|분산|

## 자주 쓰는 메서드

|메서드|용도|시간 (ArrayList)|
|---|---|---|
|[[List.add]]|원소 추가|O(1) 평균|
|[[List.get]]|인덱스로 조회|O(1)|
|[[List.set]]|인덱스 위치 값 변경|O(1)|
|[[List.remove]]|삭제|O(n)|
|[[List.size]]|개수|O(1)|
|[[List.isEmpty]]|비었는지 확인|O(1)|
|[[List.contains]]|포함 여부|O(n)|
|[[List.indexOf]]|첫 등장 인덱스|O(n)|
|[[List.clear]]|모든 원소 삭제|O(n)|
|[[List.toArray]]|배열로 변환|O(n)|
|[[List.sort]]|정렬|O(n log n)|

## List vs [[Set]] vs [[Map]]

|자료구조|순서|중복|접근 방식|
|---|---|---|---|
|**List**|O|O|인덱스|
|**Set**|X|X|값 자체|
|**Map**|X|키 X, 값 O|키|

## 정렬

```java
List<Integer> list = new ArrayList<>(Arrays.asList(3, 1, 2));

list.sort(null);                       // [1, 2, 3] (Java 8+)
list.sort(Comparator.reverseOrder());  // [3, 2, 1]
```

자세한 정렬 방법은 [[List.sort]] / [[Collections.sort]] / [[Stream.sorted]] / [[Comparator]] 참고.

## 핵심 정리

`List`는 **순서와 중복을 모두 허용하는 컬렉션 인터페이스**로, 가장 자주 쓰는 구현체는 [[ArrayList]](배열 기반, 조회 빠름)와 [[LinkedList]](연결 리스트, 중간 삽입 빠름)입니다. 알고리즘 문제에서는 거의 ArrayList가 정답이며, LinkedList는 앞/뒤 삽입·삭제가 매우 빈번한 큐/덱 용도일 때만 고려합니다. Java 8+에서는 `list.sort()`가 추가되어 [[Collections.sort]]보다 권장됩니다.
