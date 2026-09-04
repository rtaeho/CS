---
title: "Gradle"
tags: [빌드도구, JVM, 의존성관리]
status: published
---

Java, Kotlin, Scala 등 JVM 기반 언어에서 사용되는 빌드 자동화 도구다.

## 빌드 자동화 도구를 쓰는 이유

- 컴파일, 테스트, 패키징, 배포 같은 반복 작업을 자동화해 생산성을 높인다.
- 어떤 환경에서도 동일한 빌드 결과를 보장한다.
- [[CI·CD]] 파이프라인과 연동해 빌드 이후 배포까지 이어갈 수 있다.
- 외부 라이브러리를 자동으로 관리해 의존성 버전 충돌을 줄인다.

## 특징

기존 Ant와 Maven의 단점을 보완한 도구로, 증분 빌드·빌드 캐시·데몬 프로세스를 활용해 빌드 속도를 최적화하고 멀티 프로젝트를 쉽게 관리하도록 설계되었다. Groovy 또는 Kotlin DSL로 빌드 스크립트를 작성할 수 있어 XML 기반의 Maven보다 유연하다.

## Maven과의 차이

|항목|Maven|Gradle|
|--|--|--|
|빌드 스크립트|XML|Groovy/Kotlin DSL|
|빌드 속도|느림 (항상 전체 빌드)|빠름 (증분 빌드, 빌드 캐시)|
|의존성 관리|기본적인 의존성 관리|동적 버전 관리, 캐싱 최적화|
|확장성|한정적인 플러그인|다양한 플러그인, 커스텀 태스크|
|멀티 프로젝트|상속 방식, 설정 복잡|설정 주입 방식, 관리 최적화|

## Dependency Configuration

의존성의 사용 범위를 구분해 빌드 성능을 개선하고, 불필요한 의존성이 결과물에 섞이지 않도록 하는 설정이다.

- **implementation**: 컴파일·런타임 시점 모두 필요하고, 현재 모듈에서만 쓰는 일반적인 의존성.
- **api**: implementation과 같지만 다른 모듈에도 전이되어 노출되는 의존성. 예를 들어 a → b → c 관계에서 a가 c를 쓰려면 b가 c를 api로 추가해야 한다.
- **compileOnly**: 컴파일 시점에만 필요한 의존성 (예: Lombok).
- **annotationProcessor**: 컴파일 시점에 실행되는 어노테이션 프로세서 (예: Lombok, MapStruct).
- **runtimeOnly**: 런타임 시점에만 필요한 의존성 (예: DB 드라이버).
- **testImplementation / testCompileOnly / testRuntimeOnly**: 테스트 코드에서만 쓰는 의존성.

## 핵심 정리

Gradle은 증분 빌드와 빌드 캐시로 Maven보다 빠른 빌드 속도를 제공하며, DSL 기반 스크립트로 멀티 프로젝트 구성을 유연하게 관리할 수 있다. Dependency Configuration을 목적에 맞게 나누는 것이 빌드 성능과 결과물 크기 최적화의 핵심이다.

→ [[Gradle에 대해 설명해 주세요.]]
