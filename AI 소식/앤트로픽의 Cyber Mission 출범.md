---
title: 앤트로픽의 Cyber Mission 출범
tags: [AI소식, 보안, 오픈소스]
status: published
---

앤트로픽이 중요 인프라와 오픈소스 소프트웨어의 보안을 방어자 쪽에서 지원하는 장기 이니셔티브 Cyber Mission을 발표했다.
기준 시점: 2026-10-08

## 무슨 일인가

- 10월 8일 발표. 두 축으로 구성된다.
- **Critical Infrastructure Defense Program(CIDP)** — 전력망·상하수도·공장·교통망 같은 운영기술(OT)과 정부 시스템을 보안하는 신뢰받는 공급업체에 Claude 프론티어 모델, 현장 엔지니어, 위협 연구를 제공한다. OT는 수십 년간 운영되는 독점 장비가 많아 변경 위험이 크고, 취약점이 수년간 방치되는 경우가 있다고 설명한다. 초기 파트너 11곳은 Accenture, Booz Allen, CrowdStrike, Deloitte, Dragos, Hitachi, Insane Cyber, Nozomi Networks, Palo Alto Networks, PwC, Rockwell Automation이다.
- **OSS Scanner** — Google의 OSS-Fuzz에서 영감을 받은 옵트인(opt-in) 서비스. 신청한 오픈소스 프로젝트를 최상위 모델이 주기적으로 스캔해, 취약점을 보여주는 개념 증명(PoC)·설명·가능하면 수정안까지 담은 리포트를 만든다. 이 리포트는 **사람 검토 없이** 메인테이너에게 발송되며, 앤트로픽은 진양성(true positive) 비율을 90% 이상으로 예상한다고 밝혔다. 처리 역량이 부족한 프로젝트에는 기존처럼 사람이 검증한 취약점 공개 절차를 계속 제공한다.
- 배경에는 이전 프로젝트 Glasswing의 경험이 있다. Glasswing 참여 파트너들은 취약점을 많이 찾아냈지만, 찾은 취약점을 검증·우선순위화·수정하는 일은 여전히 어렵다는 교훈을 얻었고, Glasswing 자체는 이번 발표 직전 확대된 Cyber Verification Program(CVP)에 통합됐다.
- 8월에 출범한 Defender Advantage Fund(0xDAF)가 OSS Scanner를 무료로 유지하는 재원을 댄다. Python Software Foundation, Linux Foundation 산하 Alpha-Omega·OpenSSF, Apache Software Foundation도 지원 대상이다.

## 왜 중요한가

앤트로픽은 발표문에서 사이버 공격에 쓸 수 있는 고성능 AI 모델은 이미 널리 퍼졌지만, 방어 쪽 도구(앤트로픽 자체 도구 포함)는 방어가 필요한 조직에 아직 충분히 도달하지 못했다고 짚었다. 공격 비용은 낮아졌는데 취약점의 검증·공개·수정은 여전히 사람 속도에 머무는 비대칭을, 리포트를 사람 검토 없이 바로 보내는 쪽으로 풀어본 사례다. 속도를 얻는 대신 오탐(false positive)을 메인테이너가 직접 걸러내야 하는 비용을 지는 트레이드오프이기도 하다.

OT 영역은 패치 주기가 수년 단위로 길어서, 모델을 붙인다고 당장 해결되는 문제가 아니라는 점도 발표문이 스스로 인정하고 있다. 성공의 기준도 "취약점이 전부 사라진다"가 아니라 "침투해도 필수 인프라가 계속 작동하고 복구가 빨라진다"로 잡았다.

## 짚고 갈 개념

- 퍼징(Fuzzing) — OSS Scanner가 본뜬 Google OSS-Fuzz 방식의, 무작위·변형 입력으로 소프트웨어 취약점을 자동으로 찾는 테스트 기법
- CVD(Coordinated Vulnerability Disclosure) — 처리 역량이 부족한 프로젝트에 계속 적용하기로 한, 사람이 검증한 뒤 공개하는 책임있는 취약점 공개 절차

## 내 생각

진양성 90%를 "예상"이라고만 밝힌 점이 눈에 띈다. 나머지 오탐을 메인테이너가 걸러내는 비용을 누가 지는지가 이 서비스의 실제 성공 여부를 가를 것으로 보인다. CIDP처럼 사람이 반드시 끼는 영역과 OSS Scanner처럼 속도를 우선한 영역을 나눠 설계한 점이, AI 보안 도구를 어디까지 믿고 맡길지 판단하는 하나의 기준점이 될 수 있어 보인다.

## 출처

- https://www.anthropic.com/news/anthropic-cyber-mission
