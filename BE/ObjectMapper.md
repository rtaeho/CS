Jackson 라이브러리에서 JSON과 Java 객체 간의 [[직렬화]]·역직렬화를 수행하는 핵심 클래스입니다.

## 핵심 특징

- `readValue()`: JSON 문자열을 Java 객체로 역직렬화
- `writeValueAsString()`: Java 객체를 JSON 문자열로 직렬화
- Spring MVC의 [[HttpMessageConverter]] 내부에서 JSON 처리에 사용됨
- 기본 생성자와 getter/setter가 있어야 역직렬화 가능
- [[record]] 역직렬화 시 모든 필드를 초기화하는 생성자를 사용

## 주요 사용 예시

```java
ObjectMapper mapper = new ObjectMapper();

// JSON → 객체 (역직렬화)
String json = "{\"name\":\"Alice\",\"age\":30}";
Person person = mapper.readValue(json, Person.class);

// 객체 → JSON (직렬화)
String result = mapper.writeValueAsString(person);
```

## 핵심 정리

ObjectMapper는 [[HttpMessageConverter]]와 함께 Spring REST API에서 JSON 요청/응답을 Java 객체로 자동 변환합니다.
