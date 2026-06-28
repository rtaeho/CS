---
title: "AutoConfiguration 동작 원리를 설명해주세요"
tags: [매일메일, Backend]
status: published
---

[[AutoConfiguration]]의 시작은 `[[@SpringBootApplication]]` 안에 있는 `@EnableAutoConfiguration`입니다.

`@EnableAutoConfiguration`은 `@Import(AutoConfigurationImportSelector.class)`를 통해 자동 구성 클래스를 가져옵니다.

```java
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@AutoConfigurationPackage
@Import({AutoConfigurationImportSelector.class})
public @interface EnableAutoConfiguration {
    String ENABLED_OVERRIDE_PROPERTY = "spring.boot.enableautoconfiguration";

    Class<?>[] exclude() default {};

    String[] excludeName() default {};
}
```

자동 구성 클래스를 가져올 때는 `AutoConfigurationImportSelector` 클래스의 `selectImports(AnnotationMetadata annotationMetadata)` 메서드를 이용합니다. 내부적으로 `getAutoConfigurationEntry(AnnotationMetadata annotationMetadata)` 메서드를 통해 import할 클래스가 무엇인지 결정합니다.

## 간단한 메서드 동작 과정

1. `getCandidateConfigurations(annotationMetadata, attributes)`로 AutoConfiguration 후보를 가져옵니다.
2. `removeDuplicates(configurations)`로 중복을 제거합니다.
3. `getExclusions(annotationMetadata, attributes)`로 자동 설정에서 제외되는 설정 정보를 가져옵니다.
4. `configurations.removeAll(exclusions)`로 제외되는 설정을 제거합니다.
5. `getConfigurationClassFilter().filter(configurations)`로 조건 필터를 적용합니다.

## 참고

- https://velog.io/@realsy/Spring-Boot-AutoConfiguration-%EB%8F%99%EC%9E%91-%EC%9B%90%EB%A6%AC
