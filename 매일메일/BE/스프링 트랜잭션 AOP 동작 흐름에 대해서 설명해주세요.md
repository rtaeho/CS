---
title: "스프링 트랜잭션 AOP 동작 흐름에 대해서 설명해주세요"
tags: [매일메일, Backend]
status: published
---

`@Transactional`을 사용한 선언적 트랜잭션 관리는 [[트랜잭션 AOP]]를 통해 동작합니다. 주요 요소는 트랜잭션 AOP 프록시, 트랜잭션 매니저, 트랜잭션 동기화 매니저입니다.

## 전체 흐름

클라이언트 코드가 `@Transactional`이 적용된 Bean을 호출하면 실제 객체가 아니라 트랜잭션 AOP 프록시가 먼저 요청을 받습니다. 프록시는 트랜잭션 매니저를 통해 트랜잭션을 시작하고 실제 비즈니스 메서드를 호출합니다.

```text
Client
  -> Transaction AOP Proxy
  -> PlatformTransactionManager
  -> Connection 획득 및 트랜잭션 시작
  -> TransactionSynchronizationManager에 리소스 보관
  -> Target Method 실행
  -> commit 또는 rollback
  -> 리소스 정리
```

## 트랜잭션 매니저

Spring은 트랜잭션 기술을 추상화하기 위해 `PlatformTransactionManager`를 제공합니다. JDBC를 사용하면 `DataSourceTransactionManager`, JPA를 사용하면 `JpaTransactionManager`를 사용할 수 있습니다. 개발자는 세부 구현보다 공통 트랜잭션 추상화에 의존할 수 있습니다.

## 트랜잭션 동기화 매니저

트랜잭션이 시작되면 커넥션이나 EntityManager 같은 리소스가 현재 스레드에 바인딩됩니다. 이를 관리하는 것이 `TransactionSynchronizationManager`입니다. 덕분에 서비스 로직이 여러 Repository를 호출해도 같은 트랜잭션 리소스를 사용할 수 있습니다.

## 주의사항

Spring의 선언적 트랜잭션은 [[Spring AOP]] 프록시 기반입니다. 따라서 같은 클래스 내부에서 `this`로 호출하면 프록시를 거치지 않아 트랜잭션이 적용되지 않을 수 있습니다. private 메서드에 `@Transactional`을 붙여도 일반적인 프록시 방식에서는 기대대로 동작하지 않습니다.

## 정리

스프링 트랜잭션 AOP는 프록시가 메서드 호출을 감싸고, 트랜잭션 매니저가 실제 트랜잭션을 시작/종료하며, 트랜잭션 동기화 매니저가 같은 트랜잭션 리소스를 여러 코드에서 공유하게 해주는 구조입니다.

## 추가 학습 자료

- [10분 테코톡 - @Transactional](https://youtu.be/taAp_u83MwA)
- [Spring AOP와 @Transactional의 동작 원리](https://velog.io/@ann0905/AOP%EC%99%80-Transactional%EC%9D%98-%EB%8F%99%EC%9E%91-%EC%9B%90%EB%A6%AC)
- [테코블 - AOP 입문자를 위한 개념 이해하기](https://tecoble.techcourse.co.kr/post/2021-06-25-aop-transaction/)
