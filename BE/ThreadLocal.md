---
title: "ThreadLocal"
tags: [ThreadLocal, 스레드, 동시성]
status: published
---

Java에서 각 [[스레드]]마다 독립적인 변수를 저장할 수 있도록 지원하는 클래스다.

## 동작 원리

각 스레드는 자신만의 `ThreadLocalMap`을 가지고 있고, ThreadLocal 인스턴스를 키로 사용해 값을 저장한다. 하나의 스레드에서 여러 개의 ThreadLocal을 사용할 수 있으며, ThreadLocal 자체는 현재 스레드의 ThreadLocalMap에 접근해 값을 읽고 쓰는 역할만 한다. 따라서 여러 스레드가 공유 자원을 함께 사용할 때 발생하는 동시성 문제를 스레드별로 데이터를 격리해 해결할 수 있다.

## 장점

- 스레드마다 격리된 값을 가지므로 `synchronized` 같은 동기화 처리가 필요 없다.
- 메서드 인자로 값을 계속 전달하지 않고도 스레드 내 어디서든 값을 참조할 수 있다.

## 활용 예

Spring에서는 ThreadLocal을 기반으로 아래와 같은 기능을 제공한다.

- `TransactionSynchronizationManager`: 트랜잭션 동기화 정보 관리
- `SecurityContextHolder`: 사용자 인증 정보 관리
- `RequestContextHolder`: 웹 요청의 attribute 관리

## 주의사항

- **스레드풀 재사용 문제**: 스레드풀은 스레드를 재사용하므로, 이전 작업에서 ThreadLocal에 저장한 값이 남아 있으면 재사용된 스레드가 잘못된 데이터를 참조할 수 있다. 작업이 끝나는 시점에 `remove()`를 호출해 저장된 값을 제거해야 한다.
- **비동기 작업과의 호환 문제**: `@Async`처럼 새로운 스레드에서 비동기 작업이 실행되면, 비동기 스레드는 기존 스레드의 ThreadLocal 값을 참조할 수 없다. Spring 4.3 이상의 **TaskDecorator**를 사용해 기존 스레드의 ThreadLocal 값을 비동기 스레드로 복사하는 방식으로 해결할 수 있다.

## 대체 방법

- 메서드 인자로 값을 직접 전달한다.
- `ConcurrentHashMap`과 같은 thread-safe 자료구조를 사용한다.
- Spring의 `@RequestScope`를 사용해 HTTP 요청 단위로 데이터를 관리한다.

## NamedThreadLocal

Spring이 제공하는 ThreadLocal의 확장 클래스로, 이름을 부여해 디버깅을 쉽게 할 수 있도록 설계되었다. 기본 기능은 ThreadLocal과 동일하지만, 여러 개의 ThreadLocal을 사용할 때 이름으로 용도를 구분할 수 있어 디버깅이 용이하다.

## 핵심 정리

ThreadLocal은 스레드별로 독립된 저장 공간을 제공해 동기화 없이 동시성 문제를 해결하는 도구다. 다만 스레드풀 환경에서는 재사용 시점에 값이 남아 있지 않도록 `remove()`를 호출해야 하고, 비동기 작업에서는 값이 전파되지 않는 점에 주의해야 한다.

→ [[ThreadLocal에 대해 설명해 주세요.]]
