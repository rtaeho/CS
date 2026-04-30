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

|메서드|용도|시간|
|---|---|---|
|`add(e)`|끝에 추가|O(1) 평균 (ArrayList) / O(1) (LinkedList)|
|`add(i, e)`|i 위치에 삽입|O(n) (ArrayList) / O(n) (LinkedList: 탐색)|
|`get(i)`|i 위치 조회|O(1) (ArrayList) / O(n) (LinkedList)|
|`set(i, e)`|i 위치 값 변경|O(1) (ArrayList) / O(n) (LinkedList)|
|`remove(i)`|i 위치 삭제|O(n) (ArrayList) / O(n) (LinkedList: 탐색)|
|`remove(o)`|값으로 삭제|O(n)|
|`size()`|개수|O(1)|
|`isEmpty()`|빈지 확인|O(1)|
|`contains(o)`|포함 여부|O(n)|
|`indexOf(o)`|첫 등장 인덱스|O(n)|
|[[List.sort]]|정렬|O(n log n)|

## 기본 사용법

```java
List<String> names = new ArrayList<>();

names.add("홍길동");
names.add("김철수");
names.add("홍길동");   // 중복 허용

names.get(0);          // "홍길동"
names.size();          // 3
names.set(0, "박영희"); // 수정
names.remove(0);       // 인덱스로 삭제
names.contains("홍길동");
```

## 순회

```java
// for문
for (int i = 0; i < list.size(); i++) {
    System.out.println(list.get(i));
}

// for-each
for (String name : list) {
    System.out.println(name);
}

// Stream
list.stream()
    .filter(name -> name.startsWith("홍"))
    .forEach(System.out::println);
```

## List vs [[Set]] vs [[Map]]

|자료구조|순서|중복|접근 방식|
|---|---|---|---|
|**List**|✅|✅|인덱스|
|**Set**|❌|❌|값 자체|
|**Map**|❌|키 ❌, 값 ✅|키|

## 정렬

```java
List<Integer> list = new ArrayList<>(Arrays.asList(3, 1, 2));

list.sort(null);                       // [1, 2, 3] (Java 8+)
list.sort(Comparator.reverseOrder());  // [3, 2, 1]

// 또는 Collections.sort (Java 1.2+, 내부적으로 list.sort 호출)
Collections.sort(list);
```

자세한 정렬 방법은 [[List.sort]] / [[Collections.sort]] / [[Stream.sorted]] 참고.

## 핵심 정리

`List`는 **순서와 중복을 모두 허용하는 컬렉션 인터페이스**로, 가장 자주 쓰는 구현체는 `ArrayList`(배열 기반, 조회 빠름)와 `LinkedList`(연결 리스트, 중간 삽입 빠름)입니다. Java 8+에서는 `list.sort()`가 추가되어 [[Collections.sort]]보다 권장되며, 정렬·필터링·매핑이 복합적으로 필요할 때는 [[Stream]]을 쓰는 것이 자연스럽습니다.
