---
title: "Spring Data JPA"
tags: [Spring, JPA, Repository]
status: published
---

Spring Data JPA는 JPA 기반 데이터 접근 계층을 더 쉽게 만들 수 있도록 Repository 추상화와 쿼리 생성 기능을 제공하는 Spring Data 모듈입니다.

## 핵심 특징

- `JpaRepository` 같은 인터페이스를 상속하면 기본 CRUD 메서드를 사용할 수 있습니다.
- 메서드 이름을 분석해 쿼리를 자동 생성할 수 있습니다.
- `@Query`로 JPQL이나 Native Query를 직접 작성할 수 있습니다.
- 페이징, 정렬, Auditing, Specification, Querydsl 연동을 지원합니다.

## JPA와의 관계

Spring Data JPA는 JPA 구현체가 아닙니다. 내부적으로 [[JPA]]와 [[EntityManager]]를 사용해 Repository 구현체를 만들어주는 추상화 계층입니다.

```text
Repository 인터페이스
        |
        v
Spring Data JPA
        |
        v
JPA / EntityManager
        |
        v
Hibernate 같은 JPA 구현체
```

## 주의사항

- 자동 생성 쿼리가 항상 최적의 SQL을 만드는 것은 아닙니다.
- 복잡한 조회는 fetch join, Querydsl, 명시적 `@Query` 등을 고려해야 합니다.
- Repository 추상화가 편리해도 [[영속성 컨텍스트]]와 트랜잭션 경계를 이해해야 합니다.

## 핵심 정리

Spring Data JPA는 JPA 사용을 편하게 해주는 Repository 추상화입니다.

JPA 자체나 Hibernate 구현체와 같은 층이 아니라, 그 위에서 반복적인 데이터 접근 코드를 줄여주는 도구입니다.

→ [[JPA를 사용하는 이유를 설명해주세요]]
