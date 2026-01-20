**Native Query**는 **JPA에서 SQL을 직접 사용하는 방식**입니다.

## 쉽게 말하면

JPQL이 아니라 **진짜 SQL**을 그대로 쓰는 거예요.

## JPQL vs Native Query

**JPQL (엔티티 대상)**

```java
String jpql = "SELECT u FROM User u WHERE u.name = :name";
```

**Native Query (테이블 대상)**

```java
String sql = "SELECT * FROM users WHERE name = ?";
```

## 사용 예시

```java
// Native Query 사용
String sql = "SELECT * FROM users WHERE name = ?";
List<User> users = entityManager
    .createNativeQuery(sql, User.class)
    .setParameter(1, "홍길동")
    .getResultList();
```

## Spring Data JPA에서

```java
public interface UserRepository extends JpaRepository<User, Long> {
    
    // JPQL
    @Query("SELECT u FROM User u WHERE u.name = :name")
    List<User> findByNameJPQL(@Param("name") String name);
    
    // Native Query
    @Query(value = "SELECT * FROM users WHERE name = :name", nativeQuery = true)
    List<User> findByNameNative(@Param("name") String name);
}
```

## 언제 사용하나?

|상황|추천|
|---|---|
|일반적인 CRUD|JPQL 또는 메서드 쿼리|
|DB 고유 기능 사용|Native Query|
|복잡한 통계/집계|Native Query|
|성능 최적화 필요|Native Query|

```java
// 예: MySQL 전용 함수 사용
@Query(value = "SELECT * FROM users WHERE MATCH(name) AGAINST(:keyword)", 
       nativeQuery = true)
List<User> fullTextSearch(@Param("keyword") String keyword);
```

## 장단점

|구분|JPQL|Native Query|
|---|---|---|
|DB 독립성|⭕ 유지됨|❌ DB 종속|
|엔티티 매핑|자동|직접 설정 필요할 수 있음|
|DB 고유 기능|❌ 제한적|⭕ 모두 사용 가능|
|성능 최적화|제한적|세밀한 튜닝 가능|

## 한줄 요약

Native Query = **JPA에서 SQL을 직접 사용하는 방법** (DB 고유 기능이나 복잡한 쿼리가 필요할 때 사용)