---
title: "DI"
tags: [Spring, IoC]
status: published
---

**객체가 필요한 의존성을 직접 만들지 않고 외부에서 주입받는 설계 패턴**입니다 (Dependency Injection). Spring 같은 프레임워크가 객체를 만들고 연결해주므로, 클래스끼리의 결합도가 낮아지고 테스트가 쉬워집니다.

## 왜 필요한가?

```java
[ DI 없이 — 강한 결합 ]
public class UserService {
    private EmailService emailService = new EmailService();
                                          ↑ UserService가 직접 만듦

    public void register(User user) {
        // ...
        emailService.send(user.email, "환영합니다");
    }
}
```

```
문제점:
1. UserService가 EmailService 구현체에 강하게 묶여있음
   → 다른 메일 서비스로 바꾸려면 UserService 수정 필요

2. 테스트할 때 진짜 EmailService가 같이 동작
   → 단위 테스트 어려움 (실제 메일 전송 시도)

3. EmailService 생성 비용을 UserService가 떠안음
   → 매번 new EmailService() 호출
```

```
[ DI 사용 — 느슨한 결합 ]
public class UserService {
    private final EmailService emailService;

    public UserService(EmailService emailService) {   // 외부에서 받음
        this.emailService = emailService;
    }
    // ...
}
```

```
이점:
1. UserService는 EmailService라는 "역할"만 알면 됨 (구현체 무관)
2. 테스트 시 가짜 객체(Mock)를 주입 가능
3. 객체 생성 책임이 외부(Spring)로 이동
```

## DI의 3가지 방법

### 1. **생성자 주입** (권장)

```java
@Service
public class UserService {
    private final EmailService emailService;

    public UserService(EmailService emailService) {
        this.emailService = emailService;
    }
}
```

- **불변성 보장** (`final`)
- **순환 참조 컴파일 시점 발견**
- **필수 의존성 명시**
- Spring 4.3+에서는 `@Autowired` 생략 가능

### 2. **필드 주입** (비권장)

```java
@Service
public class UserService {
    @Autowired
    private EmailService emailService;
}
```

- 코드는 짧지만 **테스트 어려움** (Spring 없이 주입 불가)
- **순환 참조를 런타임까지 못 찾음**

### 3. **세터 주입** (선택적)

```java
@Service
public class UserService {
    private EmailService emailService;

    @Autowired
    public void setEmailService(EmailService emailService) {
        this.emailService = emailService;
    }
}
```

- **선택적(optional) 의존성**일 때 사용
- 일반적이지 않음

## Spring이 DI를 처리하는 흐름

```
[ 애플리케이션 시작 ]

1. ComponentScan
   → @Component, @Service 등이 붙은 클래스 탐색

2. Bean 생성
   → 각 클래스를 인스턴스화해서 [[Spring Container|Spring 컨테이너]]에 등록

3. 의존성 분석
   → 각 빈의 생성자/필드/세터에서 필요로 하는 타입 파악

4. 의존성 주입
   → 컨테이너에서 해당 타입의 빈을 찾아 주입

5. 애플리케이션 사용 가능 상태
```

```
[ 시각화 ]

@Component
class EmailService { }       ← 빈 1번 생성

@Service
class UserService {           ← 빈 2번 생성
    UserService(EmailService e) { ... }
                  ↑
        Spring이 EmailService 빈을 찾아서 주입
}
```

## DI vs [[IoC]]

```
IoC (Inversion of Control) = 제어의 역전
   "객체의 생성·생명주기를 외부(컨테이너)가 관리한다"는 큰 개념

DI (Dependency Injection) = IoC의 구체적 구현 방식
   "필요한 객체를 외부에서 주입받는다"는 패턴

→ DI는 IoC를 실현하는 한 가지 방법
```

```
IoC를 구현하는 다른 방법들:
- DI (의존성 주입) ← 가장 흔함
- Service Locator
- 템플릿 메서드 패턴
```

## 장점 정리

|항목|설명|
|---|---|
|**낮은 결합도**|구현체가 아닌 인터페이스에 의존|
|**테스트 용이**|Mock 객체 주입으로 단위 테스트 가능|
|**책임 분리**|객체 생성 ↔ 비즈니스 로직 분리|
|**유연한 교체**|구현체만 바꾸면 동작 전환 ([[SOLID]] OCP 원칙)|
|**싱글톤 보장**|컨테이너가 한 번만 생성해 재사용|

## 자주 쓰는 어노테이션

|어노테이션|용도|
|---|---|
|[[@Component]]|클래스를 빈으로 등록|
|[[@Service]]|서비스 계층 빈 등록 (= @Component + 의미)|
|[[@Repository]]|데이터 계층 빈 등록 + 예외 변환|
|[[@Controller]]|웹 계층 빈 등록|
|`@Autowired`|자동 주입|
|`@Bean`|메서드 반환값을 빈으로 등록 (외부 라이브러리)|
|`@Qualifier`|같은 타입 빈이 여러 개일 때 이름 지정|
|`@Primary`|같은 타입 빈 중 우선순위|

## 핵심 정리

DI는 **객체가 의존성을 직접 만들지 않고 외부에서 주입받는 패턴**으로, [[SOLID]] 원칙(특히 OCP, DIP)을 코드로 구현하는 핵심 도구입니다. Spring은 [[Spring Container|Spring 컨테이너]]가 빈을 만들고 의존성을 자동 주입하며, 주입 방법은 **생성자(권장) / 필드 / 세터** 세 가지입니다. DI를 통해 결합도가 낮아지고 단위 테스트가 쉬워지며, [[IoC]]라는 더 큰 개념의 한 구현 방식입니다.
