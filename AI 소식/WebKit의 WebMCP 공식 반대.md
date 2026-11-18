---
title: WebKit의 WebMCP 공식 반대
tags: [AI소식, 웹표준, 에이전트, 브라우저]
status: published
---

웹 페이지의 기능을 AI 에이전트용 툴로 노출하는 브라우저 표준 제안 WebMCP에 애플 WebKit이 2026년 6월 11일 공식 반대(oppose) 입장을 냈고, W3C TAG도 10월 26일까지 별도 우려를 이어 공유하며 표준화 경로가 불확실해졌다.
기준 시점: 2026-10-26

## 무슨 일인가

WebMCP는 구글(Dominic Farolino)과 마이크로소프트(Brandon Walderman)가 주도해 W3C Web Machine Learning Community Group에서 논의 중인 제안이다. 웹 개발자가 `document.modelContext.registerTool()`로 자연어 설명과 JSON Schema를 가진 "tool"을 등록하면, 브라우저 내장 에이전트나 iframe 안의 에이전트, 확장 프로그램이 그 tool을 직접 호출해 사람을 위해 만들어진 웹 콘텐츠를 조작할 수 있게 하는 구조다. 명세의 explainer는 2025년 8월 13일 처음 공개됐다고 적혀 있다. Chrome은 Chrome 149부터, Edge는 Edge 150부터 origin trial을 진행 중이다.

WebKit의 standards-positions 저장소 이슈 #670은 2026년 5월 28일 열렸고, 6월 3일 WebKit 담당자(@mwyrzykowski)가 반대 의견을 공식화했으며, 6월 11일 "position: oppose" 라벨이 붙어 종료됐다. WebKit이 밝힌 반대 근거는 다음과 같다.

- 에이전트를 위한 별도 도구 계층이 필요하다면 HTML·ARIA 같은 기존 공유 계층에서 풀어야 하는데, WebMCP의 도구 선택은 자연어 이름·설명에 의존하고 명세 스스로 이것이 모호하고 검증할 수 없다고 인정한다는 점.
- 에이전트는 사실상 보조 기술인데 WebMCP가 이를 별도로 취급해 "에이전트가 조작 중"임을 관찰 가능하게 만들고, 사람용·에이전트용 기능 간 동등성을 보장하지 못한다는 점.
- 격리 모델(COOP·COEP·Site Isolation)과의 상호작용이 검토되지 않은 교차 출처 호출 경로, 동의·되돌리기 모델 부재, 개인화 데이터를 이용한 추적 가능성.
- Service Worker로 확장해 사용자가 열어두지 않은 사이트의 도구까지 백그라운드에서 호출하게 하는 방향은 인증된 부작용 작업의 위험을 키운다는 점.
- 이 작업은 HTML·접근성 의미론의 영역이라 WHATWG, W3C ARIA·APA 그룹이 적합하며 머신러닝 CG는 맞는 venue가 아니라는 점.

Mozilla는 6월 1일 "neutral" 입장을 냈다. WebKit 반대 직후 구글 쪽 domfarolino가 선언형(declarative) API만 남기면 되는지 등을 물었고, 6월 17일 애플 쪽 marcoscaceres는 항목별로 답하지 않겠다며 대신 WebMCP를 잠시 보류하고 새 커뮤니티 그룹에서 문제 정의와 사용 사례부터 다시 다루자고, 2026 TPAC(10월 26~30일, 더블린) 시기에 W3C 워크숍을 열자고 제안했다.

별도로 W3C TAG의 design review #1238도 6월 11일 열려 진행 중이다. 10월 9일 Mozilla가 TPAC 이후까지 공식 입장을 미뤄 달라고 요청했고, 10월 26일 TAG 측(christianliebel)이 "결정이 아닌 현재 생각"이라며 우려를 추가로 공유했다: 에이전트 전용 기능 설명이 콘텐츠를 중복시켜 "에이전트를 위한 웹"으로 변질될 위험, 사용자가 에이전트에게 묻지 않으면 어떤 도구가 있는지 알기 어려운 불투명성, 선언형 버전을 먼저 완성해야 한다는 요구, 명령형 도구가 노드별 언어·방향 정보를 전달하지 못한다는 점, 웹 플랫폼 API에서 처음 쓰이는 JSON Schema에 대한 우려, "WebMCP"라는 이름이 MCP와의 관계를 암시해 오해를 준다며 이름 변경 검토 요청, 에이전틱 브라우징의 보안·프라이버시·신원 위임 문제는 별도 Finding으로 다룰 예정이라는 점이다. 이 이슈는 "Progress: in progress"와 "Missing: Multi-stakeholder support" 라벨이 붙은 채 아직 열려 있다.

## 왜 중요한가

[[MCP]]가 서버 쪽 툴 연동에서 빠르게 사실상 표준이 된 것과 달리, WebMCP는 같은 역할을 브라우저 안에서 하려는 시도인데 3대 렌더링 엔진 중 하나인 WebKit이 공식 반대했다. Chrome·Edge가 origin trial을 이어가도 Safari가 구현하지 않으면 상호운용 가능한 웹 표준이 아니라 사실상 Chromium 전용 기능으로 남을 수 있다. 또한 이 공방은 "에이전트가 쓰기 편한 새 API를 만들 것인가, 사람·보조기술이 이미 쓰는 HTML·ARIA 같은 기존 접근성 계층을 에이전트도 쓰게 할 것인가"라는 질문을 구체적인 사례로 드러낸다. 이 질문은 앞으로 나올 비슷한 에이전트용 웹 표준 제안에도 반복해서 적용될 것으로 보인다.

## 짚고 갈 개념

- [[MCP]] — 모델에 외부 컨텍스트·툴을 붙이는 서버 기반 프로토콜. WebMCP는 이것의 브라우저 쪽 대응으로 비교된다.
- WebMCP — 웹 페이지가 자신의 기능을 자연어 설명과 JSON Schema를 가진 tool로 노출해 브라우저 내 AI 에이전트가 직접 호출하게 하는 브라우저 표준 제안
- Permissions Policy — 교차 출처 iframe에 `allow="tools"`처럼 상위 문서가 특정 기능의 사용 권한을 하위 문서에 위임하는 웹 플랫폼 메커니즘

## 내 생각

WebKit이 든 반대 근거 중 "도구 선택이 자연어 이름·설명에 의존하고 명세 스스로 모호함을 인정한다"는 지적이 가장 근본적으로 보인다. 스키마와 함수 이름을 아무리 잘 설계해도 에이전트가 결국 자연어 설명을 보고 도구를 고르는 구조라면, [[MCP]] 서버를 설계할 때 이미 나온 "툴 이름이 모호하면 에이전트가 잘못 고른다"는 문제가 브라우저 안에서도 그대로 재현될 것이다. 다만 "기존 HTML·ARIA로 충분하다"는 WebKit의 대안도, 스크린 리더가 사람에게 설명하려고 만든 의미 구조를 에이전트의 함수 호출 패턴에 그대로 맞출 수 있을지는 TPAC 워크숍 이후 논의를 더 봐야 판단할 수 있을 것 같다.

## 출처

- https://github.com/webmachinelearning/webmcp
- https://github.com/w3ctag/design-reviews/issues/1238
- https://github.com/WebKit/standards-positions/issues/670
