---
title: "AP2"
tags: [AI에이전트, 툴과프로토콜, 결제]
status: published
---

에이전트가 사용자를 대신해 결제할 때, 사용자가 서명한 권한 위임장(Mandate)으로 그 에이전트가 할 수 있는 거래 범위를 암호학적으로 한정하는 프로토콜이다.
기준 시점: 2026-11

## 왜 필요한가

AP2 공식 문서는 기존 결제 프로토콜이 "사람이 신뢰된 인터페이스를 통해 직접 행동한다"고 전제한다고 짚는다. 에이전트가 대신 거래하는 상황에서는 이 전제가 깨지는데, 기존 프로토콜에는 "에이전트의 신원과 거래 권한을 안전하게 검증할 메커니즘이 없다"는 것이다. 공통 표준이 없으면 가맹점마다 제각각인 해법이 생겨 가맹점 부담이 커지고 사기 위험을 평가하기도 어려운 "분절되고 불안전한 생태계"가 된다고 설명한다. AP2는 이런 상황에서 에이전트가 거래할 권한이 실제로 있는지, 사용자가 의도한 범위를 넘지 않았는지, 문제가 생겼을 때 책임을 누가 지는지를 프로토콜 수준에서 증명할 수 있게 만드는 걸 목표로 한다.

## 핵심 개념 — Mandate

AP2의 권한 위임 단위는 **Mandate**(위임장)다. 사용자나 신뢰된 주체가 서명한, 검증 가능한 디지털 자격증명(Verifiable Digital Credential)의 한 형태로, 두 단계로 나뉜다.

- **Open Mandate** — 아직 특정 거래에 묶이지 않은 상태. 허용 가맹점, 품목처럼 "앞으로 생길 거래가 지켜야 할 제약조건"을 담는다. 특정 에이전트의 공개키를 `cnf`(confirmation) 클레임으로 미리 지정해, 그 에이전트만 이 위임장을 쓸 수 있게 묶어둔다.
- **Closed Mandate** — 실제 거래 한 건에 묶인 상태. 에이전트가 자신의 키로 Key Binding JWT를 만들어 "내가 그 공개키의 소유자"임을 증명하고, 위임장을 그 거래 하나에 고정한다.

거래가 실제로 진행되는 단계에서는 두 가지 구체적인 Mandate가 쓰인다.

- **Checkout Mandate** — 가맹점에게 "이 에이전트가 이 Checkout(장바구니)을 살 권한이 있다"는 암호학적 증거를 준다. 가맹점은 서명된 Checkout JWT를 발급하고, 닫힌 Checkout Mandate는 해시로 그 JWT에 묶인다.
- **Payment Mandate** — Credential Provider·결제망·가맹점 결제대행사(MPP)에게 "이 에이전트가 이 Checkout에 대해 결제할 권한이 있다"는 증거를 준다. 역시 Checkout JWT에 해시로 묶인다.

## 역할

AP2는 다섯 가지 역할을 정의하고, 한 주체가 여러 역할을 겸할 수 있다고 본다.

```
사용자 ──(동의)──▶ Trusted Surface ──(서명된 Mandate)──▶ Shopping Agent
                                                              │
                                      ┌───────────────────────┼───────────────────────┐
                                      ▼                        ▼                       ▼
                               Credential Provider          Merchant            Merchant Payment
                               (결제 자격증명 보관)      (Checkout 제공)         Processor(결제 처리)
```

- **Shopping Agent(SA)** — 상품을 탐색하고 Checkout을 구성해 실제로 구매를 실행하는 주 에이전트.
- **Credential Provider(CP)** — 디지털 지갑처럼 사용자의 결제·신원 자격증명을 관리하고, 에이전트가 그 자격증명에 접근할 권한이 있는지 확인한다.
- **Merchant(판매자)** — Checkout을 제공·완료하고, 에이전트가 해당 품목을 살 권한이 있는지 확인하며, 재고·가격·할인 정보의 무결성을 지킨다.
- **Merchant Payment Processor(MPP)** — 결제를 처리하고, 자격증명이 이 Checkout에 대해 정당하게 승인됐는지 검증한다.
- **Trusted Surface(TS)** — 사용자의 동의를 받아 사용자가 서명한 Mandate를 만들어내는 UI. 반드시 비(非)에이전틱해야 한다 — 즉 에이전트가 이 UI를 대신 조작할 수 없다.

## 동작 과정 — Human Present vs Human Not Present

