---
title: "Servlet"
tags: [Java, HTTP, WAS]
status: published
---

Java에서 HTTP 요청과 응답을 처리하기 위해 정의된 서버 측 웹 컴포넌트 표준입니다.

## 핵심 특징

- **요청/응답 기반**: `HttpServletRequest`, `HttpServletResponse`를 이용해 요청과 응답을 처리
- **컨테이너 관리**: 생성, 초기화, 실행, 소멸은 [[Tomcat]] 같은 서블릿 컨테이너가 담당
- **메서드 분기**: HTTP 메서드에 따라 `doGet()`, `doPost()` 등으로 처리
- **Spring MVC 기반**: [[DispatcherServlet]]도 Servlet 구현체로 동작

## 생명주기

```text
load
  |
  v
init()
  |
  v
service() -> doGet() / doPost() / ...
  |
  v
destroy()
```

서블릿 컨테이너는 처음 요청이 들어오거나 애플리케이션 시작 시 서블릿을 생성하고 `init()`을 호출합니다. 이후 요청마다 `service()`가 실행되고, 애플리케이션 종료 시 `destroy()`가 호출됩니다.

## 기본 예시

```java
public class HelloServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("text/plain");
        response.getWriter().write("hello");
    }
}
```

## Servlet과 DispatcherServlet

Spring MVC는 직접 여러 서블릿을 작성하는 대신 하나의 `DispatcherServlet`이 모든 요청의 진입점이 되는 Front Controller 패턴을 사용합니다.

| 항목 | Servlet | DispatcherServlet |
|---|---|---|
| 범위 | Java 웹 표준 | Spring MVC의 중심 서블릿 |
| 역할 | 요청/응답 처리 | 컨트롤러 탐색, 호출, 응답 변환 |
| 관리 주체 | Servlet Container | Servlet Container + Spring Container |

## 핵심 정리

Servlet은 Java 웹 애플리케이션의 요청 처리 표준입니다.

Tomcat 같은 서블릿 컨테이너가 생명주기를 관리하고,
Spring MVC는 DispatcherServlet을 통해 서블릿 기반 요청 처리를 추상화합니다.

→ [[톰캣에 대해서 설명해주세요]]
