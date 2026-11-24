---
title: 앤트로픽의 Enterprise Frontier Safeguards 베타 공개
tags: [AI소식, 데이터보존, 암호화, 안전장치]
status: published
---

앤트로픽이 데이터 보존이 필요한 최상위 모델을 제로 데이터 리텐션(ZDR)으로 쓸 수 있게, 안전 모니터링용 데이터를 고객의 클라우드 버킷에 봉인해 두는 Enterprise Frontier Safeguards(EFS)를 베타로 공개했다.

기준 시점: 2026-11-23

## 무슨 일인가

- 11월 23일 Claude Platform 릴리스 노트에 EFS 베타가 올라왔다. Claude Platform, Claude Platform on AWS, Claude Models on Google Cloud(Anthropic managed)에서 쓸 수 있다. 같은 날 Claude Opus 4.5의 지원 종료 예고(API 종료 2027-01-22)도 함께 나왔다.
- **배경은 "보존이 필요한 모델"과 ZDR의 충돌이다.** 같은 릴리스 노트에 따르면 Claude Fable 5.2·Mythos 5.2는 30일 데이터 보존이 필요하고, Anthropic이 따로 허가하지 않으면 ZDR로는 쓸 수 없다. FAQ에도 기존 방식(Legacy ZDR) 워크스페이스에서 이런 모델을 부르면 400 오류가 난다고 적혀 있다.
- **EFS의 답은 "보존은 하되 Anthropic이 아니라 고객 쪽에"다.** 문서는 EFS를 "Anthropic이 프롬프트와 응답을 보존하지 않는 ZDR"이라고 정의한다. 대신 프롬프트·응답·모델 추론을 Anthropic 형식으로 암호화한 **Sealed Safety Data**가 고객이 소유한 버킷(S3 또는 Google Cloud Storage)에 쓰인다. 고객 팀은 자기 버킷에 있어도 이 데이터를 읽을 수 없고, 자동 안전 모니터링만 쓴다고 밝혔다.
- **버킷에 들어가는 것은 세 종류다.** 읽을 수 없는 Sealed Safety Data, 고객 팀이 읽을 수 있는 사본인 Transcript, 그리고 Safety Case·Safety Notice·고객의 답변을 묶은 Safety Correspondence다. Safety Case는 자동 모니터링이 이용 정책 위반 가능성을 찾았을 때 열리는 기록인데, 프롬프트나 응답 자체는 담지 않고 관련 Transcript를 식별자로만 가리킨다.
- **사람 검토는 고객 쪽으로 넘어간다.** EFS에서는 Anthropic Human Review가 항상 꺼져 있고, 자동 모니터링이 찾은 사례를 고객 조직의 사람이 검토한다. 고객이 자체 분류기를 추가할 수는 없다고 FAQ에 적혀 있다.
- **보존 기한과 실패 처리가 정해져 있다.** Sealed Safety Data는 요청 후 최대 28일 동안 버킷에 남는다. Anthropic이 버킷에 쓰지 못하면 최대 24시간의 유예 기간 동안은 요청이 계속 처리되고, 그 뒤에는 거부될 수 있다. 쓰지 못한 데이터는 Anthropic 저장소로 대신 보내지 않고, Claude Platform에서는 요청 후 약 72시간에 지운다. 버킷이 하루 한 번 점검에 실패하면 `external_storage.failed` 웹훅이, 다시 통과하면 `external_storage.recovered`가 온다.
- **고객 관리형 키(CMEK)를 함께 쓸 수 있다.** AWS KMS, Google Cloud KMS, Azure Key Vault의 키를 워크스페이스에 붙이면 Anthropic은 그 키로 데이터를 암호화하고, 키를 끄면 약 1시간 안에 Anthropic도 그 데이터를 복호화할 수 없게 된다. 버킷과 함께 쓰면 키가 둘이 된다. Sealed Safety Data는 먼저 고객 관리형 키로 암호화된 뒤 저장소가 버킷 키로 한 번 더 암호화하며, 문서는 두 키를 같은 것으로 쓰지 말라고 한다. 키를 붙이는 것은 되돌릴 수 없어서, 다른 키를 쓰려면 새 워크스페이스를 만들어야 한다.
- **범위의 경계도 문서에 적혀 있다.** EFS는 워크스페이스 단위로 켜지고, 켜지면 그 워크스페이스의 모든 모델 요청에 적용된다. Messages API 요청이 대상이고, 코드 실행 컨테이너·Files API·Batch API 결과·Managed Agents 세션처럼 기능이 자체적으로 저장하는 데이터는 포함하지 않는다. Batch API는 검토할 Transcript가 남지 않아 지원하지 않고, Managed Agents는 Human Review가 꺼진 워크스페이스에서 세션을 돌리지 않는다고 밝혔다. Anthropic은 EFS에 요금을 받지 않지만 버킷의 저장·읽기·쓰기 비용은 고객 클라우드에서 나간다.

