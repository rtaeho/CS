**메서드의 반환값을 빈(Bean)으로 등록**하는 [[어노테이션]]입니다. [[@Component]]가 클래스를 자동 등록하는 것과 달리, **개발자가 직접 만들지 않은 외부 라이브러리 클래스를 빈으로 등록**할 때 주로 사용합니다.

## 왜 필요한가?

```
@Component는 클래스 선언부에 붙여야 함:

@Component
public class EmailService { }   ← 내가 만든 클래스 → OK

@Component
public class ObjectMapper { }   ← 외부 라이브러리 → X 코드 수정 불가
```

```
@Bean은 메서드에 붙임 → 외부 객체를 감싸서 등록 가능:

@Configuration
public class AppConfig {
    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();   ← 내가 만든 메서드의 반환값을 빈으로
    }
}
```

## 기본 사용법

```java
@Configuration
public class AppConfig {

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

    @Bean
    public ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.registerModule(new JavaTimeModule());
        return mapper;
    }
}
```

```
[ 등록 결과 ]
컨테이너에 두 개의 빈 등록:
  - "restTemplate"  → RestTemplate 인스턴스
  - "objectMapper"  → ObjectMapper 인스턴스 (커스텀 설정 포함)
```

> 메서드 이름이 곧 **빈 이름**이 됨.

## 빈 이름 지정

```java
@Bean
public RestTemplate restTemplate() { ... }
// 빈 이름: "restTemplate"

@Bean(name = "myRestTemplate")
public RestTemplate restTemplate() { ... }
// 빈 이름: "myRestTemplate"

@Bean(name = {"primary", "secondary"})
public RestTemplate restTemplate() { ... }
// 빈 이름: "primary"와 "secondary" (둘 다 같은 빈 가리킴)
```

## 다른 빈 주입받기

`@Bean` 메서드의 **매개변수로 다른 빈을 받음**:

```java
@Configuration
public class AppConfig {

    @Bean
    public DataSource dataSource() {
        return new HikariDataSource();
    }

    @Bean
    public JdbcTemplate jdbcTemplate(DataSource dataSource) {
        //                              ↑ 위에서 등록한 dataSource 빈 자동 주입
        return new JdbcTemplate(dataSource);
    }
}
```

```
[ 동작 ]
1. dataSource() 호출 → DataSource 빈 등록
2. jdbcTemplate(DataSource) 호출
   → 매개변수 DataSource 타입 빈을 컨테이너에서 찾아서 주입
   → JdbcTemplate 생성 → 빈 등록
```

## @Component vs @Bean

| 항목 | @Component | @Bean |
|---|---|---|
| 위치 | 클래스 선언부 | 메서드 |
| 등록 방식 | 자동 (컴포넌트 스캔) | 수동 (개발자가 메서드 작성) |
| 대상 | **내가 만든 클래스** | **외부 라이브러리 / 복잡한 생성 로직** |
| 빈 이름 | 클래스명의 첫 글자 소문자 | 메서드 이름 |
| 컨테이너 클래스 위치 | 어디든 (스캔 범위 내) | `@Configuration` 클래스 안 |

```java
// @Component — 내가 만든 클래스
@Component
public class UserService { }

// @Bean — 외부 라이브러리
@Configuration
public class AppConfig {
    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }
}
```

## 자주 쓰는 패턴

### 외부 라이브러리 등록

```java
@Bean
public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory cf) {
    RedisTemplate<String, Object> template = new RedisTemplate<>();
    template.setConnectionFactory(cf);
    template.setKeySerializer(new StringRedisSerializer());
    template.setValueSerializer(new GenericJackson2JsonRedisSerializer());
    return template;
}
```

### 조건부 빈 등록

```java
@Bean
@ConditionalOnProperty(name = "app.email.enabled", havingValue = "true")
public EmailSender emailSender() {
    return new SmtpEmailSender();
}
```

### 환경별 다른 구현

```java
@Bean
@Profile("local")
public DataSource localDataSource() {
    return new H2DataSource();
}

@Bean
@Profile("prod")
public DataSource prodDataSource() {
    return new HikariDataSource();
}
```

### 인터페이스 구현체 선택

```java
@Bean
public PaymentGateway paymentGateway() {
    if (isProduction()) {
        return new TossPaymentGateway();
    }
    return new MockPaymentGateway();
}
```

## 초기화 / 소멸 메서드

```java
@Bean(initMethod = "init", destroyMethod = "shutdown")
public CustomResource customResource() {
    return new CustomResource();
}
```

```
[ 동작 ]
1. customResource() 실행 → 인스턴스 생성
2. init() 호출
3. 사용
4. 컨테이너 종료 시 shutdown() 호출
```

> 일반적으로는 `@PostConstruct` / `@PreDestroy`를 더 많이 씀.

## 스코프 지정

```java
@Bean
@Scope("singleton")    // 기본값
public Cache cache() { ... }

@Bean
@Scope("prototype")    // 매번 새로 생성
public RequestContext requestContext() { ... }
```

## 어디에 선언해야 하나?

| 위치 | 동작 | 권장 |
|---|---|---|
| `@Configuration` 클래스 | 정상 — 싱글톤 보장 | O |
| `@Component` 클래스 | 동작은 하지만 싱글톤 보장 안 됨 | X |
| 일반 클래스 | 컨테이너에 등록 안 됨 (무시) | X |

자세한 차이는 [[@Configuration]] 참고.

## 주의: 메서드 호출 vs 빈 조회

```java
@Configuration
public class AppConfig {

    @Bean
    public DataSource dataSource() {
        return new HikariDataSource();
    }

    @Bean
    public JdbcTemplate jdbcTemplate() {
        return new JdbcTemplate(dataSource());   // ← 메서드 직접 호출
    }
}
```

```
[ @Configuration이라면 ]
Spring이 프록시로 감싸서 dataSource() 호출 시
이미 만들어진 빈을 반환 → 싱글톤 유지

[ @Component였다면 ]
dataSource()가 일반 메서드 호출처럼 동작
→ 매번 new HikariDataSource() 실행 → 빈이 여러 개 생성됨!
```

## 핵심 정리

`@Bean`은 **메서드의 반환값을 빈으로 등록**하는 어노테이션으로, 직접 만들지 않은 **외부 라이브러리** 또는 **복잡한 생성 로직**이 필요한 객체를 빈으로 등록할 때 사용합니다. 메서드 이름이 빈 이름이 되며, 매개변수로 다른 빈을 자동 주입받을 수 있습니다. **반드시 [[@Configuration]] 클래스 안에 선언**해야 싱글톤이 보장되며, [[@Component]]가 자동 등록인 반면 `@Bean`은 개발자가 메서드로 명시적 등록한다는 차이가 있습니다.
