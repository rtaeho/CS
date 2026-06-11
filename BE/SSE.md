---
title: "SSE"
tags: [HTTP, 웹소켓]
status: published
---

서버가 클라이언트에게 **HTTP 연결을 유지하며 단방향으로 이벤트를 스트리밍**하는 기술입니다 (Server-Sent Events).

## 핵심 특징

- **단방향**: 서버 → 클라이언트 방향만 가능
- **HTTP 기반**: 별도 프로토콜 없이 `text/event-stream` Content-Type 사용
- **자동 재연결**: 연결이 끊기면 브라우저가 자동으로 재시도
- **이벤트 ID**: `Last-Event-ID` 헤더로 마지막 수신 이벤트부터 이어받기 가능

## 이벤트 스트림 형식

```
data: {"message": "처리 중..."}

data: {"message": "완료"}
id: 42
event: done
retry: 3000
```

> 빈 줄(`\n\n`)이 이벤트 구분자. `data:`, `id:`, `event:`, `retry:` 필드 사용.

## Spring MVC — SseEmitter

```java
@GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
public SseEmitter stream() {
    SseEmitter emitter = new SseEmitter(30_000L);  // 30초 타임아웃

    executorService.submit(() -> {
        try {
            for (int i = 0; i < 5; i++) {
                emitter.send(SseEmitter.event()
                    .id(String.valueOf(i))
                    .data("chunk " + i));
                Thread.sleep(500);
            }
            emitter.complete();
        } catch (Exception e) {
            emitter.completeWithError(e);
        }
    });

    return emitter;
}
```

## Spring WebFlux — Flux

```java
@GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
public Flux<ServerSentEvent<String>> stream() {
    return Flux.interval(Duration.ofMillis(500))
        .take(5)
        .map(i -> ServerSentEvent.<String>builder()
            .id(String.valueOf(i))
            .data("chunk " + i)
            .build());
}
```

## 클라이언트 (JavaScript)

```javascript
const es = new EventSource('/stream');

es.onmessage = (e) => console.log(e.data);
es.addEventListener('done', (e) => es.close());
es.onerror = () => es.close();
```

## SSE vs WebSocket vs Polling

| | SSE | [[WebSocket]] | Long Polling |
|---|---|---|---|
| 방향 | 단방향 (서버→클라이언트) | 양방향 | 단방향 |
| 프로토콜 | HTTP | WS (업그레이드) | HTTP |
| 재연결 | 자동 | 직접 구현 | 직접 구현 |
| 헤더 오버헤드 | 최초 1회 | 최초 1회 | 매 요청마다 |
| 사용 예 | AI 응답 스트리밍, 알림 피드 | 채팅, 게임 | 알림 (레거시) |

## 주의사항

- 브라우저당 같은 도메인에 동시 연결 수 제한 (HTTP/1.1: 6개, HTTP/2: 무제한)
- 장시간 열린 연결은 서버 자원 소모 → 적절한 타임아웃 + `onCompletion`/`onTimeout` 핸들러 필수
- 클라이언트가 연결을 끊을 때 서버 flush 완료 여부를 보장할 수 없음 → 정리 로직 명시적으로 처리

## 핵심 정리

- HTTP 그대로 사용하는 단방향 서버 Push — AI 스트리밍 응답, 실시간 알림에 적합

- WebSocket이 양방향 채널이라면, SSE는 "서버가 클라이언트에게 지속적으로 밀어줘야 할 때" 선택

- Spring MVC → `SseEmitter` / Spring WebFlux → `Flux<ServerSentEvent>` 로 구현

→ [[Spring WebFlux]] | [[WebSocket]]

