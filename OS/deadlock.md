---
title: "deadlock"
tags: [데드락, 교착상태, 동기화]
status: published
---

둘 이상의 프로세스가 서로 상대방이 점유한 자원을 기다리며 무한히 대기하는 상태입니다.

## 발생 조건 (4가지 모두 충족 시 발생)

|조건|설명|
|---|---|
|**상호 배제**|자원은 한 번에 하나의 프로세스만 사용 가능|
|**점유 대기**|자원을 점유한 채 다른 자원을 기다림|
|**비선점**|다른 프로세스의 자원을 강제로 빼앗을 수 없음|
|**순환 대기**|프로세스들이 원형으로 서로의 자원을 대기|

## 발생 상황

```
A 프로세스: 자원1 점유 → 자원2 요청
B 프로세스: 자원2 점유 → 자원1 요청
→ 서로 무한 대기
```

## 해결 방법

|방법|설명|단점|
|---|---|---|
|**예방**|4가지 조건 중 하나를 원천 차단|자원 낭비 심함|
|**회피**|안전 상태만 허용 (은행원 알고리즘)|복잡한 계산 필요|
|**탐지 & 회복**|주기적으로 탐지 후 프로세스 종료/자원 선점|회복 비용 발생|
|**무시**|드물게 발생하면 그냥 무시 (Ostrich 알고리즘)|실제 OS에서 많이 사용|

## Java 예시 (교착상태 발생 코드)

```java
Object lock1 = new Object();
Object lock2 = new Object();

// 스레드 A
Thread threadA = new Thread(() -> {
    synchronized (lock1) {
        synchronized (lock2) { // lock2 대기
            System.out.println("Thread A");
        }
    }
});

// 스레드 B
Thread threadB = new Thread(() -> {
    synchronized (lock2) {
        synchronized (lock1) { // lock1 대기
            System.out.println("Thread B");
        }
    }
});
```

## Java 예시 (해결 - 락 순서 고정)

```java
// 두 스레드 모두 lock1 → lock2 순서로 획득
Thread threadA = new Thread(() -> {
    synchronized (lock1) {
        synchronized (lock2) {
            System.out.println("Thread A");
        }
    }
});

Thread threadB = new Thread(() -> {
    synchronized (lock1) { // 순서 통일
        synchronized (lock2) {
            System.out.println("Thread B");
        }
    }
});
```

> 락 획득 순서를 통일하면 **순환 대기** 조건이 깨져 데드락이 방지됩니다.