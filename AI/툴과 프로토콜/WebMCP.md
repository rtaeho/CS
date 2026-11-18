---
title: "WebMCP"
tags: [AI에이전트, 툴과프로토콜]
status: published
---

웹 페이지가 자신의 기능을 자연어 설명과 JSON Schema를 가진 "tool"로 노출해, 브라우저에 내장된 AI 에이전트나 확장 프로그램이 그 tool을 직접 호출해 사람을 위해 만들어진 웹 콘텐츠를 조작하게 하는 브라우저 표준 제안이다.
기준 시점: 2026-11

## 왜 필요한가

에이전트가 웹 페이지를 조작하는 방법은 크게 둘로 나뉜다. 하나는 스크린샷·DOM 분석·모의 클릭으로 사람처럼 화면을 흉내 내는 방식인데, 느리고 페이지 구조가 바뀌면 쉽게 깨진다. 다른 하나는 [[MCP]] 서버를 따로 만들어 백엔드 API를 직접 호출하는 방식인데, 이 경우 웹 UI와 로그인된 사용자 맥락을 우회하게 되고, 개발자는 사용자의 상태·인증 정보를 백엔드 서버 쪽에 별도로 다시 구현해야 한다. WebMCP는 이미 브라우저 안에 떠 있는 페이지가 가진 클라이언트 측 로직과 DOM 상호작용을 그대로 재사용해 세 번째 방법을 만든다 — 페이지 자신이 "이 브라우저 탭 안에서 동작하는 MCP 서버"가 되는 셈이다.

## 구조

호출 수명주기는 등록 → 탐색 → 호출 → 실행 → 응답 순서다.

```
[페이지 스크립트]                 [에이전트/확장 프로그램]
      │ registerTool(tool)               │
      ▼                                  │
document.modelContext  ── toolchange ──▶ getTools()
      │                                  │
      │        executeTool(tool, args) ◀─┘
      ▼
   execute({ args })  (등록 시 넘긴 콜백 실행)
      │
      └──▶ 결과를 호출자에게 반환
```

핵심 API는 `document.modelContext.registerTool()`이다. 이름·설명·`inputSchema`·`execute` 콜백을 넘겨 등록하고, 두 번째 인자로 넘긴 `AbortSignal`을 나중에 abort하면 등록을 해제한다.

```js
const controller = new AbortController();
await document.modelContext.registerTool({
  name: "add-todo",
  description: "할 일 목록에 항목을 추가한다",
  inputSchema: {
    type: "object",
    properties: { text: { type: "string" } },
    required: ["text"],
  },
  async execute({ text }) {
    // 기존 클라이언트 로직을 그대로 재사용
    return { content: [{ type: "text", text: `추가됨: ${text}` }] };
  },
}, { signal: controller.signal });

// 해제
controller.abort();
```

- `getTools({ fromOrigins })` — 기본적으로 같은 origin의 tool만 조회하고, 교차 origin tool은 `fromOrigins`로 명시해야 한다.
- `executeTool(tool, args, { signal })` — 발견한 tool을 tool 소유자의 실행 컨텍스트에서 실행한다.
- `toolchange` 이벤트 — tool이 추가·제거될 때 발생해 목록을 갱신할 수 있게 한다.
- 교차 출처 iframe에는 Permissions Policy로 `allow="tools"`처럼 권한을 위임해야 하고, 권한이 없으면 `registerTool()`은 `NotAllowedError`로 거부된다.

## 트레이드오프

- MCP는 서버 쪽에 한 번 구현하면 여러 호스트에서 재사용할 수 있지만 백엔드 API 설계가 필요하다. WebMCP는 이미 있는 클라이언트 로직을 그대로 노출해 백엔드를 새로 만들 필요가 없지만, 그 페이지를 열어 둔 동안에만 tool이 존재한다.
- 에이전트의 tool 선택이 결국 자연어 이름·설명에 의존한다. 명세 스스로 이것이 모호하고 검증할 수 없다는 점을 인정하고 있어, [[MCP]] 서버의 [[함수 호출|툴]] 이름이 모호하면 잘못 호출되는 문제가 브라우저 쪽에서도 그대로 재현될 수 있다.

## 주의사항

- 아직 W3C Web Machine Learning Community Group의 Draft Community Group Report 단계로, Chrome 149부터(Edge 150부터) origin trial 중이며 W3C 표준 트랙에 올라 있지 않다.
- WebKit은 2026년 6월 11일 공식 반대(oppose) 입장을 냈다. 별도의 에이전트 전용 도구 계층 대신 HTML·ARIA 같은 기존 공유 계층에서 풀어야 한다는 것, 교차 출처 호출 경로가 격리 모델(COOP·COEP·Site Isolation)과의 상호작용 검토 없이 열려 있다는 것, 동의·되돌리기 모델이 없다는 것이 주된 근거다.
- Service Worker까지 확장해 사용자가 열어 두지 않은 사이트의 tool을 백그라운드에서 호출하게 하는 방향은 인증된 부작용 작업(결제·삭제 등)의 위험을 키운다는 우려가 나온 상태다.
- 브라우저 3사(Chrome·Edge, Firefox, Safari) 중 하나가 반대하는 상태라 아직 상호운용 가능한 표준으로 자리잡았다고 보기 어렵다.

## 핵심 정리

- WebMCP는 `document.modelContext.registerTool()`로 웹 페이지의 클라이언트 측 기능을 tool로 노출해, 브라우저 내 에이전트가 스크래핑 없이 구조화된 방식으로 페이지를 조작하게 한다
- [[MCP]]가 서버 쪽에서 외부 서비스를 붙이는 프로토콜이라면, WebMCP는 그 역할을 브라우저 안의 페이지 자신이 하게 만드는 쪽이다
- tool 선택이 자연어 설명에 의존하는 모호함, 교차 출처·Service Worker 보안 모델 미비가 아직 풀리지 않은 채로 WebKit의 공식 반대를 받았다

## 참고

- [WebMCP 명세·explainer, webmachinelearning/webmcp](https://github.com/webmachinelearning/webmcp)
- [W3C TAG design review #1238: Incubation: WebMCP](https://github.com/w3ctag/design-reviews/issues/1238)
- [WebKit standards-positions #670: WebMCP](https://github.com/WebKit/standards-positions/issues/670)
