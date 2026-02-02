Spring에서 클래스를 빈(Bean)으로 등록하는 가장 기본적인 [[어노테이션]]입니다. 컴포넌트 스캔 대상이 되어 자동으로 Spring 컨테이너에 등록됩니다.

## 왜 필요한가?

- 객체를 직접 생성하지 않고 Spring이 관리하게 함
- 의존성 주입(DI)을 받을 수 있음
- 싱글톤으로 관리됨

## 기본 사용법

```java
@Component
public class EmailService {
    public void send(String to, String message) {
        // 이메일 전송 로직
    }
}

// 다른 곳에서 주입받아 사용
@Service
public class UserService {
    private final EmailService emailService;
    
    @Autowired
    public UserService(EmailService emailService) {
        this.emailService = emailService;
    }
}
```

## 컴포넌트 스캔 동작

```java
@SpringBootApplication  // 내부에 @ComponentScan 포함
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

```
애플리케이션 시작
    ↓
@ComponentScan 실행
    ↓
@Component 붙은 클래스 탐색
    ↓
빈으로 등록 (싱글톤)
    ↓
필요한 곳에 주입
```

## 빈 이름 지정

```java
// 기본: 클래스명의 첫 글자를 소문자로
@Component
public class EmailService { }  // 빈 이름: "emailService"

// 직접 지정
@Component("mailService")
public class EmailService { }  // 빈 이름: "mailService"
```

## @Component vs @Bean

|항목|@Component|@Bean|
|---|---|---|
|위치|클래스에 선언|메서드에 선언|
|등록 방식|자동 (컴포넌트 스캔)|수동 (설정 클래스)|
|용도|직접 만든 클래스|외부 라이브러리|

```java
// @Component - 내가 만든 클래스
@Component
public class MyService { }

// @Bean - 외부 라이브러리
@Configuration
public class AppConfig {
    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();  // 외부 라이브러리
    }
}
```

## @Component 파생 어노테이션

```java
@Controller   // = @Component + 웹 계층
@Service      // = @Component + 서비스 계층
@Repository   // = @Component + 데이터 계층 + 예외 변환
```

- 모두 내부에 @Component 포함
- 계층별 역할 명시 + 추가 기능

## 스캔 범위 지정

```java
@Configuration
@ComponentScan(basePackages = "com.example.service")
public class AppConfig { }

// 특정 패키지만 스캔
// 기본은 @SpringBootApplication 위치 기준 하위 패키지 전체
```
