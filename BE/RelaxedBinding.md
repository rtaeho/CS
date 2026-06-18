---
title: "RelaxedBinding"
tags: [Spring, SpringBoot, 설정]
status: published
---

Spring Boot에서 [[@ConfigurationProperties]]를 사용할 때 프로퍼티 이름의 표기법이 달라도 유연하게 바인딩해주는 규칙입니다.

## 핵심 특징

- 다음 표기법을 **동일한 프로퍼티로 인식**:
  - `my-property` (케밥 케이스, 권장)
  - `myProperty` (카멜 케이스)
  - `MY_PROPERTY` (대문자 언더스코어, 환경 변수)
  - `my_property` (스네이크 케이스)
- `@Value`에는 적용되지 않음 — 표기법이 정확히 일치해야 함
- 환경 변수나 시스템 프로퍼티로 설정을 주입할 때 특히 유용

## 예시

```yaml
# application.yaml
my-server:
  max-connections: 100
```

```java
@ConfigurationProperties(prefix = "my-server")
public class ServerProperties {
    private int maxConnections; // my-server.max-connections → maxConnections 자동 바인딩
}
```

## 핵심 정리

- 환경에 따라 프로퍼티 이름 표기가 달라도 바인딩이 깨지지 않습니다
- `@Value`를 사용할 경우 RelaxedBinding이 없으므로 정확한 키 이름을 사용해야 합니다

→ [[@ConfigurationProperties]]
