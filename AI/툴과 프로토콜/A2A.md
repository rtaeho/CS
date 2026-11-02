---
title: "A2A"
tags: [AI에이전트, 툴과프로토콜]
status: published
---

서로 다른 벤더·프레임워크로 만들어진 에이전트들이 서로의 내부 상태·메모리·툴을 들여다보지 않고도 작업을 주고받을 수 있게 하는 개방형 프로토콜이다.
기준 시점: 2026-11

## 왜 필요한가

[[MCP]]는 에이전트 하나가 외부 툴·데이터에 붙는 수직 연결을 표준화한다. 반면 에이전트 둘 이상이 서로를 상대로 "이 작업을 처리해 달라"고 주고받는 수평 연결에는 표준이 따로 필요했다. A2A는 이 역할을 맡아, 공급사가 다른 에이전트끼리도 같은 방식으로 서로의 능력을 찾고(discover) 작업을 맡기고 결과를 돌려받게 한다.

## 구조

```
A2A Client                         A2A Server (Remote Agent)
(사용자나 다른 시스템을 대신해        (A2A 엔드포인트를 노출하고
 요청을 보내는 에이전트/앱)            작업을 처리하는 에이전트)

  1. GET /.well-known/agent-card.json
     ─────────────────────────────▶
     ◀───────────────────────────── Agent Card (능력·접속 정보)

  2. SendMessage(Task 생성)
     ─────────────────────────────▶
     ◀───────────────────────────── Task { id, state: SUBMITTED }

  3. (폴링 GetTask / 스트리밍 / 푸시 알림으로 진행 상태 수신)
     ◀───────────────────────────── Task { state: WORKING → COMPLETED }
                                      + Artifact(결과물)
```

- **Agent Card** — 서버가 자신을 설명하는 JSON 문서. name·description·version 같은 식별 정보, 접속 가능한 인터페이스 목록(`supportedInterfaces`, 각각 URL·프로토콜 바인딩·버전을 담는다), streaming·pushNotifications 같은 `capabilities`, 에이전트가 제공하는 능력 목록인 `skills`, 인증 방식을 적는 `securitySchemes`로 구성된다.
- **Discovery(탐색)** — 클라이언트가 Agent Card를 찾는 방법은 세 가지다: 정해진 경로(`/.well-known/agent-card.json`)로 직접 조회, 레지스트리·카탈로그에서 찾기, 또는 Agent Card URL을 미리 설정해 두기.
- **Task(작업)** — 프로토콜이 추적하는 작업 단위. `SUBMITTED` → `WORKING`을 거쳐 `COMPLETED`/`FAILED`/`CANCELED`/`REJECTED` 같은 종료 상태로 끝나거나, 클라이언트의 추가 입력·인증을 기다리는 `INPUT_REQUIRED`/`AUTH_REQUIRED` 상태로 멈춘다. 종료 상태에 도달한 작업에는 더 이상 메시지를 보낼 수 없다.
- **Message와 Artifact** — Message는 역할(user/agent)과 내용(텍스트·파일·구조화 데이터로 이루어진 parts)을 담은 한 턴의 통신이고, Artifact는 작업이 만들어낸 최종 결과물이다. 스펙은 결과는 Artifact로, 대화는 Message로 나눠 쓰도록 권장한다.
- **진행 상태 전달** — 폴링(GetTask 반복 호출), 스트리밍(실시간 이벤트, `streaming` capability 필요), 푸시 알림(서버가 클라이언트 웹훅으로 HTTP POST, `pushNotifications` capability 필요) 세 가지를 지원한다. 푸시 알림은 최소 한 번(at least once) 전달을 보장하므로 클라이언트가 중복 수신을 처리해야 한다.
- **전송 바인딩** — 같은 작업 모음을 JSON-RPC, gRPC, HTTP+JSON(REST) 세 가지 중 어느 것으로 구현해도 되며, 데이터 모델 자체는 `a2a.proto`로 정의된다.

## 트레이드오프

- 벤더·프레임워크가 달라도 같은 프로토콜로 통신할 수 있게 되지만, 그만큼 Agent Card·Task 상태 기계·세 가지 전송 바인딩을 전부 구현하는 비용이 서버 쪽에 생긴다.
- 폴링은 구현이 가장 단순하지만 지연이 크고, 스트리밍·푸시 알림은 실시간성을 얻는 대신 해당 capability 지원 여부를 Agent Card로 미리 확인하고 중복 전달 같은 예외를 처리해야 한다.

## 주의사항

- 운영 환경에서는 통신을 반드시 암호화해야 한다(HTTPS 또는 gRPC의 TLS). 클라이언트는 서버의 TLS 인증서를 검증해야 한다.
- `AUTH_REQUIRED` 상태는 클라이언트에게 인증 절차를 넘기는 신호일 뿐, 그 상태 자체가 어떤 작업에 대한 인가를 주는 것은 아니다. 인가 판단은 프로토콜이 아니라 구현(서버) 쪽 책임이다.
- 버전은 `Major.Minor` 단위로 식별하고(패치 번호는 호환성에 영향을 주지 않는다), 클라이언트가 요청한 버전을 서버가 지원하지 않으면 오류를 돌려준다. 최신 릴리스는 1.0.0이다.

## 핵심 정리

- A2A는 에이전트 둘 이상이 서로의 내부 상태를 공유하지 않고도 작업을 주고받게 하는 수평 연결 프로토콜로, [[MCP]]의 수직 연결(에이전트-툴)과 역할이 다르다
- 서버는 Agent Card로 자신의 접속 정보·capabilities·skills를 알리고, 클라이언트는 `/.well-known/agent-card.json` 등으로 이를 찾는다
- Task는 SUBMITTED에서 시작해 종료 상태(COMPLETED 등) 또는 대기 상태(INPUT_REQUIRED 등)로 이어지는 상태 기계로 관리된다
- 진행 상태는 폴링·스트리밍·푸시 알림 중 서버가 지원하는 방식으로 전달되고, 전송은 JSON-RPC·gRPC·HTTP+JSON 중 하나로 구현된다

## 참고

- [A2A 공식 스펙, a2aproject/A2A](https://github.com/a2aproject/A2A/blob/main/docs/specification.md)
