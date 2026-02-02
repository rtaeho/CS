키(Key)와 값(Value)의 쌍으로 데이터를 저장하는 자료구조입니다. 키로 값을 빠르게 조회할 수 있습니다.

## 특징

|항목|설명|
|---|---|
|키 중복|허용 안 함|
|값 중복|허용|
|순서|구현체에 따라 다름|
|조회|키로 O(1) 접근|

## Java에서의 Map

```java
// 인터페이스
Map<String, Integer> map;

// 주요 구현체
Map<String, Integer> hashMap = new HashMap<>();
Map<String, Integer> linkedHashMap = new LinkedHashMap<>();
Map<String, Integer> treeMap = new TreeMap<>();
```

## 구현체별 차이

|구현체|순서|정렬|성능|
|---|---|---|---|
|**HashMap**|없음|없음|O(1) 가장 빠름|
|**LinkedHashMap**|삽입 순서 유지|없음|O(1)|
|**TreeMap**|키 기준 정렬|자동 정렬|O(log n)|

## 기본 사용법

```java
Map<String, Integer> scores = new HashMap<>();

// 추가
scores.put("홍길동", 90);
scores.put("김철수", 85);
scores.put("홍길동", 95);  // 키 중복 → 값 덮어씀

// 조회
scores.get("홍길동");       // 95
scores.getOrDefault("박영희", 0);  // 없으면 0 반환

// 포함 여부
scores.containsKey("홍길동");   // true
scores.containsValue(90);       // false

// 삭제
scores.remove("홍길동");

// 크기
scores.size();
```

## 순회

```java
Map<String, Integer> map = new HashMap<>();

// 키 순회
for (String key : map.keySet()) {
    System.out.println(key);
}

// 값 순회
for (Integer value : map.values()) {
    System.out.println(value);
}

// 키-값 쌍 순회
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    System.out.println(entry.getKey() + ": " + entry.getValue());
}

// forEach
map.forEach((key, value) -> {
    System.out.println(key + ": " + value);
});
```

## 유용한 메서드

```java
// 없을 때만 추가
map.putIfAbsent("홍길동", 100);

// 값 계산해서 추가
map.computeIfAbsent("홍길동", k -> calculateScore(k));

// 값 변환
map.compute("홍길동", (k, v) -> v == null ? 0 : v + 10);

// 병합
map.merge("홍길동", 10, Integer::sum);  // 기존 값 + 10
```

## List, Set, Map 비교

|자료구조|저장 방식|중복|순서|용도|
|---|---|---|---|---|
|**List**|값|O|O|순서 있는 목록|
|**Set**|값|X|X|고유 값 집합|
|**Map**|키-값 쌍|키 X|X|키로 값 조회|

## 언제 사용하나?

```java
// 빠른 조회가 필요할 때
Map<Long, User> userCache = new HashMap<>();
User user = userCache.get(userId);

// 그룹핑
Map<String, List<User>> usersByCity = new HashMap<>();

// 카운팅
Map<String, Integer> wordCount = new HashMap<>();
wordCount.merge(word, 1, Integer::sum);

// 설정값 관리
Map<String, String> config = new HashMap<>();
```
