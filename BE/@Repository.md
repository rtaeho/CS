Spring에서 데이터 접근을 담당하는 계층 빈을 등록하는 어노테이션입니다. DB와 통신하며, 예외 변환 기능이 추가되어 있습니다.

## 기본 사용법

```java
@Repository
public class UserRepository {
    
    @PersistenceContext
    private EntityManager em;
    
    public User findById(Long id) {
        return em.find(User.class, id);
    }
    
    public void save(User user) {
        em.persist(user);
    }
    
    public List<User> findAll() {
        return em.createQuery("SELECT u FROM User u", User.class)
            .getResultList();
    }
}
```

## 계층 구조에서의 위치

```
@Controller  ─ 요청/응답 처리
    ↓
@Service     ─ 비즈니스 로직
    ↓
@Repository  ─ DB 접근 ← 여기
    ↓
[Database]
```

## @Repository만의 특별한 기능: 예외 변환

```java
@Repository
public class UserRepository {
    
    public void save(User user) {
        // SQLException, JPA 예외 발생 시
        // → DataAccessException으로 자동 변환
    }
}
```

```
[DB별 예외]
├─ MySQL: MySQLIntegrityConstraintViolationException
├─ Oracle: OracleSQLException
├─ PostgreSQL: PSQLException
    ↓
[Spring 표준 예외]
└─ DataAccessException
   ├─ DataIntegrityViolationException
   ├─ DuplicateKeyException
   └─ EmptyResultDataAccessException
```

## 왜 예외 변환이 필요한가?

```java
// ❌ DB 종속적인 예외 처리
try {
    userRepository.save(user);
} catch (MySQLIntegrityConstraintViolationException e) {
    // MySQL에서만 동작
}

// ✅ Spring 표준 예외로 처리
try {
    userRepository.save(user);
} catch (DataIntegrityViolationException e) {
    // 어떤 DB든 동작
}
```

- DB 변경해도 예외 처리 코드 수정 불필요
- 기술에 종속되지 않는 코드

## @Repository vs @Component

|항목|@Component|@Repository|
|---|---|---|
|빈 등록|O|O|
|예외 변환|X|O|
|용도|범용|데이터 접근 계층|

## Spring Data JPA 사용 시

```java
// 인터페이스만 정의하면 구현체 자동 생성
public interface UserRepository extends JpaRepository<User, Long> {
    
    List<User> findByName(String name);
    
    Optional<User> findByEmail(String email);
}
```

- `@Repository` 안 붙여도 됨
- Spring Data JPA가 자동으로 빈 등록 + 예외 변환 처리

## 실무 패턴

```java
// 커스텀 쿼리가 필요한 경우
public interface UserRepository extends JpaRepository<User, Long> {
    
    @Query("SELECT u FROM User u WHERE u.status = :status")
    List<User> findActiveUsers(@Param("status") Status status);
}

// 복잡한 쿼리는 별도 구현
@Repository
@RequiredArgsConstructor
public class UserQueryRepository {
    
    private final JPAQueryFactory queryFactory;
    
    public List<UserDto> searchUsers(UserSearchCondition condition) {
        // QueryDSL 사용
    }
}
```