Spring에서 메서드 또는 클래스에 선언하여 해당 범위의 작업을 하나의 트랜잭션으로 묶어주는 어노테이션입니다.

## 기본 동작 원리

```
메서드 시작 → 트랜잭션 시작 → 비즈니스 로직 실행 → 성공 시 커밋 / 예외 시 롤백
```

- 메서드가 정상 완료되면 **자동 커밋**
- **런타임 예외(Unchecked Exception)** 발생 시 자동 롤백
- **체크 예외(Checked Exception)** 발생 시 기본적으로 롤백하지 않음

## 기본 사용 예시

```java
@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private PaymentRepository paymentRepository;

    @Transactional
    public void createOrder(OrderRequest request) {
        Order order = orderRepository.save(new Order(request));   // 1. 주문 저장
        paymentRepository.save(new Payment(order));               // 2. 결제 저장
        // 2에서 예외 발생 시 1도 함께 롤백
    }
}
```

## 주요 속성

|속성|설명|기본값|
|---|---|---|
|**propagation**|트랜잭션 전파 방식|REQUIRED|
|**isolation**|트랜잭션 격리 수준|DB 기본값|
|**readOnly**|읽기 전용 여부 (조회 성능 최적화)|false|
|**rollbackFor**|롤백할 예외 지정|RuntimeException|
|**timeout**|트랜잭션 제한 시간(초)|-1 (무제한)|

```java
@Transactional(readOnly = true)
public List<Order> getOrders() {
    return orderRepository.findAll();  // 조회 전용, 성능 최적화
}

@Transactional(rollbackFor = Exception.class)
public void process() throws Exception {
    // 체크 예외도 롤백 대상에 포함
}
```

## 전파 옵션 (Propagation)

|옵션|설명|
|---|---|
|**REQUIRED**|기존 트랜잭션이 있으면 참여, 없으면 새로 생성 (기본값)|
|**REQUIRES_NEW**|항상 새 트랜잭션 생성, 기존 트랜잭션은 일시 중단|
|**NESTED**|기존 트랜잭션 내에 중첩 트랜잭션(세이브포인트) 생성|
|**MANDATORY**|기존 트랜잭션이 반드시 있어야 함, 없으면 예외|
|**SUPPORTS**|트랜잭션이 있으면 참여, 없으면 트랜잭션 없이 실행|
|**NOT_SUPPORTED**|트랜잭션 없이 실행, 기존 트랜잭션은 일시 중단|

## 동작 원리 (프록시 기반)

```
클라이언트 → Spring AOP 프록시 → 트랜잭션 시작 → 실제 메서드 → 커밋/롤백
```

Spring은 **프록시 객체**를 통해 트랜잭션을 관리하기 때문에, 주의할 점이 있습니다.

## ⚠️ 자주 발생하는 실수

### 1. 내부 호출 시 트랜잭션 미적용

```java
@Service
public class OrderService {

    public void outer() {
        this.inner();  // 프록시를 거치지 않아 @Transactional 미적용!
    }

    @Transactional
    public void inner() {
        // 트랜잭션이 걸리지 않음
    }
}
```

같은 클래스 내부에서 `this`로 호출하면 프록시를 거치지 않으므로 트랜잭션이 동작하지 않습니다. **별도 클래스로 분리**하여 해결합니다.

### 2. private 메서드에 적용

```java
@Transactional
private void process() {  // 프록시가 오버라이드할 수 없어 미적용!
    // ...
}
```

`@Transactional`은 **public 메서드**에만 적용 가능합니다.

### 3. 체크 예외 롤백 누락

```java
@Transactional
public void process() throws IOException {
    // IOException 발생 시 롤백되지 않음!
    // rollbackFor = IOException.class 추가 필요
}
```