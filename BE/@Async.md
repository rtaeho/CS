Spring에서 메서드를 비동기적으로 실행하여 호출자가 해당 메서드의 완료를 기다리지 않고 다음 작업을 계속 수행할 수 있게 해주는 어노테이션입니다.

## 동기 vs 비동기 비교

```
[동기 실행]
주문 처리 → 이메일 발송(3초 대기) → 응답 반환    총 소요: 4초

[비동기 실행 (@Async)]
주문 처리 → 이메일 발송(별도 스레드) → 응답 즉시 반환    총 소요: 1초
                 ↓
            백그라운드에서 3초 후 완료
```

## 기본 설정

```java
@Configuration
@EnableAsync  // 비동기 기능 활성화 (필수)
public class AsyncConfig {
}
```

## 기본 사용 예시

```java
@Service
public class NotificationService {

    @Async
    public void sendEmail(String to, String content) {
        // 별도 스레드에서 실행, 호출자는 기다리지 않음
        emailClient.send(to, content);
        log.info("이메일 발송 완료");
    }
}

@Service
public class OrderService {

    @Autowired
    private NotificationService notificationService;

    public void createOrder(OrderRequest request) {
        orderRepository.save(new Order(request));
        notificationService.sendEmail(request.getEmail(), "주문 완료");  // 비동기 실행
        // 이메일 발송 완료를 기다리지 않고 즉시 다음 줄 실행
    }
}
```

## 반환 타입

|반환 타입|설명|
|---|---|
|**void**|결과를 받을 필요 없을 때 (fire-and-forget)|
|**Future<T>**|비동기 결과를 나중에 받을 수 있음|
|**CompletableFuture<T>**|Future보다 유연한 체이닝, 조합 가능 (권장)|

```java
@Service
public class AnalyticsService {

    // 1. 결과가 필요 없는 경우
    @Async
    public void logEvent(String event) {
        analyticsClient.log(event);
    }

    // 2. 결과를 나중에 받고 싶은 경우
    @Async
    public CompletableFuture<Report> generateReport(Long userId) {
        Report report = reportGenerator.create(userId);
        return CompletableFuture.completedFuture(report);
    }
}

// 호출 측
@Service
public class DashboardService {

    @Autowired
    private AnalyticsService analyticsService;

    public DashboardData getDashboard(Long userId) throws Exception {
        CompletableFuture<Report> reportFuture = analyticsService.generateReport(userId);

        // 다른 작업 수행 가능
        UserInfo userInfo = userService.getUser(userId);

        // 필요한 시점에 결과 조회
        Report report = reportFuture.get(5, TimeUnit.SECONDS);  // 최대 5초 대기

        return new DashboardData(userInfo, report);
    }
}
```

## 스레드 풀 설정

기본적으로 Spring은 `SimpleAsyncTaskExecutor`를 사용하는데, 매 호출마다 새 스레드를 생성하므로 **커스텀 스레드 풀 설정이 권장**됩니다.

```java
@Configuration
@EnableAsync
public class AsyncConfig {

    @Bean(name = "taskExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);          // 기본 스레드 수
        executor.setMaxPoolSize(10);          // 최대 스레드 수
        executor.setQueueCapacity(50);        // 대기 큐 크기
        executor.setThreadNamePrefix("async-");
        executor.setRejectedExecutionHandler(new CallerRunsPolicy());  // 큐 초과 시 호출 스레드에서 실행
        executor.initialize();
        return executor;
    }
}

// 특정 스레드 풀 지정
@Async("taskExecutor")
public void sendEmail(String to, String content) {
    // taskExecutor 스레드 풀에서 실행
}
```

## 예외 처리

비동기 메서드에서 발생한 예외는 호출자에게 전파되지 않으므로 별도 처리가 필요합니다.

```java
// 1. void 반환 시: AsyncUncaughtExceptionHandler 사용
@Configuration
@EnableAsync
public class AsyncConfig implements AsyncConfigurer {

    @Override
    public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
        return (ex, method, params) -> {
            log.error("비동기 예외 발생 - 메서드: {}, 에러: {}", method.getName(), ex.getMessage());
        };
    }
}

// 2. CompletableFuture 반환 시: exceptionally로 처리
@Async
public CompletableFuture<String> process() {
    return CompletableFuture.supplyAsync(() -> {
        // 비즈니스 로직
        return "결과";
    }).exceptionally(ex -> {
        log.error("처리 실패: {}", ex.getMessage());
        return "기본값";
    });
}
```

## ⚠️ 주의사항

|주의점|설명|
|---|---|
|**내부 호출 미적용**|`@Transactional`과 동일하게 같은 클래스 내부 호출 시 비동기 동작하지 않음|
|**프록시 기반**|public 메서드에만 적용 가능|
|**예외 전파 불가**|void 반환 시 호출자가 예외를 알 수 없으므로 별도 핸들러 필요|
|**트랜잭션 분리**|비동기 메서드는 별도 스레드이므로 호출자의 트랜잭션과 독립적으로 동작|
|**스레드 풀 미설정**|기본 설정은 매번 새 스레드를 생성하므로 반드시 커스텀 스레드 풀 설정|
