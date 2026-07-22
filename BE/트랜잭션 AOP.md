---
title: "트랜잭션 AOP"
tags: [Spring, AOP, 트랜잭션]
status: published
---

트랜잭션 AOP는 Spring이 프록시를 통해 비즈니스 메서드 호출 전후에 트랜잭션 시작, 커밋, 롤백을 자동으로 적용하는 방식입니다.

## 등장 요소

- **트랜잭션 AOP 프록시**: 대상 객체 앞에서 트랜잭션 부가 기능을 수행합니다.
- **PlatformTransactionManager**: JDBC, JPA 등 기술별 트랜잭션을 추상화합니다.
- **TransactionSynchronizationManager**: 현재 스레드에 트랜잭션 리소스와 동기화 정보를 보관합니다.
- **DataSource/EntityManager**: 실제 DB 연결이나 영속성 컨텍스트를 사용합니다.

## 동작 흐름

```text
클라이언트
  -> 트랜잭션 AOP 프록시
  -> TransactionManager.getTransaction()
  -> 커넥션 획득 및 트랜잭션 시작
  -> TransactionSynchronizationManager에 리소스 바인딩
  -> 실제 비즈니스 메서드 실행
  -> 성공 시 commit / 예외 시 rollback
  -> 리소스 정리
```

## 왜 동기화 매니저가 필요한가

서비스 로직은 여러 Repository나 DAO를 호출할 수 있습니다. 이때 같은 트랜잭션을 유지하려면 같은 커넥션이나 EntityManager를 공유해야 합니다. TransactionSynchronizationManager는 현재 스레드에 트랜잭션 리소스를 보관해 하위 데이터 접근 코드가 같은 리소스를 사용할 수 있게 합니다.

## 주의사항

- [[Spring AOP]]는 기본적으로 프록시 기반이므로 같은 클래스 내부 호출에서는 트랜잭션이 적용되지 않을 수 있습니다.
- private 메서드나 final 메서드는 프록시가 개입하기 어렵습니다.
- 롤백 기본 정책은 RuntimeException과 Error이며, 체크 예외는 별도 설정이 필요합니다.

## 핵심 정리

트랜잭션 AOP는 `@Transactional` 메서드 호출을 프록시가 감싸고, TransactionManager와 동기화 매니저를 통해 트랜잭션 리소스를 관리하는 구조입니다.

→ [[스프링 트랜잭션 AOP 동작 흐름에 대해서 설명해주세요]]
