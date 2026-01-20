**JPQL(Java Persistence Query Language)** 은 **엔티티 객체를 대상으로 쿼리하는 JPA 전용 쿼리 언어**입니다.

## 쉽게 말하면

SQL은 **테이블**을 대상으로 쿼리하고, JPQL은 **엔티티(객체)** 를 대상으로 쿼리해요.

## SQL vs JPQL 비교

**SQL (테이블 대상)**

```sql
SELECT * FROM users WHERE name = '홍길동'
```

**JPQL (엔티티 대상)**

```java
SELECT u FROM User u WHERE u.name = '홍길동'
```

|구분|SQL|JPQL|
|---|---|---|
|대상|테이블, 컬럼|엔티티, 필드|
|대소문자|구분 안 함|엔티티/필드는 구분함|
|결과|Row|엔티티 객체|

## 왜 필요한가?

`entityManager.find()`는 단순 조회만 가능해요.
JPA 기본 메서드로는 사용이 불가할 때 사용

```java
// 이건 가능 - ID로 단건 조회
User user = entityManager.find(User.class, 1L);

// 이런 건 불가능 - 복잡한 조건 조회
// 이름이 '홍길동'인 사용자 전체 조회?
// 나이가 20 이상인 사용자?
```

이런 복잡한 조회를 위해 JPQL이 필요합니다.

## 사용 예시

```java
// 기본 조회
String jpql = "SELECT u FROM User u WHERE u.name = :name";
List<User> users = entityManager.createQuery(jpql, User.class)
    .setParameter("name", "홍길동")
    .getResultList();

// 조건 조회
String jpql2 = "SELECT u FROM User u WHERE u.age >= 20";

// 정렬
String jpql3 = "SELECT u FROM User u ORDER BY u.createdAt DESC";

// 조인
String jpql4 = "SELECT u FROM User u JOIN u.team t WHERE t.name = '개발팀'";
```

## JPQL의 장점

```java
// JPQL - DB가 바뀌어도 코드 변경 없음
"SELECT u FROM User u WHERE u.name = :name"

// 실행 시 각 DB에 맞게 변환됨
// MySQL: SELECT * FROM users WHERE name = ?
// Oracle: SELECT * FROM USERS WHERE NAME = ?
```

## Spring Data JPA에서는

직접 JPQL 작성할 일이 줄어들어요.

```java
public interface UserRepository extends JpaRepository<User, Long> {
    
    // 메서드 이름으로 자동 생성
    List<User> findByName(String name);
    
    // 직접 JPQL 작성도 가능
    @Query("SELECT u FROM User u WHERE u.age >= :age")
    List<User> findByAgeGreaterThan(@Param("age") int age);
}
```

## 한줄 요약

JPQL = **테이블이 아닌 엔티티 객체를 대상으로 하는 SQL과 비슷한 쿼리 언어**