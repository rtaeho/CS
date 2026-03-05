객체지향 설계에서 **유지보수성과 확장성이 높은 코드를 작성하기 위한 5가지 설계 원칙**입니다.

## SOLID 한눈에 보기

|원칙|이름|핵심 한 줄|
|---|---|---|
|**S**|단일 책임 원칙 (SRP)|클래스는 하나의 책임만 가져야 한다|
|**O**|개방-폐쇄 원칙 (OCP)|확장에는 열려있고, 수정에는 닫혀있어야 한다|
|**L**|리스코프 치환 원칙 (LSP)|자식 클래스는 부모 클래스를 대체할 수 있어야 한다|
|**I**|인터페이스 분리 원칙 (ISP)|사용하지 않는 인터페이스에 의존하면 안 된다|
|**D**|의존성 역전 원칙 (DIP)|추상화에 의존해야 한다, 구체화에 의존하면 안 된다|

## S - 단일 책임 원칙 (SRP)

```java
// ❌ 하나의 클래스가 여러 책임
class User {
    public void login() { ... }       // 인증 책임
    public void saveToDb() { ... }    // DB 책임
    public void sendEmail() { ... }   // 이메일 책임
}

// ✅ 책임별로 클래스 분리
class AuthService   { public void login() { ... } }
class UserRepository { public void save() { ... } }
class EmailService  { public void send() { ... } }
```

## O - 개방-폐쇄 원칙 (OCP)

```java
// ❌ 새 결제 수단 추가 시 기존 코드 수정 필요
class PaymentService {
    public void pay(String type) {
        if (type.equals("card")) { ... }
        else if (type.equals("kakao")) { ... }  // 추가할 때마다 수정
    }
}

// ✅ 인터페이스로 확장에만 열기
interface PaymentStrategy {
    void pay();
}
class CardPayment  implements PaymentStrategy { public void pay() { ... } }
class KakaoPayment implements PaymentStrategy { public void pay() { ... } }

class PaymentService {
    public void pay(PaymentStrategy strategy) {
        strategy.pay();  // 기존 코드 수정 없이 새 결제 수단 추가 가능
    }
}
```

## L - 리스코프 치환 원칙 (LSP)

```java
// ❌ 자식이 부모를 대체하지 못하는 경우
class Rectangle {
    public void setWidth(int w)  { this.width = w; }
    public void setHeight(int h) { this.height = h; }
}
class Square extends Rectangle {
    @Override
    public void setWidth(int w) {
        this.width = w;
        this.height = w;  // 정사각형이라 높이도 같이 변경 → 부모 동작 위반 ❌
    }
}

// ✅ 공통 인터페이스로 분리
interface Shape { int area(); }
class Rectangle implements Shape { ... }
class Square    implements Shape { ... }
```

## I - 인터페이스 분리 원칙 (ISP)

```java
// ❌ 너무 많은 기능을 가진 인터페이스
interface Worker {
    void work();
    void eat();   // 로봇은 eat()이 필요 없음
}
class Robot implements Worker {
    public void work() { ... }
    public void eat()  { }  // 억지로 구현 ❌
}

// ✅ 인터페이스 분리
interface Workable { void work(); }
interface Eatable  { void eat(); }

class Human implements Workable, Eatable { ... }
class Robot implements Workable { ... }  // 필요한 것만 구현
```

## D - 의존성 역전 원칙 (DIP)

```java
// ❌ 구체 클래스에 직접 의존
class OrderService {
    private MySQLRepository repo = new MySQLRepository();  // 구체 클래스에 의존
}

// ✅ 추상화(인터페이스)에 의존
class OrderService {
    private final OrderRepository repo;  // 인터페이스에 의존

    public OrderService(OrderRepository repo) {  // 외부에서 주입 (DI)
        this.repo = repo;
    }
}

// MySQL → MongoDB로 바꿔도 OrderService 코드 변경 없음
class MySQLRepository  implements OrderRepository { ... }
class MongoRepository  implements OrderRepository { ... }
```

## 왜 중요한가?

```
SOLID 미적용          SOLID 적용
─────────────         ─────────────
기능 추가 → 기존 코드 수정   기능 추가 → 새 코드만 추가
테스트 어려움               단위 테스트 용이
변경 시 사이드이펙트 큼      변경 영향 범위 최소화
```

> SOLID는 규칙이 아닌 **"지향점"** 입니다. 무조건 적용하면 오히려 과설계가 될 수 있으므로, 변경 가능성이 높은 부분에 선택적으로 적용하는 것이 핵심입니다.