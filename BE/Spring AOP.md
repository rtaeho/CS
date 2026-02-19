Spring에서 핵심 비즈니스 로직과 부가 기능(로깅, 트랜잭션, 보안 등)을 분리하여 모듈화하는 프로그래밍 기법입니다.

## AOP가 필요한 이유

```
[AOP 적용 전 - 부가 기능이 핵심 로직에 섞임]
public void createOrder() {
    log.info("주문 시작");           // 로깅
    checkAuth();                     // 보안
    beginTransaction();              // 트랜잭션
    orderRepository.save(order);     // ★ 핵심 로직
    commitTransaction();             // 트랜잭션
    log.info("주문 완료");           // 로깅
}

[AOP 적용 후 - 핵심 로직만 남음]
@Transactional
@Logging
public void createOrder() {
    orderRepository.save(order);     // ★ 핵심 로직만 집중
}
```

## 핵심 용어

|용어|설명|
|---|---|
|**Aspect**|부가 기능을 모듈화한 클래스 (로깅, 트랜잭션 등)|
|**Advice**|부가 기능의 실제 구현 (언제 실행할지 정의)|
|**JoinPoint**|Advice가 적용될 수 있는 지점 (메서드 실행 시점)|
|**Pointcut**|Advice를 적용할 대상을 선별하는 표현식|
|**Target**|Advice가 적용되는 실제 객체|
|**Proxy**|Target을 감싸서 부가 기능을 제공하는 대리 객체|

## 동작 원리

```
클라이언트 → 프록시 객체 → Advice 실행 → Target 메서드 실행 → Advice 실행 → 반환
              (Spring이 자동 생성)
```

Spring은 **프록시 패턴**을 사용하여 AOP를 구현합니다.

|방식|설명|
|---|---|
|**JDK 동적 프록시**|인터페이스 기반, 인터페이스를 구현한 경우 사용|
|**CGLIB 프록시**|클래스 기반, 인터페이스가 없는 경우 사용 (Spring 기본값)|

## Advice 종류

|종류|실행 시점|용도|
|---|---|---|
|**@Before**|메서드 실행 전|권한 체크, 파라미터 검증|
|**@AfterReturning**|메서드 정상 완료 후|결과 로깅, 후처리|
|**@AfterThrowing**|예외 발생 후|에러 로깅, 알림|
|**@After**|메서드 완료 후 (성공/실패 무관)|리소스 정리|
|**@Around**|메서드 실행 전후 모두|시간 측정, 트랜잭션, 가장 강력|

```
@Before → Target 메서드 실행 → @AfterReturning (성공 시)
                              → @AfterThrowing  (예외 시)
                              → @After          (항상)

@Around: 위 전체를 감싸서 제어 가능
```

## 구현 예시

### 1. 실행 시간 측정

```java
@Aspect
@Component
public class ExecutionTimeAspect {

    @Around("execution(* com.example.service.*.*(..))")
    public Object measureTime(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();

        Object result = joinPoint.proceed();  // 실제 메서드 실행

        long end = System.currentTimeMillis();
        log.info("{} 실행 시간: {}ms",
                joinPoint.getSignature().getName(), end - start);

        return result;
    }
}
```

### 2. 로깅 AOP

```java
@Aspect
@Component
public class LoggingAspect {

    @Before("execution(* com.example.service.*.*(..))")
    public void logBefore(JoinPoint joinPoint) {
        log.info("[호출] {} - args: {}",
                joinPoint.getSignature().getName(),
                Arrays.toString(joinPoint.getArgs()));
    }

    @AfterReturning(pointcut = "execution(* com.example.service.*.*(..))",
                     returning = "result")
    public void logAfter(JoinPoint joinPoint, Object result) {
        log.info("[완료] {} - result: {}",
                joinPoint.getSignature().getName(), result);
    }

    @AfterThrowing(pointcut = "execution(* com.example.service.*.*(..))",
                    throwing = "ex")
    public void logError(JoinPoint joinPoint, Exception ex) {
        log.error("[에러] {} - {}",
                joinPoint.getSignature().getName(), ex.getMessage());
    }
}
```

### 3. 커스텀 어노테이션 기반 AOP

```java
// 커스텀 어노테이션 정의
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RoleCheck {
    String value();  // 필요한 권한
}

// Aspect 구현
@Aspect
@Component
public class RoleCheckAspect {

    @Before("@annotation(roleCheck)")
    public void checkRole(JoinPoint joinPoint, RoleCheck roleCheck) {
        String requiredRole = roleCheck.value();
        String currentRole = SecurityContextHolder.getContext().getRole();

        if (!currentRole.equals(requiredRole)) {
            throw new AccessDeniedException("권한 없음: " + requiredRole + " 필요");
        }
    }
}

// 사용
@Service
public class AdminService {

    @RoleCheck("ADMIN")
    public void deleteUser(Long userId) {
        userRepository.deleteById(userId);
    }
}
```

## Pointcut 표현식

```java
// 패키지 내 모든 메서드
@Around("execution(* com.example.service.*.*(..))")

// 특정 어노테이션이 붙은 메서드
@Around("@annotation(com.example.annotation.Logging)")

// 특정 어노테이션이 붙은 클래스의 모든 메서드
@Around("@within(org.springframework.stereotype.Service)")

// 조합 (AND, OR)
@Around("execution(* com.example.service.*.*(..)) && @annotation(Logging)")
```

## AOP가 적용된 Spring 기능들

|기능|설명|
|---|---|
|**@Transactional**|트랜잭션 관리|
|**@Cacheable**|캐시 처리|
|**@Async**|비동기 실행|
|**@Secured / @PreAuthorize**|보안/권한 체크|
|**@Retryable**|재시도 처리|

이들이 모두 프록시 기반 AOP로 동작하기 때문에, **내부 호출 시 미적용**, **public 메서드만 적용** 등의 동일한 제약이 존재합니다.