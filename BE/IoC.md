---
title: "IoC"
tags: [Spring, DI]
status: published
---

**객체의 생성·생명주기·의존성 관리를 개발자가 아닌 외부 컨테이너가 책임지도록 뒤집는 설계 원칙**입니다 (Inversion of Control). [[DI]]보다 큰 개념으로, DI는 IoC를 구현하는 방법 중 하나입니다.

## 왜 필요한가?

```
[ 전통적인 제어 흐름 ]
public class UserService {
    private EmailService emailService = new EmailService();
                                          ↑
                                  내가(코드 작성자가)
                                  객체를 만든다
}
```

```
이 방식의 문제:
- 어떤 EmailService를 쓸지 결정 권한 = UserService에 있음
- 다른 메일 서비스로 교체하려면 UserService 코드 변경
- 객체 생성 시점·횟수도 UserService가 통제

→ 모든 책임이 한 클래스에 몰림
```

```
[ IoC가 적용된 흐름 ]
public class UserService {
    private final EmailService emailService;

    public UserService(EmailService emailService) {
        this.emailService = emailService;     ← 외부에서 받은 걸 사용
    }
}
```

```
권한 이동:
- "어떤 EmailService를 쓸지" 결정 = 외부(컨테이너/설정)
- "언제 만들지" 결정 = 외부
- "몇 개를 만들지" 결정 = 외부

→ 제어권이 개발자(코드)에서 외부로 "역전"됨
```

## 헐리우드 원칙

```
"Don't call us, we'll call you"
"우리한테 전화하지 마, 우리가 너한테 전화할게"

→ 객체가 의존성을 능동적으로 가져오는(call) 게 아니라
   컨테이너가 객체에게 의존성을 던져주는(callback) 형태
```

```
[ 제어 흐름 비교 ]

전통:
  내 코드 → "필요해" → new EmailService() 호출 → 사용

IoC:
  컨테이너 → "여기 있어" → 내 코드에 의존성 전달 → 내 코드 사용
```

## IoC를 구현하는 방법

| 방법 | 설명 |
|---|---|
| **[[DI]] (의존성 주입)** | 외부에서 의존성을 생성자/필드/세터로 주입 — 가장 흔함 |
| **Service Locator** | 중앙 레지스트리에서 의존성을 조회 (안티패턴 취급) |
| **템플릿 메서드** | 추상 클래스가 흐름을 제어, 하위가 일부 단계만 구현 |
| **이벤트 기반** | 이벤트 디스패처가 콜백 호출 시점 결정 |

```java
// Service Locator 예시 (참고용 — 안티패턴)
public class UserService {
    private EmailService email = ServiceLocator.get(EmailService.class);
    //                              ↑
    //                       객체가 능동적으로 가져옴 — IoC지만 DI는 아님
}

// DI 방식 (권장)
public class UserService {
    private final EmailService email;
    public UserService(EmailService email) {
        this.email = email;        // 수동적으로 받음
    }
}
```

> Service Locator는 IoC지만 의존성이 코드에 숨어서 테스트가 어려움. DI가 더 명시적.

## Spring의 IoC 컨테이너

```
Spring = 자바 진영의 대표적인 IoC 컨테이너 프레임워크

기능:
1. 빈(Bean)의 생성
2. 의존성 주입
3. 생명주기 관리 (초기화, 소멸)
4. 싱글톤 등 스코프 관리
```

```
[ Spring이 IoC를 실현하는 흐름 ]

1. @Component 등이 붙은 클래스 스캔
2. 컨테이너가 객체 생성 (개발자 코드는 new 안 함)
3. 의존성 분석 → 자동 주입
4. 빈으로 등록 → 필요할 때 꺼내 씀
5. 종료 시 정리 (@PreDestroy 호출 등)

개발자는 "무엇이 필요한지"만 선언, "어떻게 얻을지"는 컨테이너 책임
```

## IoC와 DI의 관계

```
        IoC (큰 개념)
         └─ "제어권을 외부로 넘긴다"
            │
            ├─ DI (구체 구현)
            │   └─ "의존성을 주입받는다"
            │
            ├─ Service Locator
            │   └─ "레지스트리에서 조회한다"
            │
            └─ 다른 방법들...
```

|항목|IoC|DI|
|---|---|---|
|범위|넓음 (원칙)|좁음 (패턴)|
|초점|"누가 통제하나"|"어떻게 의존성을 주입하나"|
|예시|Spring 전체 철학|`@Autowired`, 생성자 주입|

> "스프링은 IoC 컨테이너이며, 그 핵심 메커니즘으로 DI를 사용한다"가 정확한 표현.

## IoC가 만들어내는 효과

```
[ 결합도 감소 ]
구체 구현이 아니라 인터페이스에 의존
→ 구현체 교체가 자유로움

[ 테스트 용이 ]
의존성을 외부에서 주입할 수 있으니 Mock 객체 주입 가능

[ 횡단 관심사 분리 ]
객체 생성, 트랜잭션, 로깅 등을 컨테이너가 처리
→ 비즈니스 로직만 코드에 남음 ([[Spring AOP]]와 결합)

[ 단일 책임 ]
객체 생성 책임을 떠나 본연의 역할에만 집중 ([[SOLID]] SRP)
```

## 자주 하는 오해

```
X "IoC = DI"
→ DI는 IoC의 구현 방식 중 하나일 뿐

X "Spring 안 쓰면 IoC 불가능"
→ IoC는 설계 원칙. 직접 구현해도 됨 (수동 DI도 IoC)

X "IoC를 쓰면 무조건 좋다"
→ 작은 프로젝트에서는 컨테이너 학습 비용이 더 클 수도
```

## 핵심 정리

IoC는 **객체의 생성·생명주기 통제권을 개발자에서 외부 컨테이너로 넘기는 설계 원칙**으로, "Don't call us, we'll call you"라는 헐리우드 원칙으로 표현됩니다. 가장 흔한 구현 방식이 [[DI]]이며, Spring은 IoC 컨테이너로서 빈 생성부터 의존성 주입, 생명주기 관리까지 자동화합니다. IoC를 통해 결합도가 낮아지고 테스트가 쉬워지며, [[SOLID]] 원칙(특히 DIP)을 자연스럽게 따르는 구조가 됩니다.
