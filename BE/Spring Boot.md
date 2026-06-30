---
title: "Spring Boot"
tags: [Spring, SpringBoot, AutoConfiguration]
status: published
---

Spring Boot는 Spring 기반 애플리케이션을 더 빠르게 만들 수 있도록 자동 설정, 스타터 의존성, 내장 서버, 운영 기능을 제공하는 프레임워크입니다.

## 핵심 특징

- **[[AutoConfiguration]]**: 클래스패스, Bean, 설정 값을 기준으로 필요한 구성을 자동 등록합니다.
- **Starter 의존성**: `spring-boot-starter-web`처럼 자주 함께 쓰는 라이브러리를 묶어서 제공합니다.
- **내장 서버**: [[Tomcat]], Jetty, Undertow 같은 서버를 내장해 실행 가능한 JAR로 배포할 수 있습니다.
- **운영 편의성**: Actuator, 외부 설정, profile, 로깅 기본값 등 운영에 필요한 기능을 제공합니다.

## Spring과의 관계

Spring Boot는 Spring을 대체하는 기술이 아니라, Spring을 더 쉽게 사용할 수 있게 해주는 도구입니다.

| 항목 | Spring | Spring Boot |
|---|---|---|
| 목적 | DI, AOP, MVC 등 핵심 프레임워크 제공 | Spring 애플리케이션 구성과 실행 간소화 |
| 설정 | 직접 Bean, MVC, 서버 설정을 많이 작성 | 조건부 자동 설정을 기본 제공 |
| 서버 | 외부 WAS 배포가 일반적 | 내장 서버로 독립 실행 가능 |
| 의존성 | 필요한 라이브러리를 직접 조합 | starter로 의존성 묶음 제공 |

## 동작 흐름

```text
@SpringBootApplication
        |
        v
@EnableAutoConfiguration
        |
        v
AutoConfiguration 후보 로딩
        |
        v
조건 검사 후 필요한 Bean 등록
```

## 주의사항

- 자동 설정이 편리하지만, 어떤 Bean이 자동 등록되는지 모르면 문제 원인 추적이 어려울 수 있습니다.
- 기본값을 그대로 쓰기보다 운영 환경에서는 timeout, pool size, logging, profile 같은 설정을 명시적으로 점검해야 합니다.
- Spring Boot가 제공하는 추상화 아래에서 실제로는 [[Spring Container]], [[Servlet]], [[Tomcat]] 같은 Spring 생태계 구성요소가 동작합니다.

## 핵심 정리

Spring Boot는 Spring 애플리케이션의 초기 설정과 배포 복잡도를 줄여줍니다.

핵심은 자동 설정, starter 의존성, 내장 서버입니다.

→ [[Spring과 Spring Boot의 차이를 말해주세요]]
