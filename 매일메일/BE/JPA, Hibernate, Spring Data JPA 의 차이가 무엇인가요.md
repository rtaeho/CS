---
title: "JPA, Hibernate, Spring Data JPA 의 차이가 무엇인가요"
tags: [매일메일, Backend]
status: published
---

[[JPA]], [[Hibernate]], [[Spring Data JPA]]는 모두 Java에서 데이터베이스를 다룰 때 함께 언급되지만, 역할이 서로 다릅니다.

## JPA

JPA는 자바 애플리케이션에서 관계형 데이터베이스를 객체로 다루기 위한 표준 명세입니다. 인터페이스와 규약을 정의할 뿐, 실제 구현체를 직접 제공하지 않습니다.

## Hibernate

Hibernate는 JPA 명세를 구현한 대표적인 ORM 프레임워크입니다. JPA가 정의한 `EntityManager` 같은 인터페이스를 실제로 동작하게 만드는 구현체입니다. EclipseLink, DataNucleus 같은 다른 구현체로 대체할 수도 있습니다.

## Spring Data JPA

Spring Data JPA는 JPA를 더 편하게 사용하도록 도와주는 Spring Data 모듈입니다. `Repository` 인터페이스를 제공하고, 메서드 이름 기반 쿼리 생성, 기본 CRUD, 페이징, 정렬 등을 지원합니다.

## 관계

```text
Spring Data JPA
        |
        v
JPA 표준 인터페이스
        |
        v
Hibernate 같은 구현체
        |
        v
JDBC / Database
```

## 핵심 차이

| 항목 | 역할 |
|---|---|
| JPA | ORM 표준 명세 |
| Hibernate | JPA 명세 구현체 |
| Spring Data JPA | JPA 사용을 쉽게 해주는 Repository 추상화 |

## 정리

JPA는 표준이고, Hibernate는 그 표준을 구현한 구현체이며, Spring Data JPA는 JPA를 더 편하게 사용하게 해주는 추상화입니다. Spring Data JPA의 기본 Repository 구현체도 내부적으로는 [[EntityManager]]를 사용합니다.
