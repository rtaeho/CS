Spring 5에서 도입된 **리액티브 프로그래밍 기반 논블로킹 웹 프레임워크**로, 적은 스레드로 많은 동시 요청을 처리합니다.

## 핵심 개념

- **Reactor**: Spring WebFlux의 리액티브 라이브러리 — `Mono<T>` (0~1개), `Flux<T>` (0~N개) 제공
- **논블로킹 I/O**: 스레드가 I/O 대기 없이 다른 요청 처리 → 적은 스레드로 높은 처리량
- **백프레셔**: 소비자가 처리 가능한 속도로 데이터를 요청 — 과부하 방지
- **이벤트 루프 모델**: Netty 기반 (기본), Tomcat 사용 시 블로킹 방식과 혼용 가능

## Mono / Flux

```java
// Mono: 0 또는 1개 값
Mono<String> mono = Mono.just("hello");
Mono<String> empty = Mono.empty();
Mono<String> error = Mono.error(new RuntimeException("fail"));

// Flux: 0~N개 값 스트림
Flux<Integer> flux = Flux.just(1, 2, 3);
Flux<Long>    interval = Flux.interval(Duration.ofSeconds(1));

// 구독 (실제 실행은 subscribe() 시점)
mono.subscribe(val -> System.out.println(val));
flux.subscribe(
    val   -> System.out.println(val),   // onNext
    err   -> System.err.println(err),   // onError
    ()    -> System.out.println("완료")  // onComplete
);
```

## 컨트롤러 작성

```java
@RestController
@RequestMapping("/posts")
public class PostController {

    @GetMapping("/{id}")
    public Mono<Post> getPost(@PathVariable Long id) {
        return postService.findById(id);  // Mono 반환
    }

    @GetMapping
    public Flux<Post> getAllPosts() {
        return postService.findAll();     // Flux 반환
    }

    // SSE 스트리밍
    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<Post> streamPosts() {
        return postService.streamAll();
    }
}
```

## Spring MVC vs Spring WebFlux

| | Spring MVC | Spring WebFlux |
|---|---|---|
| 모델 | 동기 블로킹 | 비동기 논블로킹 |
| 스레드 | 요청당 1스레드 | 이벤트 루프 (소수 스레드) |
| 서버 | Tomcat (기본) | Netty (기본), Tomcat 가능 |
| DB 지원 | JPA (블로킹) | R2DBC (리액티브 JDBC) |
| 코드 패러다임 | 명령형 | 선언형 (함수형) |
| 학습 곡선 | 낮음 | 높음 |
| 적합한 상황 | CRUD, 팀이 MVC 익숙 | I/O 집약적, 스트리밍, 고동시성 |

## MVC + WebFlux 하이브리드

Spring Boot에서 두 모듈을 같이 쓸 수 있음. MVC 환경에서 특정 엔드포인트만 WebFlux 스타일(`SseEmitter`, `StreamingResponseBody`)로 구현하는 혼합 방식.

```java
// MVC 컨트롤러에서 SSE만 WebFlux처럼 처리
@GetMapping(value = "/ai/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
public SseEmitter streamAI() {
    SseEmitter emitter = new SseEmitter();
    // 논블로킹 처리 위임
    asyncService.processAndEmit(emitter);
    return emitter;
}
```

> 완전한 WebFlux 전환 없이 SSE, 파일 다운로드 등 스트리밍 엔드포인트만 비동기로 처리할 때 유용.

## 주의사항

- **블로킹 코드 금지**: Flux 체인 안에서 `Thread.sleep()`, 블로킹 JDBC 호출 시 이벤트 루프 블로킹 → 성능 역효과
- **R2DBC 필요**: JPA는 블로킹 → WebFlux와 완전 통합하려면 R2DBC로 전환 필요
- **디버깅 어려움**: 비동기 스택 트레이스가 복잡 → `Hooks.onOperatorDebug()` 활용

## 핵심 정리

- `Mono<T>` = 단일 비동기 값 / `Flux<T>` = 비동기 스트림 — 실제 실행은 subscribe 시점

- 적은 스레드로 높은 동시성 처리가 핵심 — I/O 대기 시간이 많은 AI 연동, 파일 처리에 유리

- MVC와 WebFlux는 같은 프로젝트에서 혼용 가능 — 스트리밍 엔드포인트만 WebFlux 방식으로

→ [[SSE]] | [[비동기]] | [[Spring MVC vs WebFlux]]
