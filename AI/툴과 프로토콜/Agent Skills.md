---
title: "Agent Skills"
tags: [AI에이전트, 툴과프로토콜]
status: published
---

에이전트에게 특정 작업의 절차적 지식을 `SKILL.md` 폴더 단위로 담아 필요할 때만 불러오게 하는 개방형 포맷이다.
기준 시점: 2026-11

## 왜 필요한가

공식 리드미는 "에이전트는 점점 더 능력이 좋아지고 있지만, 실제 업무를 안정적으로 해내기 위한 맥락이 자주 부족하다"고 짚는다. [[함수 호출]]이나 [[MCP]]가 "에이전트가 외부 기능·데이터에 어떻게 접근하는가"를 표준화한다면, Agent Skills는 그와는 다른 축인 "이 작업을 어떤 절차로 처리해야 하는지"를 표준화한다. 절차적 지식·회사·팀·사용자별 맥락을 버전 관리되는 폴더로 포장해, 에이전트가 필요할 때만 불러 쓰게 하는 것이 목적이다.

## 구조

스킬 하나는 `SKILL.md` 파일을 반드시 포함하는 디렉터리다.

```
skill-name/
├── SKILL.md          # 필수: 메타데이터 + 지침
├── scripts/          # 선택: 실행 가능한 코드
├── references/       # 선택: 추가 문서
├── assets/           # 선택: 템플릿·리소스
└── ...               # 그 외 임의의 파일·디렉터리
```

`SKILL.md`는 YAML 프런트매터 다음에 마크다운 본문이 오는 구조다. 프런트매터 필드는 다음과 같다.

| 필드 | 필수 | 제약 |
|---|---|---|
| `name` | O | 최대 64자. 소문자·숫자·하이픈만 허용, 하이픈으로 시작·끝 불가, 연속 하이픈 불가, 부모 디렉터리 이름과 일치해야 함 |
| `description` | O | 최대 1024자, 비어 있으면 안 됨. 무엇을 하는 스킬인지와 언제 써야 하는지를 설명 |
| `license` | X | 라이선스 이름 또는 동봉된 라이선스 파일 참조 |
| `compatibility` | X | 최대 500자. 특정 제품·시스템 패키지·네트워크 접근 같은 환경 요구사항 |
| `metadata` | X | 문자열 키-값 맵. 스펙이 정의하지 않은 추가 속성을 담는 용도 |
| `allowed-tools` | X | 공백으로 구분한, 사전 승인된 툴 목록. 실험적 필드로 구현체마다 지원이 다를 수 있음 |

본문에는 형식 제약이 없고, 단계별 지침·입출력 예시·흔한 엣지 케이스 같은 내용을 담도록 권장한다.

## 동작 과정 — Progressive Disclosure

에이전트는 스킬을 한 번에 전부 읽지 않고, 작업에 필요한 만큼만 단계적으로 불러온다.

```
1단계 Discovery (시작 시, ~100 토큰)
   모든 스킬의 name·description만 메모리에 올려둔다
          │
          ▼  작업이 어떤 스킬의 description과 맞아떨어지면
2단계 Activation (활성화 시, 500줄/5000토큰 권장 이하)
   해당 스킬의 SKILL.md 본문 전체를 읽어 지침을 따른다
          │
          ▼  지침이 스크립트·참고 문서를 가리키면
3단계 Execution (필요할 때만)
   scripts/ 를 실행하거나 references/ · assets/ 를 그때 읽는다
```

이렇게 나누는 이유는, 스킬을 아무리 많이 등록해 두어도 시작 시점에는 이름·설명 정도의 작은 컨텍스트만 차지하게 하기 위해서다. 스펙은 `SKILL.md` 본문을 500줄 이하로 유지하고, 상세 내용은 `references/` 폴더의 별도 파일로 분리하도록 권장한다. 파일을 서로 참조할 때도 `SKILL.md`에서 한 단계 깊이까지만 참조하도록 권장해, 참조가 참조를 부르는 깊은 체인을 피하게 한다.

## 트레이드오프

- Discovery 단계가 가볍다는 것은 거꾸로 "description이 얼마나 잘 쓰였는가"에 활성화 여부가 전부 걸려 있다는 뜻이다. description이 모호하면(공식 스펙이 드는 나쁜 예: "Helps with PDFs.") 필요한 순간에 에이전트가 그 스킬을 찾아 쓰지 못한다.
- 폴더 하나로 이식 가능하다는 장점은, `allowed-tools`처럼 아직 실험적인 필드의 지원이 구현체마다 달라 "같은 스킬이 모든 에이전트에서 똑같이 동작하지는 않는다"는 한계와 맞물려 있다.

## 주의사항

- `name`은 소문자·숫자·하이픈만 허용되고 부모 디렉터리 이름과 반드시 일치해야 한다. 대문자(`PDF-Processing`), 하이픈으로 시작(`-pdf`), 연속 하이픈(`pdf--processing`)은 전부 무효다.
- Agent Skills는 Claude Code를 만들며 앤트로픽이 다진 개념에서 출발해 개방형 표준으로 공개된 뒤, [[MCP]]에 이어 Agentic AI Foundation(AAIF)에 기부됐다 — [[앤트로픽의 Agent Skills 오픈 표준 기부]].
- MCP와는 별도 축이지만 서로 배타적이지 않다. MCP 스펙의 옵트인 확장 중 하나인 **Skills over MCP**는 MCP 서버를 통해 스킬을 찾아 쓰는 구조화된 지침을 제공한다 — 즉 "스킬을 어떻게 패키징하는가"(Agent Skills)와 "그 스킬을 어떻게 찾아 전달하는가"(MCP)가 결합될 수 있다.
- 공식 참조 라이브러리 `skills-ref`로 프런트매터 유효성과 네이밍 규칙을 검증할 수 있다(`skills-ref validate ./my-skill`).

## 핵심 정리

- 스킬은 `SKILL.md`(필수) + `scripts/`·`references/`·`assets/`(선택)로 구성된 폴더이고, `name`·`description`이 유일한 필수 프런트매터 필드다
- Discovery(이름·설명만) → Activation(SKILL.md 본문 전체) → Execution(필요한 리소스만)의 3단계 Progressive Disclosure로 컨텍스트 사용량을 억누른다
- MCP가 "외부 기능·데이터 접근"을 표준화한다면 Agent Skills는 "작업 절차 지식을 어떻게 패키징·로드하는가"를 표준화하며, Skills over MCP로 두 축이 결합될 수 있다

## 참고

- [Agent Skills README (agentskills/agentskills)](https://github.com/agentskills/agentskills/blob/main/README.md)
- [Agent Skills Specification (agentskills/agentskills, docs/specification.mdx)](https://github.com/agentskills/agentskills/blob/main/docs/specification.mdx)