## 왜 중요한가

지금까지 ZDR은 "아무것도 남기지 않는다"였고, 안전 모니터링을 하려면 공급자가 데이터를 가지고 있어야 했다. 강한 모델일수록 오남용 감시가 필요해 보존을 요구하게 되면서, 규제 산업처럼 데이터를 밖에 둘 수 없는 조직은 최상위 모델을 쓰지 못하는 구조였다. EFS는 이 둘을 "데이터는 고객 소유 저장소에, 읽을 권한은 암호로 봉인"하는 방식으로 갈라놓았다.

만드는 입장에서 달라지는 점은 세 가지다.

- **워크스페이스 설계가 데이터 정책이 된다.** EFS는 워크스페이스 전체에 걸리고, Batch API와 Managed Agents는 그 안에서 쓸 수 없다. 민감한 트래픽과 배치·에이전트 트래픽을 API 키 단위로 다른 워크스페이스에 나눠야 한다.
- **내 버킷이 장애 지점이 된다.** 버킷 권한을 잘못 바꾸거나 키 관리 서비스가 멈추면 유예 시간 뒤에 모델 요청이 실패한다. 웹훅으로 버킷·키 상태를 감시하는 것이 운영 항목에 들어간다.
- **안전 검토 인력이 고객 쪽에 필요해진다.** Safety Case를 받아 조사하고 답변을 버킷에 쓰는 일을 조직 안의 누군가가 맡아야 한다.

## 짚고 갈 개념

- 제로 데이터 리텐션(ZDR) — API 요청·응답을 공급자 서버에 남기지 않는 정책. EFS는 보존이 필요한 데이터를 고객 저장소로 옮겨 ZDR의 정의를 유지했다
- 고객 관리형 키(CMEK) — 고객의 키 관리 서비스에 둔 키로 공급자가 데이터를 암호화하게 해, 키를 끄는 것만으로 공급자의 접근을 끊는 방식. 저장소 자체의 키와 겹쳐 두 겹으로 암호화한다
- [[공개키]]·[[대칭키]] 암호화 — 키를 누가 가지고 있느냐가 곧 누가 읽을 수 있느냐를 정한다는 점이 이번 설계의 바탕이다

## 내 생각

"보존 의무가 있는 데이터를 고객이 소유하되 고객도 못 읽게 한다"는 구조가 눈에 띈다. 저장 위치의 통제권과 열람 권한을 분리한 것인데, 클라우드에서 흔히 보는 CMEK보다 한 단계 더 간 형태로 보인다. 다만 봉인된 데이터를 누가 어떤 조건에서 복호화하는지는 이번에 읽은 문서 범위에서는 자세히 나오지 않아, 신뢰의 근거가 암호 기술보다 계약과 Access Transparency 기록 쪽에 더 기대고 있는 것으로 보인다.

[[앤트로픽의 Managed Agents 전체 셀프호스팅 공개]], [[앤트로픽의 OpenTelemetry 트레이싱 베타 공개]]와 함께 보면, 하네스·관측·안전 데이터까지 "고객 환경에 두는" 선택지를 차례로 넓히는 흐름으로 읽힌다. 반대로 EFS 워크스페이스에서는 Managed Agents를 못 쓰는 등 기능끼리 아직 맞물리지 않는 부분이 있어, 베타 동안 이 경계가 바뀔 가능성이 커 보인다.

## 출처

- https://platform.claude.com/docs/en/release-notes/overview
- https://platform.claude.com/docs/en/manage-claude/enterprise-frontier-safeguards/overview
- https://platform.claude.com/docs/en/manage-claude/enterprise-frontier-safeguards/customer-owned-storage
- https://platform.claude.com/docs/en/manage-claude/enterprise-frontier-safeguards/customer-managed-keys
- https://platform.claude.com/docs/en/manage-claude/enterprise-frontier-safeguards/faq