```
[Human Present(직접 승인)]
사용자 → (닫힌 Checkout·결제 내역을 직접 보고 승인) → Trusted Surface가 Mandate에 서명
       → Shopping Agent는 그 Mandate를 그대로 전달만 한다

[Human Not Present(자율 결제)]
사용자 → (지출 범위·조건을 담은 Open Mandate에 서명, 1회) → Shopping Agent 보관
       → 이후 거래마다: Shopping Agent가 자기 키로 Closed Mandate를 만들어 서명
       → 거부 영수증을 받기 전에는 같은 Open Mandate로 새 요청을 또 보낼 수 없다
```

Human Present 모드에서는 사용자가 매 거래마다 닫힌 Checkout과 결제 내역을 직접 보고 명시적으로 승인한다. Human Not Present(자율 결제) 모드에서는 사용자가 제약조건이 담긴 Open Mandate에 한 번 서명해두면, 에이전트가 그 범위 안에서 스스로 거래마다 Closed Mandate를 만들어 서명한다. 이때 Open Mandate는 에이전트의 공개키를 `cnf` 클레임으로 반드시 포함해야 하고, 만료 시각(`exp`)은 작업에 필요한 만큼 짧게 잡아야 한다고 명시한다.

## 트레이드오프

- Human Not Present 모드는 사람이 매번 개입하지 않아도 되는 자율성을 주지만, 그 대가로 "서명 시점의 제약조건"과 "실제 거래 시점의 상황"이 벌어질 위험을 감수해야 한다. 짧은 만료 시각과 품목·가맹점 제약이 이 틈을 좁히는 장치다.
- Mandate 체계는 분쟁이 생겼을 때 Checkout Mandate·Payment Mandate와 그 영수증을 묶어 "누가 무엇을 승인했는지" 부인할 수 없는 기록을 남길 수 있지만, 그 대신 모든 단계에서 서명·해시 바인딩·검증 로직을 구현해야 하는 복잡도를 가맹점·결제사·에이전트 양쪽에 요구한다.

## 주의사항

- Checkout JWT는 ECDSA 같은 디지털 서명 방식으로 서명해야 하고 결정론적 서명은 금지된다 — 레인보우 테이블 공격을 막기 위해서다.
- 검증자는 에이전틱 역할을 잠재적 공격자로 간주하고 변조 감지 메커니즘을 반드시 둬야 한다. 알 수 없는 제약조건(Constraint)은 전부 검증 실패로 처리해야 한다.
- 각 Mandate 스키마는 `vct` 클레임으로 자기 종류와 버전을 식별한다(예: `mandate.payment.1`). 구현체는 버전 접미사까지 포함해 정확히 일치하는 `vct` 문자열만 받아들여야 하며, 이후 호환되지 않는 개정이 나오면 `.2`처럼 접미사가 바뀐다.
- AP2는 [[A2A]]·[[MCP]]의 확장으로 설계되었고 Universal Commerce Protocol(UCP)과도 호환되도록 만들어졌다 — 즉 AP2 자체는 상품 탐색이나 통신 방식을 규정하지 않고, 그 위에서 결제 권한만 보안한다.
- 체크리스트에 적힌 대로 AP2는 v0.2 버전이며 2026년 4월 FIDO Alliance로 이관되었다고 알려져 있다. 이 이관 경위는 이번 조사에서 1차 문서로 재확인하지 못해 기존 기록을 그대로 따랐다.

## 핵심 정리

- AP2는 "사용자가 서명한 Mandate로 에이전트의 결제 권한을 암호학적으로 한정"하는 프로토콜이고, Mandate는 아직 거래에 묶이지 않은 Open 상태와 거래 하나에 고정된 Closed 상태로 나뉜다
- 역할은 Shopping Agent·Credential Provider·Merchant·Merchant Payment Processor·Trusted Surface 다섯 가지이고, Trusted Surface는 반드시 비에이전틱해야 한다
- Human Present(매 거래 직접 승인)와 Human Not Present(제약조건부 위임 후 자율 결제) 두 모드가 있고, 후자는 공개키 바인딩과 짧은 만료 시각으로 위험을 줄인다
- Mandate는 SD-JWT로 서명되고 해시로 서로 묶여, 분쟁 시 부인할 수 없는 거래 기록이 된다

## 참고

- [AP2 공식 스펙 (google-agentic-commerce/AP2, docs/ap2/specification.md)](https://github.com/google-agentic-commerce/AP2/blob/main/docs/ap2/specification.md)
- [AP2 Agent Authorization Framework (docs/ap2/agent_authorization.md)](https://github.com/google-agentic-commerce/AP2/blob/main/docs/ap2/agent_authorization.md)
- [AP2 Overview (docs/overview.md)](https://github.com/google-agentic-commerce/AP2/blob/main/docs/overview.md)
- [AP2 Glossary (docs/glossary.md)](https://github.com/google-agentic-commerce/AP2/blob/main/docs/glossary.md)
