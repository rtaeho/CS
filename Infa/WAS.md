클라이언트의 요청에 따라 **동적인 콘텐츠(비즈니스 로직, DB 조회 등)를 처리하고 응답을 생성하는 서버 소프트웨어**입니다.

## 핵심 개념

|항목|내용|
|---|---|
|**정식 명칭**|Web Application Server|
|**역할**|비즈니스 로직 실행, 동적 콘텐츠 생성, DB 연동|
|**위치**|웹 서버(Nginx, Apache)와 DB 사이|
|**Java 대표**|Tomcat, Jetty, Undertow, WildFly|
|**프로토콜**|HTTP, AJP, WebSocket 등|

## Web Server vs WAS

|항목|Web Server|WAS|
|---|---|---|
|**역할**|정적 콘텐츠 제공 (HTML, CSS, JS, 이미지)|동적 콘텐츠 생성 (비즈니스 로직 실행)|
|**처리 대상**|이미 만들어진 파일을 그대로 반환|요청마다 로직 수행 후 결과 생성|
|**예시**|Nginx, Apache HTTP Server|Tomcat, Jetty, Undertow|
|**성능**|정적 파일 처리에 최적화|로직 처리에 최적화|
|**부하**|낮음 (파일 반환만)|높음 (연산, DB 조회 등)|

```
[정적 콘텐츠 요청]
클라이언트 → "index.html 줘" → Web Server → index.html 반환

[동적 콘텐츠 요청]
클라이언트 → "내 주문 목록 줘" → WAS → DB 조회 → 결과 생성 → 응답
```

## 일반적인 아키텍처

```
클라이언트 (브라우저)
    │
    ▼
┌──────────────────────────────────┐
│       Web Server (Nginx)          │
│  - 정적 파일 직접 응답              │
│  - SSL 종료                       │
│  - 로드 밸런싱                     │
│  - 리버스 프록시                   │
├──────────────────────────────────┤
│  정적 요청        │  동적 요청      │
│  (HTML, CSS, JS)  │  (/api/*)     │
│       │           │       │       │
│       ▼           │       ▼       │
│  정적 파일 반환     │  WAS로 전달    │
└───────────────────┴───────┬──────┘
                            │
                            ▼
┌──────────────────────────────────┐
│         WAS (Tomcat)              │
│  - 서블릿/JSP 실행                │
│  - Spring 애플리케이션 실행         │
│  - 비즈니스 로직 처리               │
│  - DB 연동                        │
│  - 세션 관리                       │
│  - 트랜잭션 관리                   │
└──────────────┬───────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│        Database (MySQL 등)        │
└──────────────────────────────────┘
```

## WAS가 하는 일

|역할|설명|
|---|---|
|**비즈니스 로직 실행**|주문 처리, 결제, 사용자 인증 등|
|**동적 콘텐츠 생성**|요청에 따라 HTML, JSON 등 응답 생성|
|**DB 연동**|데이터 조회·삽입·수정·삭제|
|**세션 관리**|사용자 로그인 상태 유지|
|**트랜잭션 관리**|데이터 일관성 보장|
|**스레드 풀 관리**|동시 요청 처리를 위한 스레드 관리|
|**커넥션 풀 관리**|DB 연결 재사용으로 성능 최적화|

## Java WAS의 동작 구조 (Tomcat 기준)

```
클라이언트 요청: GET /api/users
    │
    ▼
┌──────────────────────────────────────┐
│             Tomcat (WAS)              │
│                                      │
│  ┌────────────────────────────────┐  │
│  │       Connector (HTTP/AJP)     │  │
│  │  - 요청 수신 (포트 8080)        │  │
│  │  - HTTP 파싱                   │  │
│  └──────────────┬─────────────────┘  │
│                 │                     │
│  ┌──────────────▼─────────────────┐  │
│  │         Thread Pool             │  │
│  │  - 스레드 할당 (기본 200개)      │  │
│  └──────────────┬─────────────────┘  │
│                 │                     │
│  ┌──────────────▼─────────────────┐  │
│  │      Servlet Container          │  │
│  │  ┌────────────────────────┐    │  │
│  │  │   Filter Chain          │    │  │
│  │  │  (인증, 로깅, CORS 등)   │    │  │
│  │  └────────────┬───────────┘    │  │
│  │               ▼                │  │
│  │  ┌────────────────────────┐    │  │
│  │  │  DispatcherServlet     │    │  │
│  │  │  (Spring MVC)          │    │  │
│  │  └────────────┬───────────┘    │  │
│  │               ▼                │  │
│  │  ┌────────────────────────┐    │  │
│  │  │  Controller → Service  │    │  │
│  │  │  → Repository → DB    │    │  │
│  │  └────────────────────────┘    │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

## Java 코드 예시 (Spring Boot + 내장 Tomcat)

```java
// Spring Boot는 WAS(Tomcat)가 내장되어 있음
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
        // 내장 Tomcat이 8080 포트에서 시작
    }
}

