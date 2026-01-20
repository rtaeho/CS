JPA(Java Persistence API)는 자바 객체와 관계형 데이터베이스를 매핑해주는 ORM 표준 명세입니다.

## 핵심 개념

**ORM (Object-Relational Mapping)**

- 객체와 테이블을 자동으로 매핑
- SQL을 직접 작성하지 않고 객체 중심으로 개발

```java
// SQL 직접 작성 (JDBC)
String sql = "INSERT INTO member (name, age) VALUES (?, ?)";

// JPA 사용
Member member = new Member("홍길동", 25);
entityManager.persist(member);  // 객체만 저장하면 끝
```

## JPA는 "명세"일 뿐

JPA 자체는 인터페이스(표준 스펙)이고, 실제 구현체가 필요합니다.

|구분|설명|
|---|---|
|**JPA**|표준 명세 (인터페이스)|
|**Hibernate**|가장 널리 쓰이는 구현체|
|**Spring Data JPA**|JPA를 더 편하게 쓰도록 감싼 추상화 계층|

```
Spring Data JPA
      ↓ 사용
     JPA (표준 인터페이스)
      ↓ 구현
   Hibernate (구현체)
      ↓ 사용
    JDBC → DB
```

## 주요 기능

- **엔티티 매핑**: `@Entity`, `@Table`, `@Column`
- **연관관계 매핑**: `@OneToMany`, `@ManyToOne`
- **영속성 컨텍스트**: 1차 캐시, 변경 감지, 지연 로딩

간단히 말해, **SQL 대신 객체로 DB를 다루게 해주는 기술**입니다.