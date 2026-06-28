---
title: "AutoConfiguration"
tags: [Spring, SpringBoot, 설정]
status: published
---

Spring Boot가 클래스패스, 설정 값, 빈 존재 여부를 조건으로 판단해 필요한 Bean 설정을 자동으로 등록하는 기능입니다.

## 핵심 특징

- **자동 설정**: 개발자가 반복적으로 작성하던 인프라 Bean 설정을 Spring Boot가 대신 구성
- **조건 기반**: `@ConditionalOnClass`, `@ConditionalOnMissingBean`, `@ConditionalOnProperty` 등으로 적용 여부를 판단
- **진입점**: `@SpringBootApplication` 내부의 `@EnableAutoConfiguration`
- **확장 가능**: 라이브러리는 auto-configuration 클래스를 제공해 Spring Boot 애플리케이션에 자연스럽게 통합 가능

## 동작 흐름

```text
@SpringBootApplication
  |
  v
@EnableAutoConfiguration
  |
  v
AutoConfigurationImportSelector
  |
  v
Auto-configuration 후보 로딩
  |
  v
조건 필터링
  |
  v
Bean 등록
```

`@EnableAutoConfiguration`은 `@Import(AutoConfigurationImportSelector.class)`를 통해 자동 구성 후보를 가져옵니다. 이후 후보 목록에서 중복, 제외 설정, 조건 불일치 항목을 제거한 뒤 적용 가능한 설정만 등록합니다.

## 주요 조건 애너테이션

| 조건 | 의미 |
|---|---|
| `@ConditionalOnClass` | 특정 클래스가 클래스패스에 있을 때 |
| `@ConditionalOnMissingBean` | 같은 타입의 Bean이 없을 때 |
| `@ConditionalOnProperty` | 특정 설정 값이 있을 때 |
| `@ConditionalOnWebApplication` | 웹 애플리케이션일 때 |

## 왜 필요한가

예를 들어 `spring-boot-starter-web`을 추가하면 Spring MVC, Jackson, 내장 [[Tomcat]] 관련 설정이 자동으로 잡힙니다. 개발자는 공통 설정을 매번 직접 등록하지 않고, 필요한 경우에만 명시적으로 커스터마이징하면 됩니다.

## 주의사항

- 자동 구성은 편리하지만 어떤 Bean이 등록되는지 모르면 문제 원인을 찾기 어려움
- 직접 등록한 Bean이 `@ConditionalOnMissingBean` 조건을 통해 자동 구성보다 우선할 수 있음
- `spring.autoconfigure.exclude`나 `exclude` 속성으로 특정 자동 구성을 제외할 수 있음

## 핵심 정리

AutoConfiguration은 Spring Boot가 조건에 맞는 설정을 자동으로 적용하는 메커니즘입니다.

핵심은 `AutoConfigurationImportSelector`가 후보 설정을 가져오고,
조건을 통과한 설정만 Spring Bean으로 등록한다는 점입니다.

→ [[AutoConfiguration 동작 원리를 설명해주세요]]
