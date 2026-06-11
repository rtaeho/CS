---
title: "Spring Proxy"
tags: [Spring, 프록시, AOP]
status: published
---

**런타임에 자동으로 만들어진 자식 클래스가 원본의 메서드 호출을 가로채서 부가 동작을 끼워넣는 메커니즘**입니다. Spring의 거의 모든 어노테이션 기반 기능(`@Transactional`, `@Async`, `@Cacheable`, `@Configuration`, AOP 등)이 이 원리로 동작합니다.

## 왜 필요한가?

```
[ 일반 자바 ]
class UserService {
    void register(User u) {
        userRepo.save(u);
    }
}

→ register()는 적힌 본문만 실행. 트랜잭션·로깅·캐시 같은 부가 동작은 직접 짜야 함.
```

```java
[ 프록시 활용 ]
class UserService {
    @Transactional
    void register(User u) {
        userRepo.save(u);
    }
}

→ 어노테이션만 붙였는데 메서드 시작 시 BEGIN, 끝나면 COMMIT/ROLLBACK 자동 처리
→ 비즈니스 로직 코드는 깨끗하게 유지
→ 부가 동작 = 프록시가 가로채서 처리
```

## 동작 원리 — 런타임 자식 클래스 생성

```java
[ 너의 코드 ]
@Service
class UserService {
    @Transactional
    void register(User u) { ... }
}


[ Spring이 시작 시 만드는 자식 클래스 (메모리에서만 존재) ]
class UserService$$EnhancerByCGLIB$$abc123 extends UserService {

    @Override
    void register(User u) {
        TransactionStatus tx = txManager.begin();   // 부가 동작 (전)
        try {
            super.register(u);                        // 진짜 메서드 호출
            txManager.commit(tx);                     // 부가 동작 (후)
        } catch (Exception e) {
            txManager.rollback(tx);
            throw e;
        }
    }
}


[ Spring이 컨테이너에 등록 ]
"userService" → UserService$$EnhancerByCGLIB$$abc123 인스턴스
                                    ↑
                            진짜 UserService가 아니라 자식
```

```java
[ 호출 시 ]
@Autowired UserService userService;   // 실제로는 자식 인스턴스
userService.register(u);              // 자식의 오버라이드 메서드 호출
                                       // → 가로채기 발동 (트랜잭션 처리)
                                       // → super.register(u)로 진짜 본문 실행
```

자바의 **다형성 + 상속 + 오버라이드** 그 자체야. 다만 자식 클래스를 컴파일 타임이 아니라 런타임에 만든다는 점이 다름.

## 두 가지 프록시 기술

### CGLIB — 클래스 상속

```
대상 클래스를 상속받은 자식을 만듦.

class UserService$$Proxy extends UserService { ... }

O 인터페이스 없어도 OK
X final 클래스/메서드 사용 불가 (상속 못 함)
```

### JDK Dynamic Proxy — 인터페이스 구현

```
대상이 구현한 인터페이스를 구현하는 새 클래스를 만듦.

class $Proxy implements UserService { ... }

O 가벼움 (CGLIB보다 빠름)
X 대상이 인터페이스를 구현해야 함
```

| 항목 | CGLIB | JDK Dynamic Proxy |
|---|---|---|
| 동작 방식 | 자식 클래스 생성 | 인터페이스 구현체 생성 |
| 대상 | 클래스 (구체 타입) | 인터페이스 |
| 제약 | `final` 안 됨 | 인터페이스 필수 |
| 성능 | 약간 느림 | 빠름 |
| Spring Boot 2.0+ | **기본값** | 옵션 |

> Spring Boot 2.0 이후로는 인터페이스가 있어도 기본적으로 CGLIB 사용. 이유: `@Async` 등 일부 어노테이션이 클래스 기반이라 일관성 위해.

## 프록시로 구현되는 어노테이션

|어노테이션|프록시가 끼워넣는 부가 동작|
|---|---|
|[[@Configuration]]|`@Bean` 메서드 호출 → 컨테이너 캐시 반환 (싱글톤 보장)|
|[[@Transactional]]|메서드 시작 시 BEGIN, 끝나면 COMMIT/ROLLBACK|
|[[@Async]]|메서드를 별도 스레드에서 실행|
|[[@Cacheable]]|캐시 조회 → 히트면 반환, 미스면 실행 후 캐시 저장|
|`@CacheEvict`|메서드 실행 전후 캐시 삭제|
|[[Spring AOP]] (`@Aspect`, `@Around`, `@Before`)|임의 로직 끼워넣기 (로깅·검증·보안)|
|`@PreAuthorize`, `@Secured`|메서드 실행 전 권한 검사|
|`@Validated` (메서드 레벨)|매개변수 검증|
|`@Retryable`|예외 발생 시 자동 재시도|
|`@Scheduled` (일부 경우)|메서드를 스케줄러에 등록|

```
모두 같은 패턴:
  자식 클래스 만든다 → 메서드 오버라이드 → 부가 동작 + super 호출
```

## 어노테이션별 프록시 동작 비교

