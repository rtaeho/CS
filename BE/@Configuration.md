**[[@Bean]] 메서드들을 모아두는 설정 클래스**임을 [[Spring Container|Spring 컨테이너]]에게 알리는 [[어노테이션]]입니다. 단순히 메서드를 모으는 것을 넘어, **빈의 싱글톤을 보장하는 프록시**를 자동으로 만들어줍니다.

## 왜 필요한가?

```
@Bean 메서드를 어디에 둘까?

옵션 1: 일반 클래스
  → 컨테이너가 이 클래스를 모름 → 빈 등록 안 됨

옵션 2: @Component 클래스
  → 등록은 되지만 싱글톤 보장 X (자세한 건 아래)

옵션 3: @Configuration 클래스 O
  → 등록 + 싱글톤 보장 (프록시로 감쌈)
```

## 기본 사용법

```java
@Configuration
public class AppConfig {

    @Bean
    public DataSource dataSource() {
        return new HikariDataSource();
    }

    @Bean
    public JdbcTemplate jdbcTemplate() {
        return new JdbcTemplate(dataSource());
        //                       ↑
        //                여기서 dataSource() 호출
    }

    @Bean
    public TransactionManager transactionManager() {
        return new DataSourceTransactionManager(dataSource());
        //                                       ↑
        //                                  또 호출됨
    }
}
```

```
[ 결과 ]
컨테이너에 빈 3개 등록:
  - dataSource         (1번만 생성)
  - jdbcTemplate       (위의 dataSource를 받음)
  - transactionManager (위의 dataSource를 받음)

dataSource()가 코드상 3번 호출되지만,
실제로 HikariDataSource는 한 번만 생성됨 (싱글톤)
```

## @Configuration의 마법: CGLIB 프록시

`@Configuration`이 붙은 클래스는 **Spring이 런타임에 자식 클래스(프록시)를 만들어서 사용**합니다. 자세한 프록시 메커니즘은 [[Spring Proxy]] 참고.

```
[ 일반 클래스의 경우 ]
new AppConfig().dataSource()    ← 매번 새 인스턴스 생성

[ @Configuration의 경우 ]
프록시.dataSource() 호출 → 첫 호출만 실제로 실행, 이후는 캐시된 빈 반환
```

```java
@Configuration
public class AppConfig {

    @Bean
    public ServiceA serviceA() {
        return new ServiceA(common());   // 첫 호출 → 실제 실행
    }

    @Bean
    public ServiceB serviceB() {
        return new ServiceB(common());   // common()을 또 호출
    }                                     //  → 프록시가 가로채서 캐시된 빈 반환
                                          //  → 같은 Common 인스턴스
    @Bean
    public Common common() {
        return new Common();
    }
}
```

## @Configuration vs @Component (with @Bean)

```java
// 1. @Configuration — 싱글톤 보장 O
@Configuration
public class Config {
    @Bean public A a() { return new A(); }
    @Bean public B b() { return new B(a()); }
}
// a()는 단 한 번 실행 → A 인스턴스 1개

// 2. @Component — 싱글톤 보장 X
@Component
public class Config {
    @Bean public A a() { return new A(); }
    @Bean public B b() { return new B(a()); }
}
// a()가 호출될 때마다 new A() 실행 → A 인스턴스 여러 개!
```

| 항목 | @Configuration | @Component (+ @Bean) |
|---|---|---|
| 빈 등록 | O | O |
| 프록시 생성 | O CGLIB로 감쌈 | X 일반 클래스 |
| `@Bean` 메서드 호출 시 동작 | 캐시된 빈 반환 | 매번 new 실행 |
| 싱글톤 보장 | O | X |

> `@Bean`은 항상 `@Configuration` 클래스에 두는 것이 안전.

## 자주 쓰는 패턴

### 외부 라이브러리 설정 모음

```java
@Configuration
public class HttpConfig {

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplateBuilder()
            .setConnectTimeout(Duration.ofSeconds(3))
            .setReadTimeout(Duration.ofSeconds(5))
            .build();
    }

    @Bean
    public WebClient webClient() {
        return WebClient.builder().baseUrl("https://api.example.com").build();
    }
}
```

### 환경별 분리

```java
@Configuration
@Profile("local")
public class LocalConfig {
    @Bean public DataSource dataSource() { return new H2DataSource(); }
}

@Configuration
@Profile("prod")
public class ProdConfig {
    @Bean public DataSource dataSource() { return new HikariDataSource(); }
}
```

### `@ComponentScan` 함께 사용

```java
@Configuration
@ComponentScan(basePackages = "com.example.app")
public class AppConfig {
    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }
}
```

## `@SpringBootApplication`은 `@Configuration` 포함

```java
@SpringBootApplication   // 내부에 @Configuration + @ComponentScan + @EnableAutoConfiguration
public class App {
    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }
}
```

> 메인 애플리케이션 클래스에 `@Bean`을 직접 둘 수 있는 이유.
> 다만 큰 프로젝트에서는 별도 `@Configuration` 클래스로 분리하는 게 좋음.

## 여러 `@Configuration` 클래스 조합

```java
@Configuration
@Import({DatabaseConfig.class, SecurityConfig.class, CacheConfig.class})
public class AppConfig {
    // ...
}
```

또는 그냥 컴포넌트 스캔 범위 안에 두면 자동으로 모두 로딩됨.

## 함정: final 키워드 금지

```java
// X final 클래스는 CGLIB 프록시 생성 불가 → 싱글톤 보장 깨짐
@Configuration
public final class AppConfig {   // 컴파일은 되지만 경고 / 동작 이상
    @Bean public A a() { ... }
}

// O final 키워드 빼기
@Configuration
public class AppConfig {
    @Bean public A a() { ... }
}
```

CGLIB이 자식 클래스를 생성해야 하기 때문에 부모 클래스가 `final`이면 안 됨.

## proxyBeanMethods = false (Spring Boot 2.2+)

```java
@Configuration(proxyBeanMethods = false)
public class AppConfig {
    @Bean public A a() { return new A(); }
    @Bean public B b() { return new B(a()); }   // 매번 new A() 실행됨!
}
```

```
proxyBeanMethods = true (기본값):  CGLIB 프록시 → 싱글톤 보장
proxyBeanMethods = false:         프록시 없음 → 메모리·시작 시간 ↓
                                    대신 @Bean 메서드끼리 호출 시 주의 필요
```

> 성능 최적화가 필요하고 `@Bean` 메서드끼리 직접 호출하지 않을 때만 사용.

## 핵심 정리

`@Configuration`은 **[[@Bean]] 메서드들을 담는 설정 클래스**임을 알리는 어노테이션으로, [[Spring Container|Spring 컨테이너]]가 [[Spring Proxy|CGLIB 프록시]]로 감싸서 **`@Bean` 메서드 호출 시 캐시된 빈을 반환하도록 보장**합니다. 같은 효과를 [[@Component]]에서는 얻을 수 없으며, `@Bean` 메서드 사이에서 `dataSource()` 같은 호출이 안전하게 싱글톤을 유지하는 핵심이 바로 이 프록시 동작입니다. `final` 키워드를 붙이면 프록시 생성이 불가능해 싱글톤이 깨지므로 주의해야 합니다.
