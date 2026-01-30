Spring에서 비즈니스 로직을 처리하는 서비스 계층 빈을 등록하는 어노테이션입니다. Controller와 Repository 사이에서 핵심 로직을 담당합니다.

## 기본 사용법

```java
@Service
public class UserService {
    
    private final UserRepository userRepository;
    
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
    
    public User findById(Long id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException(id));
    }
    
    @Transactional
    public User createUser(UserDto dto) {
        // 비즈니스 로직
        validateDuplicate(dto.getEmail());
        User user = new User(dto.getName(), dto.getEmail());
        return userRepository.save(user);
    }
}
```

## 계층 구조에서의 위치

```
@Controller  ─ 요청/응답 처리
    ↓
@Service     ─ 비즈니스 로직 ← 여기
    ↓
@Repository  ─ DB 접근
```

## @Service vs @Component

```java
// 동작은 동일
@Component
public class UserService { }

@Service
public class UserService { }
```

|항목|@Component|@Service|
|---|---|---|
|기능|빈 등록|빈 등록|
|추가 기능|없음|없음|
|차이점|범용|서비스 계층 명시|

- @Service는 @Component와 기능 차이 없음
- 순수하게 의미적 구분 목적

## 왜 구분해서 쓰나?

```java
// ❌ 역할을 알 수 없음
@Component
public class UserService { }

@Component
public class UserRepository { }

// ✅ 역할이 명확함
@Service
public class UserService { }

@Repository
public class UserRepository { }
```

- 코드 가독성 향상
- 계층별 역할 명확화
- AOP 적용 시 계층별 구분 가능

## 트랜잭션 처리

```java
@Service
public class OrderService {
    
    @Transactional
    public void createOrder(OrderDto dto) {
        // 재고 차감
        productService.decreaseStock(dto.getProductId());
        
        // 주문 생성
        Order order = new Order(dto);
        orderRepository.save(order);
        
        // 결제 처리
        paymentService.pay(dto.getPaymentInfo());
        
        // 하나라도 실패하면 전체 롤백
    }
}
```

- 서비스 계층에서 트랜잭션 관리
- 여러 Repository 호출을 하나의 트랜잭션으로 묶음

## 실무 패턴

```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)  // 기본 읽기 전용
public class UserService {
    
    private final UserRepository userRepository;
    
    public User findById(Long id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException(id));
    }
    
    @Transactional  // 쓰기 작업만 트랜잭션 적용
    public User create(UserDto dto) {
        return userRepository.save(new User(dto));
    }
}
```
