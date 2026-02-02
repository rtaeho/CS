순서가 있고 중복을 허용하는 자료구조입니다. 인덱스로 요소에 접근할 수 있습니다.

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
List<String> arrayList = new ArrayList<>();
List<String> linkedList = new LinkedList<>();
```

## ArrayList vs LinkedList

|항목|ArrayList|LinkedList|
|---|---|---|
|내부 구조|배열|노드 연결|
|조회|O(1) 빠름|O(n) 느림|
|삽입/삭제 (중간)|O(n) 느림|O(1) 빠름|
|메모리|연속|분산|

## 기본 사용법

```java
List<String> names = new ArrayList<>();

// 추가
names.add("홍길동");
names.add("김철수");
names.add("홍길동");  // 중복 허용

// 조회
names.get(0);    // "홍길동"
names.size();    // 3

// 수정
names.set(0, "박영희");

// 삭제
names.remove(0);           // 인덱스로 삭제
names.remove("김철수");    // 값으로 삭제

// 포함 여부
names.contains("홍길동");  // true/false
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
|**List**|O|O|인덱스|
|**Set**|X|X|값 자체|
|**Map**|X|키 X, 값 O|키|

## 언제 사용하나?

```java
// 순서가 중요하고 중복 허용
List<Order> orderHistory = new ArrayList<>();

// 인덱스 접근이 필요할 때
List<String> ranking = new ArrayList<>();
ranking.get(0);  // 1등
```

---

**분류: 자료구조**