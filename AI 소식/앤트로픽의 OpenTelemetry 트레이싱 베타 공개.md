---
title: 앤트로픽의 OpenTelemetry 트레이싱 베타 공개
tags: [AI소식, 관측, 트레이싱]
status: published
---

앤트로픽이 Messages API 요청과 Managed Agents 세션을 OpenTelemetry 스팬으로 내보내 기존 관측 플랫폼에서 볼 수 있게 하는 기능을 베타로 공개했다.

기준 시점: 2026-10-14

## 무슨 일인가

- 10월 14일 Claude Platform 릴리스 노트에 OpenTelemetry export 베타가 올라왔다. SDK는 Python, TypeScript, C#, Go, Java, PHP, Ruby에서 스팬을 낸다.
- **스팬의 출처가 두 갈래다.** 내 애플리케이션 안의 SDK가 내는 클라이언트 스팬과, Claude API 서버가 내는 서버 스팬이다. 서버 스팬을 받으려면 관리자가 Claude Console에서 *destination*(내 관측 플랫폼의 OTLP/HTTP 엔드포인트와 인증 헤더)을 등록한다. 코드는 바꾸지 않아도 된다.
- **둘은 보이는 범위가 다르다.** 문서 표에 따르면 한 요청 안에서 모델이 여러 번 돈 각 실행, API가 직접 돌리는 서버 툴, Managed Agents의 턴은 API 쪽 스팬에만 있다. 반대로 툴 러너가 내 쪽에서 돌리는 클라이언트 툴과 셀프호스팅 샌드박스 안의 툴은 SDK 쪽에만 있다. 둘 다 켜야 한 요청이 한 트레이스로 이어진다.
- **기존 트레이스에 이어 붙는다.** API는 요청의 W3C `traceparent` 헤더에서 트레이스 컨텍스트를 읽는다. 내 서비스의 스팬 안에서 SDK를 호출하면 "내 스팬 → SDK 스팬 → API 스팬"으로 중첩된다. MCP 커넥터를 쓰면 API가 `tools/call` 요청의 `params._meta`에 `traceparent`를 실어 MCP 서버까지 트레이스를 넘긴다. 헤더의 sampled 플래그가 꺼져 있으면 API는 그 요청의 스팬을 내지 않는다.
- **속성 이름은 OpenTelemetry의 GenAI 시맨틱 컨벤션을 따른다.** 시스템 프롬프트는 `gen_ai.system_instructions`, 입력은 `gen_ai.input.messages`, 출력은 `gen_ai.output.messages`에 담긴다. 규약을 지원하는 플랫폼은 추가 설정 없이 스팬을 알아본다고 문서는 밝혔다.
- **내용 모드가 둘이다.** 기본값인 Metadata only는 식별자·타이밍·상태·토큰 수만 담고, Full content는 프롬프트와 응답까지 담는다. Full content의 스팬당 기본 한도는 0.75 MB이고, 넘으면 시스템 프롬프트와 가장 오래된 메시지부터 잘라내며 `anthropic.content.truncated`를 `true`로 둔다. HIPAA·FERPA·K-12 데이터 처리 제한이 있는 조직은 설정과 관계없이 메타데이터만 나간다. 제로 데이터 리텐션 조직도 Full content를 쓸 수 있고, 이때 Messages API의 내보낼 내용은 전달될 때까지 메모리에만 둔다고 한다.
- **전달은 "최소 한 번, 최선 노력"이다.** 같은 스팬이 두 번 올 수 있으니 트레이스 ID와 스팬 ID로 중복을 지우라고 하고, 전달 전에 잃어버린 스팬은 다시 보내지 않는다. 3xx 리다이렉트를 받거나 24시간 동안 모든 전달이 실패하면 destination을 비활성화하고, 그동안의 스팬은 버린다.

## 왜 중요한가

[[트레이싱과 관측]]에서 정리했듯 에이전트는 재현으로 디버깅하기 어렵고, 실행 시점에 남긴 궤적이 거의 유일한 단서다. 지금까지는 그 궤적을 내 코드에서 직접 계측해야 했고, API 안에서 벌어지는 일(서버 툴 실행, 한 요청 안의 여러 모델 호출, Managed Agents 턴)은 블랙박스였다. 이번 기능은 그 안쪽을 표준 형식의 스팬으로 꺼내 내 서비스 트레이스 밑에 붙여준다.

만드는 입장에서 달라지는 점은 세 가지다.

- **"느리다"를 어디서 느린지로 바꿀 수 있다.** 내 API 서버 → SDK → 모델 호출 → 웹 검색 → 다음 모델 호출이 한 트레이스에 시간 순서대로 찍힌다.
- **토큰 집계에 규칙이 생긴다.** 같은 사용량이 여러 단계 스팬에 반복해서 붙기 때문에, 문서는 요청마다 한쪽 출처만 더하라고 한다. SDK 스팬과 API 스팬이 둘 다 있으면 API 스팬만 더하고(둘 다 `anthropic.messages.create`라서 `CLIENT`/`SERVER` 종류로 구분한다), 전달이 최선 노력이라 스팬이 빠질 수 있으니 과금·키 유출 추적에는 별도의 사용량 API를 쓰라고 못 박았다.
- **관측 데이터가 곧 민감 데이터가 된다.** Full content를 켜면 프롬프트와 툴 결과가 회사 밖 관측 플랫폼의 보존·접근 정책 아래로 넘어간다. 문서도 그 플랫폼의 설정이 조직 요건에 맞는지 확인하라고 경고한다.

## 짚고 갈 개념

- [[분산 추적]] — 트레이스 ID와 부모 스팬 ID를 헤더로 넘겨 서비스 경계를 넘어 한 요청을 잇는 기법. 이번 기능은 그 경계를 Claude API와 MCP 서버까지 넓혔고, 전파 헤더로 W3C `traceparent`를 쓴다
- 메시지 전달 보장 — 최대 한 번·최소 한 번·정확히 한 번 중 무엇을 약속하느냐에 따라 받는 쪽이 중복 제거나 유실을 감당해야 하는 문제. 이번 스팬 전달은 최소 한 번이라 ID 기반 중복 제거가 필요하다
- 제로 데이터 리텐션(ZDR) — API 요청·응답을 서버에 남기지 않는 정책. 내보내기와 충돌할 것 같지만, 메모리에만 들고 있다 전달하는 방식으로 함께 쓰게 했다

## 내 생각

기본값을 Metadata only로 둔 것은 관측 플랫폼이 새로운 유출 경로가 될 수 있다는 점을 의식한 선택으로 보인다. 실무에서는 평소 메타데이터만 받다가, 평가셋을 만들거나 장애를 조사할 때만 일부 워크스페이스에 Full content를 켜는 식으로 쓰게 될 것 같다.

[[앤트로픽의 Managed Agents 전체 셀프호스팅 공개]]에서 OpenTelemetry 내보내기를 보안 원칙 중 하나로 꼽은 것과 이어지는 흐름으로 읽힌다. 하네스를 어디서 돌리든 관측은 고객의 기존 도구로 모으겠다는 방향이 굳어지는 것으로 보인다. 다만 전달이 최선 노력이라, 트레이스를 감사 기록처럼 믿는 것은 위험해 보인다. 문서가 사용량 집계를 별도 API로 하라고 한 것도 같은 이유일 것이다.

## 출처

- https://platform.claude.com/docs/en/release-notes/overview
- https://platform.claude.com/docs/en/manage-claude/opentelemetry
- https://platform.claude.com/docs/en/manage-claude/opentelemetry/api
