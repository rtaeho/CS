---
title: "Tomcat"
tags: [Java, Spring, WAS]
status: published
---

Java Servlet과 JSP를 실행하기 위한 대표적인 오픈소스 웹 애플리케이션 서버이자 서블릿 컨테이너입니다.

## 핵심 특징

- **서블릿 컨테이너**: [[Servlet]]의 생성, 실행, 소멸 생명주기를 관리
- **HTTP 처리**: 클라이언트의 [[HTTP]] 요청을 받고 응답을 반환
- **요청 매핑**: URL과 서블릿 또는 Spring의 [[DispatcherServlet]]을 연결
- **필터 체인 관리**: [[Filter]]를 순서대로 실행해 인증, 로깅, 인코딩 등을 처리
- **Spring Boot 내장 서버**: Spring Boot 웹 애플리케이션은 기본적으로 내장 Tomcat을 사용

## 요청 처리 흐름

```text
Client
  |
  v
Tomcat Connector
  |
  v
Filter Chain
  |
  v
Servlet / DispatcherServlet
  |
  v
Response
```

Tomcat은 네트워크 요청을 받아 적절한 서블릿으로 전달하고, 서블릿이 만든 응답을 다시 클라이언트에게 반환합니다.

## Servlet 컨테이너 역할

- 서블릿 인스턴스 생성과 초기화
- 요청마다 `service()` 호출
- `doGet()`, `doPost()` 같은 HTTP 메서드별 처리 위임
- 종료 시 `destroy()` 호출
- 멀티스레드 기반 요청 처리

## Tomcat vs Web Server

| 항목 | Tomcat | Web Server |
|---|---|---|
| 역할 | Java 웹 애플리케이션 실행 | 정적 파일 제공, 프록시 |
| 처리 대상 | Servlet, JSP, Spring MVC | HTML, CSS, JS, 이미지 |
| 예 | Apache Tomcat | Nginx, Apache HTTP Server |

## 주의사항

- Tomcat은 요청마다 스레드를 사용하므로 스레드 풀, 커넥션 수, 타임아웃 설정이 중요함
- 정적 리소스 처리와 TLS 종료는 Nginx 같은 웹 서버나 로드 밸런서에 맡기는 구성이 많음
- Spring Boot 내장 Tomcat도 운영 환경에서는 커넥션, 스레드, graceful shutdown 설정을 점검해야 함

## 핵심 정리

Tomcat은 Java 웹 요청을 처리하는 서블릿 컨테이너입니다.

Spring MVC 애플리케이션에서는 Tomcat이 요청을 받고,
최종적으로 DispatcherServlet이 컨트롤러 호출 흐름을 시작합니다.

→ [[톰캣에 대해서 설명해주세요]]
