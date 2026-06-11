---
title: "Collections"
tags: [자료구조, Java, 컬렉션]
status: published
---

**컬렉션(List, Set, Map)을 다루는 정적 메서드의 모음**입니다 (`java.util.Collections`). 정렬·검색·셔플·동기화 같은 작업을 한 줄로 처리할 수 있습니다.

## 왜 필요한가?

```
List, Set 등은 자체 메서드로 제공되지 않는 작업이 많음:
  - list.sort() O (Java 8+)
  - list.shuffle() X (없음)
  - list.max() X (없음)

→ Collections 유틸리티 클래스가 정적 메서드로 보완:
  - Collections.shuffle(list)
  - Collections.max(list)
  - Collections.binarySearch(list, key)
```

## 자주 쓰는 메서드

|메서드|용도|
|---|---|
|[[Collections.sort]]|List 정렬|
|[[Collections.reverseOrder]]|역순 비교자 반환 (최대 힙 / 내림차순)|
|`Collections.shuffle`|List 무작위 섞기|
|`Collections.reverse`|List 뒤집기|
|`Collections.max` / `min`|최댓값 / 최솟값|
|`Collections.binarySearch`|이진 탐색 (정렬 전제)|
|`Collections.frequency`|특정 값 등장 횟수|
|`Collections.unmodifiableList`|읽기 전용 뷰|
|`Collections.synchronizedList`|동기화 래퍼|
|`Collections.emptyList`|빈 List|

## Arrays vs Collections

|클래스|대상|예시|
|---|---|---|
|[[Arrays]]|배열 (`int[]`, `String[]`)|`Arrays.sort(arr)`|
|`Collections`|컬렉션 (`List`, `Set`, `Map`)|`Collections.sort(list)`|

```
같은 패턴의 페어:
- Arrays.sort        ↔ Collections.sort
- Arrays.binarySearch ↔ Collections.binarySearch
- Arrays.asList       ↔ Collections.singletonList
```

## 정적 메서드인 이유

```
Collections는 인스턴스를 만들지 않는 유틸리티 클래스:

X Collections c = new Collections();   // 사용 X
O Collections.sort(list);              // 정적 호출

→ Math, Arrays와 같은 패턴
```

## 핵심 정리

`Collections`는 자바 컬렉션을 다루기 위한 **정적 유틸리티 클래스**로, [[Arrays]]가 배열에 대해 하는 일을 컬렉션에 대해 합니다. 가장 자주 쓰는 것은 [[Collections.sort]], `shuffle`, `reverse`, `max/min`, `binarySearch`이며, Java 8+에서는 `list.sort()`처럼 컬렉션 자체에 메서드가 추가되어 일부 기능은 인스턴스 메서드로 대체되었습니다.
