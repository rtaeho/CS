---
title: MCP의 스테이트리스 전환
tags: [AI소식, 프로토콜, MCP]
status: published
---

MCP(Model Context Protocol) 스펙이 2026-07-28 개정판에서 `initialize` 핸드셰이크와 연결별 세션을 없애고 완전한 스테이트리스 프로토콜로 바뀌었다.
기준 시점: 2026-07-28

## 무슨 일인가

MCP 공식 스펙 저장소의 "Key Changes" 문서에 따르면, 2026-07-28 개정판(이전 개정판은 2025-11-25)은 메이저 변경 9건을 담았다. 가장 큰 축은 상태(state)를 프로토콜 레벨에서 완전히 제거한 것이다.

- `initialize`/`notifications/initialized` 핸드셰이크를 없앴다. 이제 모든 요청이 `_meta` 필드에 자신의 프로토콜 버전과 클라이언트 기능(`io.modelcontextprotocol/protocolVersion`, `clientCapabilities`)을 담아 보낸다. 버전이 안 맞으면 `UnsupportedProtocolVersionError`를 반환한다.
- Streamable HTTP 전송에서 `Mcp-Session-Id` 헤더와 프로토콜 세션을 없앴다. `tools/list` 같은 목록 응답이 더 이상 연결마다 달라지지 않는다. 호출 간 상태가 필요하면 서버가 발급한 핸들을 평범한 툴 인자로 주고받는 방식을 쓴다.
- `server/discover`라는 새 RPC를 추가했다. 서버는 이 메서드로 지원 프로토콜 버전·기능·신원을 알려야 하며, 클라이언트는 다른 요청 전에 미리 호출해 버전을 고를 수 있다.
- 서버→클라이언트 변경 알림은 HTTP GET 엔드포인트와 `resources/subscribe`/`unsubscribe` 대신 `subscriptions/listen`이라는 단일 장기 연결 스트림으로 받는다. 클라이언트가 원하는 알림 종류만 선택적으로 구독한다.
- `ping`, `logging/setLevel`, `notifications/roots/list_changed`를 없앴다. 로그 레벨은 요청마다 `_meta`로 지정한다.
- 실험적이던 Tasks 기능을 핵심 프로토콜에서 빼 공식 확장(`io.modelcontextprotocol/tasks`)으로 옮기고, 블로킹 방식이던 `tasks/result`를 폴링 방식 `tasks/get`/`tasks/update`로 바꿨다.
- 서버가 보내던 `roots/list`, `sampling/createMessage` 같은 요청들은 Multi Round-Trip Requests(MRTR) 패턴으로 대체됐다. 서버가 `resultType: "input_required"`인 결과를 돌려주면, 클라이언트는 같은 요청을 추가 정보와 함께 재시도한다.
- SSE 스트림 재연결·메시지 재전송(`Last-Event-ID`)도 없앴다. 응답 스트림이 끊기면 클라이언트는 새 요청 ID로 처음부터 다시 보낸다.

같은 문서는 Roots, Sampling, Logging 세 기능과 HTTP+SSE 전송을 공식적으로 "Deprecated" 상태로 분류했다고도 밝혔다.

## 왜 중요한가

세션을 없앴다는 것은 MCP 서버를 운영하는 쪽에서 더 이상 "이 클라이언트가 어느 서버 인스턴스에 붙어 있는지"를 신경 쓰지 않아도 된다는 뜻이다. 로드 밸런서 뒤에 서버를 여러 대 띄워도 요청마다 아무 인스턴스로 보내면 되고, 스케일 아웃이 훨씬 단순해진다. 반대로 지금까지 세션 상태에 의존해 구현된 MCP 서버·클라이언트는 이번 개정에서 구조를 다시 짜야 한다.

Sampling(서버가 클라이언트의 LLM을 빌려 쓰는 기능)과 Roots(파일 루트 공유)가 Deprecated로 분류된 것도 눈에 띈다. 스펙 자체가 "서버가 클라이언트 쪽 LLM 호출을 대신 요청하는" 설계보다 "툴 파라미터나 리소스 URI로 필요한 걸 직접 넘기는" 설계를 권장하는 방향으로 움직이고 있다는 신호로 읽힌다.

## 짚고 갈 개념

- MCP — 모델에 외부 컨텍스트·툴을 붙이는 프로토콜, 서버/클라이언트 구조
- 스테이트리스 — 서버가 요청 간 상태를 들고 있지 않고 매 요청이 필요한 정보를 모두 담아 보내는 설계 방식 ([[Stateless]])

## 내 생각

MCP가 나온 지 1년 조금 넘은 시점에 세션·핸드셰이크 같은 "전형적인 연결 지향 프로토콜" 요소를 걷어내고 스테이트리스로 간 건, 실제 운영 환경에서 MCP 서버를 여러 대 띄워 돌려본 피드백이 쌓였기 때문으로 보인다. 다만 호출 간 상태가 필요한 경우 "서버가 발급한 핸들을 툴 인자로 주고받으라"는 건 결국 상태 관리를 프로토콜 밖, 즉 서버 구현 쪽으로 떠넘긴 것이어서, 스펙은 가벼워지지만 서버 구현의 복잡도는 그대로거나 오히려 늘어날 수 있을 것으로 보인다.

## 출처

- https://modelcontextprotocol.io/specification/2026-07-28/changelog
- https://github.com/modelcontextprotocol/modelcontextprotocol