```java
// @Configuration
@Override
Pizza makePizza() {
    if (containerHas("pizza")) return container.get("pizza");
    return super.makePizza();
}

// @Transactional
@Override
void register(User u) {
    tx.begin();
    try { super.register(u); tx.commit(); }
    catch (Exception e) { tx.rollback(); throw e; }
}

// @Async
@Override
void sendEmail(String to) {
    executor.submit(() -> super.sendEmail(to));
}

// @Cacheable
@Override
Product findById(Long id) {
    Product cached = cache.get(id);
    if (cached != null) return cached;
    Product result = super.findById(id);
    cache.put(id, result);
    return result;
}

// AOP @Around
@Override
void placeOrder(Order o) {
    long start = System.currentTimeMillis();
    super.placeOrder(o);
    log.info("{}ms", System.currentTimeMillis() - start);
}
```

→ **가로채는 동작이 다를 뿐, 메커니즘은 동일**.

## 프록시 클래스 직접 보기

```java
@Autowired UserService userService;
System.out.println(userService.getClass().getName());
// 출력: com.example.UserService$$EnhancerByCGLIB$$abc123
//                              ↑ CGLIB이 만든 자식 클래스
```

진짜 `UserService`가 아니라 자식 클래스가 들어있다는 게 보임.

## 자주 만나는 함정

### 1. 같은 클래스 안에서 자기 자신 호출 시 프록시 안 탐

```java
@Service
public class OrderService {

    @Transactional
    public void outer() {
        inner();   // ← 같은 클래스의 메서드 호출
    }

    @Transactional
    public void inner() { ... }
}
```

```
호출자 → 프록시.outer() → 가로채기 발동 → super.outer() 실행
                                              ↓
                                          inner() 호출
                                              ↓
                                  this.inner() = super.inner()  ← 프록시 안 거침!
                                              ↓
                                          @Transactional 무시됨!
```

해결:
- 두 메서드를 다른 빈으로 분리
- 자기 자신을 `@Autowired`로 주입받아 호출 (자기 참조)
- AspectJ (load-time weaving) 사용

### 2. `final` 키워드 함정

```java
@Configuration
public final class AppConfig { ... }   // X CGLIB 상속 불가

@Service
public class UserService {
    @Transactional
    public final void register(User u) { ... }   // X 메서드도 안 됨
}
```

CGLIB이 자식 클래스를 만들고 메서드를 오버라이드해야 하는데, `final`은 그걸 막음.

### 3. private 메서드 가로채기 안 됨

```java
@Service
public class UserService {
    public void register(User u) {
        validate(u);   // ← @Transactional 붙어있어도 무의미
    }

    @Transactional
    private void validate(User u) { ... }
}
```

`private`은 외부에서 접근 불가 → 자식 클래스가 오버라이드 못 함 → 프록시 가로채기 불가.

### 4. 생성자에서 프록시 메서드 호출 시 가로채기 안 됨

```java
@Service
public class UserService {
    public UserService() {
        register(...);   // X 생성자에선 프록시 동작 안 함
    }

    @Transactional
    public void register(User u) { ... }
}
```

생성자 시점에는 아직 프록시가 만들어지지 않음.

## CGLIB vs JDK Dynamic Proxy — 코드 비교

### JDK Dynamic Proxy

```java
public interface UserService { void register(User u); }

@Service
public class UserServiceImpl implements UserService {
    @Override public void register(User u) { ... }
}

// JDK Dynamic Proxy 사용 시
// → JDK가 UserService 인터페이스를 구현하는 새 클래스 생성
// → 동적 클래스 + InvocationHandler

UserService proxy = (UserService) Proxy.newProxyInstance(
    UserService.class.getClassLoader(),
    new Class[] { UserService.class },
    (instance, method, args) -> {
        // 부가 동작
        Object result = method.invoke(target, args);
        // 부가 동작
        return result;
    }
);
```

### CGLIB

```java
@Service
public class StandaloneService {   // 인터페이스 없음
    public void doWork() { ... }
}

// CGLIB 사용 시
// → StandaloneService를 상속받는 자식 클래스 생성
// → 메서드 오버라이드로 가로챔
```

## 프록시가 핵심인 이유 — Spring의 3대 기능

```
Spring의 3대 핵심 기능:
1. IoC/DI    ← 컨테이너로 빈 관리
2. AOP       ← 프록시로 부가 동작 끼워넣기
3. 추상화    ← 트랜잭션·캐시 등 (프록시로 구현)

→ 2, 3번이 프록시 메커니즘 위에 세워짐
→ Spring을 "어노테이션 마법사"가 아니라 "체계적인 프록시 시스템"으로 이해할 수 있게 됨
```

## 핵심 정리

Spring 프록시는 **런타임에 원본 클래스를 상속(CGLIB)하거나 인터페이스를 구현(JDK Dynamic Proxy)한 자식을 만들어 메서드 호출을 가로채는 메커니즘**으로, [[@Configuration]]의 싱글톤 보장부터 [[@Transactional]] / [[@Async]] / [[@Cacheable]] / [[Spring AOP]] 등 거의 모든 어노테이션 기반 동작이 이 원리로 구현됩니다. 자바의 **상속 + 오버라이드 + 다형성**을 런타임에 동적으로 활용하는 것이 핵심이며, `final` 키워드, `private` 메서드, 자기 자신 호출, 생성자 안 호출 등에서는 프록시가 동작하지 않으므로 주의가 필요합니다.
