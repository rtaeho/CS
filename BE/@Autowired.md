---
title: "@Autowired"
tags: [Spring, DI, IoC]
status: published
---

Spring이 타입을 기준으로 빈을 자동으로 찾아 주입해주는 어노테이션으로, 주입 방식은 필드·세터·생성자 세 가지이며 **생성자 주입이 표준**입니다.

## 주입 방식 3가지

### 필드 주입

```java
@Service
public class OrderService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PaymentService paymentService;
}
```

- `final` 선언 불가 → 런타임 변경 가능성 열려 있음
- `new OrderService()`로 생성하면 `null` → Spring 없이 테스트 불가
- 순환 의존성을 시작 시점에 감지 못함

### 세터 주입

```java
@Service
public class OrderService {

    private UserRepository userRepository;

    @Autowired
    public void setUserRepository(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
}
```

- 선택적 의존성(없어도 동작 가능)에만 제한적으로 사용

```java
@Autowired(required = false)
public void setOptionalPlugin(Plugin plugin) {
    this.plugin = plugin;  // 빈이 없으면 null, 오류 없음
}
```

### 생성자 주입 — 권장

```java
@Service
public class OrderService {

    private final UserRepository userRepository;
    private final PaymentService paymentService;

    // 생성자가 1개면 @Autowired 생략 가능
    public OrderService(UserRepository userRepository,
                        PaymentService paymentService) {
        this.userRepository = userRepository;
        this.paymentService = paymentService;
    }
}
```

Lombok `@RequiredArgsConstructor`로 더 간결하게:

```java
@Service
@RequiredArgsConstructor
public class OrderService {
    private final UserRepository userRepository;
    private final PaymentService paymentService;
}
```

## 생성자 주입을 권장하는 이유

**테스트 가능**
```java
// Spring 없이 순수 Java 테스트 가능
OrderService sut = new OrderService(new FakeUserRepository(), new FakePaymentService());
```

**불변성 보장**
```java
private final UserRepository userRepository;
// final → 한 번 주입 후 변경 불가
```

**순환 의존성 조기 발견**
```
A → B → A 순환이 있을 때
  생성자 주입: 컨테이너 시작 시점에 즉시 오류 → 배포 전 발견
  필드 주입:   런타임 호출 시점까지 오류 안 남
```

**의존성이 명확히 드러남**
```java
// 생성자 파라미터가 너무 많으면 → 책임이 너무 많다는 신호 → 리팩토링 타이밍
public OrderService(UserRepository repo,
                    PaymentService payment,
                    NotificationService notification,
                    DiscountPolicy discount) { ... }
```

## 비교 요약

| 방식 | final | 테스트 | 권장 |
|---|---|---|---|
| 필드 주입 | X | X | X |
| 세터 주입 | X | 가능 | 선택적 의존성만 |
| 생성자 주입 | O | O | **O 표준** |

## 같은 타입 빈이 여러 개일 때

```java
public interface DiscountPolicy { int discount(int price); }

@Component public class RateDiscount implements DiscountPolicy { ... }  // 10% 할인
@Component public class FixDiscount implements DiscountPolicy { ... }   // 1000원 할인
```

주입 시 `NoUniqueBeanDefinitionException` 발생 → 아래 3가지로 해결:

```java
// 1. @Primary — 우선 빈 지정
@Component @Primary
public class RateDiscount implements DiscountPolicy { ... }

// 2. @Qualifier — 이름 명시 (더 구체적)
@Component @Qualifier("rateDiscount")
public class RateDiscount implements DiscountPolicy { ... }

@Service
public class OrderService {
    public OrderService(@Qualifier("rateDiscount") DiscountPolicy policy) { ... }
}

// 3. 변수명 매칭 (최후 수단)
public OrderService(DiscountPolicy rateDiscount) { ... }
// 변수명 == 빈 이름으로 자동 매칭
```

> 우선순위: `@Qualifier` > `@Primary` > 변수명 매칭

## 연관 개념

- [[DI]] — 의존성 주입 개념 자체
- [[IoC]] — 제어의 역전, @Autowired의 철학적 배경
- [[Spring Container]] — 빈을 관리하고 주입을 처리하는 주체
- [[@Component]] — 주입 대상이 되는 빈 등록 어노테이션
