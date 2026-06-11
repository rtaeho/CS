**빈(Bean)을 생성·관리하고 의존성을 주입하는 Spring의 핵심 [[IoC]] 컨테이너**입니다. 개발자가 직접 `new`로 객체를 만들지 않고, 컨테이너에 등록된 빈을 가져다 씁니다.

## 왜 필요한가?

```
[ 컨테이너 없을 때 ]
public static void main(String[] args) {
    EmailService email = new EmailService();
    NotificationService notification = new NotificationService();
    UserService userService = new UserService(email, notification);
    Controller controller = new Controller(userService);
    // ...

    개발자가 직접 의존성 그래프를 따라가며 객체 생성·연결
    → 객체 수가 많아지면 관리 불가능
}
```

```
[ Spring 컨테이너 ]
@SpringBootApplication
public class App {
    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
        ↑ 컨테이너가 모든 빈을 알아서 생성·연결
    }
}

→ 개발자는 "어떤 빈이 필요한지"만 어노테이션으로 선언
→ 어떻게 만들고 연결할지는 컨테이너가 처리
```

## 두 가지 인터페이스: BeanFactory vs ApplicationContext

```
        BeanFactory (최상위)
        └─ ApplicationContext (확장)
            ├─ AnnotationConfigApplicationContext
            ├─ ClassPathXmlApplicationContext
            └─ WebApplicationContext (Spring Web에서 사용)
```

| 항목 | BeanFactory | ApplicationContext |
|---|---|---|
| 역할 | 빈 생성·조회의 가장 기본 기능 | BeanFactory + 부가 기능 |
| 빈 로딩 | 지연(lazy) — 처음 요청 시 생성 | 즉시(eager) — 시작 시 모두 생성 |
| 메시지 국제화 | X | O |
| 이벤트 발행 | X | O (ApplicationEvent) |
| AOP 통합 | X | O |
| 실무 사용 | 거의 안 씀 | **표준** |

> 실무에서 "Spring 컨테이너"라고 하면 거의 항상 **ApplicationContext**를 말함.

## 빈 등록 방법 3가지

### 1. 컴포넌트 스캔 (가장 흔함)

```java
@Component
public class EmailService { }
```

컨테이너가 시작 시 [[@Component]]/`@Service`/`@Repository`/`@Controller`가 붙은 클래스를 탐색해서 빈으로 등록.

### 2. `@Bean` 메서드 (외부 라이브러리)

```java
@Configuration
public class AppConfig {
    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }
}
```

내가 만들지 않은 클래스(라이브러리)를 빈으로 등록할 때 사용.

### 3. XML 설정 (legacy)

```xml
<bean id="emailService" class="com.example.EmailService"/>
```

요즘은 거의 안 씀.

## 컨테이너 동작 흐름

```
[ 애플리케이션 시작 ]

1. ApplicationContext 생성
   ├─ 설정 정보 로딩 (@Configuration 클래스, application.properties 등)

2. 빈 정의 등록 (Bean Definition)
   ├─ @ComponentScan으로 어노테이션 클래스 탐색
   ├─ @Bean 메서드 등록
   └─ "어떤 빈이 있고 어떤 의존성이 필요한지" 메타데이터 수집

3. 빈 인스턴스 생성
   ├─ 의존성 그래프 분석 (위상 정렬)
   ├─ 의존성이 없는 빈부터 순서대로 인스턴스화
   └─ 싱글톤이 기본 (한 번만 생성)

4. 의존성 주입
   ├─ 생성자 주입: 인스턴스화 시점에 동시 처리
   ├─ 필드/세터 주입: 인스턴스 생성 후 처리
   └─ @Autowired로 자동 매칭

5. 빈 후처리 (BeanPostProcessor)
   ├─ AOP 프록시 생성
   ├─ @PostConstruct 호출
   └─ 커스텀 초기화 로직

6. 사용 가능 상태
   └─ 빈 조회·실행
```

## 빈 조회 방법

대부분 자동 주입(`@Autowired`)을 쓰지만, 컨테이너에서 직접 꺼낼 수도 있음:

```java
@SpringBootApplication
public class App implements CommandLineRunner {

    private final ApplicationContext context;

    public App(ApplicationContext context) {
        this.context = context;
    }

    @Override
    public void run(String... args) {
        // 1. 타입으로 조회
        EmailService email = context.getBean(EmailService.class);

        // 2. 이름으로 조회
        EmailService email = (EmailService) context.getBean("emailService");

        // 3. 이름 + 타입
        EmailService email = context.getBean("emailService", EmailService.class);

        // 4. 같은 타입 빈 모두 조회
        Map<String, MailSender> senders = context.getBeansOfType(MailSender.class);
    }
}
```

> 직접 조회는 테스트나 디버깅 외에는 잘 안 씀. **DI를 쓰는 게 IoC 정신에 맞음**.

## 빈 등록 방식의 우선순위

같은 빈 이름·타입이 여러 곳에서 등록되면:

```
@Bean 메서드 > 컴포넌트 스캔
   ↑
  설정 클래스의 @Bean이 우선
```

```java
@Component
public class EmailService { }   // 자동 등록

@Configuration
public class AppConfig {
    @Bean
    public EmailService emailService() {  // 같은 이름의 빈 → 이게 우선
        return new MockEmailService();
    }
}
```

## 컨테이너 종류

| 클래스 | 용도 |
|---|---|
| `AnnotationConfigApplicationContext` | 자바 어노테이션 기반 (가장 흔함) |
| `ClassPathXmlApplicationContext` | XML 기반 (legacy) |
| `AnnotationConfigWebApplicationContext` | 웹 + 어노테이션 |
| `WebApplicationContext` | Spring MVC에서 자동 사용 |

Spring Boot에서는 `SpringApplication.run()`이 알아서 적절한 구현체 선택 — 직접 만들 일 거의 없음.

## 빈 스코프 (간단 소개)

```
기본은 싱글톤 — 컨테이너당 한 개만 생성

@Component
public class UserService { }   // 컨테이너 전체에서 공유

@Component
@Scope("prototype")
public class TempBuffer { }    // 요청할 때마다 새로 생성

기타: request, session, application, websocket (웹 전용)
```

자세한 건 별도 노트에서 다룰 예정.

## 빈 생명주기 (간단 소개)

```
1. 객체 생성 (constructor)
2. 의존성 주입 (@Autowired)
3. 초기화 콜백 (@PostConstruct)
4. 사용
5. 소멸 콜백 (@PreDestroy)
```

자세한 건 별도 노트에서 다룰 예정.

## 핵심 정리

Spring 컨테이너는 **빈의 생성·의존성 주입·생명주기를 관리하는 [[IoC]] 컨테이너**로, 실무에서는 거의 항상 `ApplicationContext` 인터페이스를 사용합니다. 빈 등록은 [[@Component]] 기반 컴포넌트 스캔과 `@Bean` 메서드 두 가지가 주를 이루며, 컨테이너는 시작 시 빈 정의를 수집한 뒤 의존성 그래프를 따라 순서대로 인스턴스화합니다. 개발자는 빈 조회를 직접 하기보다 [[DI]]를 통해 받는 것이 [[IoC]] 원칙에 맞으며, Spring Boot는 `SpringApplication.run()` 한 줄로 적절한 컨테이너를 자동 구성해줍니다.