// 동적 요청 처리 — WAS가 실행하는 비즈니스 로직
@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    // GET /api/users/1 → WAS가 처리
    @GetMapping("/{id}")
    public ResponseEntity<User> getUser(@PathVariable Long id) {
        User user = userService.findById(id);  // DB 조회
        return ResponseEntity.ok(user);         // JSON 응답 생성
    }

    // POST /api/users → WAS가 처리
    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody UserDto dto) {
        User user = userService.create(dto);    // 비즈니스 로직 + DB 저장
        return ResponseEntity.status(201).body(user);
    }
}
```

## 왜 Web Server와 WAS를 분리하는가?

|이유|설명|
|---|---|
|**역할 분리**|정적/동적 처리를 분리하여 각각 최적화|
|**보안**|WAS를 외부에 직접 노출하지 않음|
|**로드 밸런싱**|여러 WAS에 요청 분배 가능|
|**장애 격리**|WAS 장애 시 Web Server가 에러 페이지 반환|
|**SSL 처리**|Web Server에서 SSL 종료 → WAS 부담 감소|
|**정적 파일 성능**|Nginx가 정적 파일 처리에 훨씬 빠름|

```
[분리 구조의 장점]

                   ┌─── WAS 1 (Tomcat)
Nginx ── 로드밸런싱 ─┼─── WAS 2 (Tomcat)
                   └─── WAS 3 (Tomcat)

WAS 2 장애 발생 시:
  → Nginx가 WAS 1, 3에만 요청 전달
  → 서비스 중단 없음

모든 WAS 장애 시:
  → Nginx가 "503 Service Unavailable" 에러 페이지 반환
  → 사용자에게 깔끔한 에러 표시
```

## 주요 Java WAS 비교

|WAS|특징|용도|
|---|---|---|
|**Tomcat**|경량, 서블릿/JSP 컨테이너, Spring Boot 기본 내장|가장 널리 사용|
|**Jetty**|경량, 임베디드에 강함|마이크로서비스, 클라우드|
|**Undertow**|고성능, 논블로킹 I/O|Spring Boot 대안 내장 WAS|
|**WildFly**|Java EE 풀스펙 지원 (구 JBoss)|엔터프라이즈|
|**WebLogic**|Oracle, Java EE 풀스펙, 상용|대기업 레거시|
|**WebSphere**|IBM, Java EE 풀스펙, 상용|금융/공공 레거시|

```
경량 WAS (서블릿 컨테이너)        풀스펙 WAS (Java EE)
┌──────────────────┐          ┌──────────────────────┐
│ Tomcat, Jetty     │          │ WildFly, WebLogic     │
│ Undertow          │          │ WebSphere             │
│                   │          │                       │
│ - 서블릿/JSP      │          │ - 서블릿/JSP           │
│ - WebSocket       │          │ - EJB                 │
│                   │          │ - JMS                 │
│ Spring이 나머지    │          │ - JPA                 │
│ 기능을 제공        │          │ - CDI                 │
└──────────────────┘          │ - 기타 Java EE 스펙    │
                              └──────────────────────┘
```

## Nginx + Tomcat 연동 예시

```nginx
# nginx.conf
server {
    listen 80;
    server_name example.com;

    # 정적 파일 → Nginx가 직접 처리
    location /static/ {
        root /var/www/html;
    }

    # 동적 요청 → Tomcat(WAS)으로 전달
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```
요청: GET /static/logo.png
  → Nginx가 직접 파일 반환 (빠름)

요청: GET /api/users/1
  → Nginx → Tomcat → Controller → Service → DB → 응답
```