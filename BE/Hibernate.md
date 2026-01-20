**Hibernate**는 Java 진영에서 가장 널리 쓰이는 **ORM(Object-Relational Mapping) 프레임워크**입니다.

## 핵심 개념

ORM은 객체(Object)와 관계형 데이터베이스(Relational DB)를 자동으로 매핑해주는 기술이에요. 쉽게 말해, SQL을 직접 작성하지 않고도 Java 객체를 통해 DB를 다룰 수 있게 해줍니다.

## 예시

**Hibernate 없이 ([[JDBC]] 직접 사용)**

```java
String sql = "INSERT INTO users (name, email) VALUES (?, ?)";
PreparedStatement stmt = conn.prepareStatement(sql);
stmt.setString(1, "홍길동");
stmt.setString(2, "hong@example.com");
stmt.executeUpdate();
```

**Hibernate 사용**

```java
User user = new User("홍길동", "hong@example.com");
session.save(user);  // 끝!
```

## 주요 장점

1. **생산성 향상**: 반복적인 CRUD SQL 작성이 필요 없음
2. **DB 독립성**: MySQL, PostgreSQL, Oracle 등 DB를 바꿔도 코드 수정이 거의 없음
3. **객체 지향적 개발**: 테이블이 아닌 객체 중심으로 설계 가능
4. **캐싱**: 1차/2차 캐시를 통한 성능 최적화

## JPA와의 관계

- **JPA(Java Persistence API)**: Java ORM의 표준 인터페이스(스펙)
- **Hibernate**: JPA를 구현한 구현체 중 하나 (가장 유명함)

Spring Boot에서는 보통 **Spring Data JPA + Hibernate** 조합으로 많이 사용합니다.