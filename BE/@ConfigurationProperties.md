---
title: "@ConfigurationProperties"
tags: [Spring, SpringBoot, 설정]
status: published
---

`application.yaml`(또는 `.properties`)의 특정 프리픽스 아래 값들을 한 클래스의 필드에 일괄 바인딩하는 Spring Boot 어노테이션입니다.

## 핵심 특징

- `@Value`와 달리 여러 설정 값을 **클래스 단위로 묶어서** 관리
- [[RelaxedBinding]] 적용: `my-property`, `MY_PROPERTY`, `myProperty` 모두 같은 필드에 매핑
- `@Validated`와 조합하여 설정값 유효성 검증 가능
- [[@Component]] 또는 `@EnableConfigurationProperties`로 빈 등록 필요

## 사용 예시

```yaml
# application.yaml
mail:
  host: smtp.example.com
  port: 587
  username: user@example.com
```

```java
@ConfigurationProperties(prefix = "mail")
@Component
public class MailProperties {
    private String host;
    private int port;
    private String username;
    // getter/setter
}
```

## @Value vs @ConfigurationProperties

| | `@Value` | `@ConfigurationProperties` |
|---|---|---|
| 바인딩 대상 | 단일 값 | 프리픽스 단위 클래스 전체 |
| [[RelaxedBinding]] | X | O |
| 유효성 검증 (`@Validated`) | 어려움 | O |
| 타입 안전성 | X | O |

## 핵심 정리

- 설정 값이 여러 개 묶이는 경우 `@Value`보다 `@ConfigurationProperties`가 유지보수에 유리
- [[RelaxedBinding]]으로 환경 변수(`MY_MAIL_HOST`)나 YAML(`my-mail.host`) 표기 모두 자동 처리

→ [[@Component]] | [[RelaxedBinding]]
