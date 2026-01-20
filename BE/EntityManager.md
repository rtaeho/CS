**EntityManager**는 **JPA에서 엔티티(객체)를 관리하고 DB 작업을 수행하는 핵심 인터페이스**입니다.

## 쉽게 말하면

Java 객체와 DB 사이의 **중간 관리자** 역할을 해요.

```
Java 객체 ←→ EntityManager ←→ 데이터베이스
```

## 주요 기능

```java
// 1. 저장
entityManager.persist(user);

// 2. 조회
User user = entityManager.find(User.class, 1L);

// 3. 수정 (변경 감지 - 자동으로 UPDATE)
user.setName("새이름");

// 4. 삭제
entityManager.remove(user);
```

## 영속성 컨텍스트

EntityManager는 내부에 **[[영속성 컨텍스트]](Persistence Context)** 라는 공간을 갖고 있어요.

```
┌─────────────────────────────┐
│      영속성 컨텍스트         │
│  ┌─────┐ ┌─────┐ ┌─────┐   │
│  │User1│ │User2│ │User3│   │  ← 엔티티들이 여기서 관리됨
│  └─────┘ └─────┘ └─────┘   │
└─────────────────────────────┘
            ↕ 동기화
┌─────────────────────────────┐
│        데이터베이스          │
└─────────────────────────────┘
```

## 영속성 컨텍스트의 장점

|기능|설명|
|---|---|
|1차 캐시|같은 엔티티 조회 시 DB 안 가고 캐시에서 반환|
|변경 감지|객체 수정하면 자동으로 UPDATE 쿼리 실행|
|쓰기 지연|여러 쿼리를 모았다가 한번에 실행|
|동일성 보장|같은 ID의 엔티티는 항상 같은 객체|

## 예시 코드

```java
// 영속성 컨텍스트에 저장 (아직 DB에 안 감)
entityManager.persist(user);

// 트랜잭션 커밋할 때 DB에 반영
transaction.commit();
```

## Spring에서는?

Spring Data JPA를 쓰면 EntityManager를 직접 다룰 일이 거의 없어요.

```java
// 직접 EntityManager 사용
entityManager.persist(user);
entityManager.find(User.class, 1L);

// Spring Data JPA 사용 (내부적으로 EntityManager 사용)
userRepository.save(user);
userRepository.findById(1L);
```

## 한줄 요약

EntityManager = **JPA에서 엔티티의 저장, 조회, 수정, 삭제를 담당하는 관리자**