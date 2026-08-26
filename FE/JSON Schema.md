---
title: "JSON Schema"
tags: [JSONSchema, 데이터검증, TypeScript]
status: published
---

JSON 데이터가 가져야 할 구조(타입, 필수 속성, 형식 등)를 기술하고 검증하기 위한 명세서입니다.

## 핵심 특징

- JSON 데이터의 속성 이름, 타입, 필수 여부, 형식(`format`) 등을 선언적으로 정의
- 명세 자체가 JSON 형식이라 다양한 언어·툴체인에서 파싱하고 검증기로 활용 가능
- `additionalProperties: false` 등으로 정의되지 않은 속성을 허용하지 않도록 강제 가능

## 예시

```json
{
  "type": "object",
  "properties": {
    "username": { "type": "string", "minLength": 3 },
    "email": { "type": "string", "format": "email" },
    "password": { "type": "string", "minLength": 6 }
  },
  "required": ["username", "email", "password"],
  "additionalProperties": false
}
```

## 활용 사례

- **API 응답 검증**: 백엔드가 내려주는 데이터의 속성·타입·필수 여부를 명세하면, 프론트엔드에서 그 스키마를 기준으로 런타임에 데이터 유효성을 검증할 수 있어 API 통신 오류를 사전에 방지
- **타입 자동 생성**: `json-schema-to-typescript` 같은 도구로 JSON Schema에서 [[타입스크립트]] 타입을 자동 생성해, 스키마와 타입 간 불일치를 줄임
- **설정 파일 명세**: `eslintrc`, `tsconfig`, `prettierrc` 등 JSON 기반 설정 파일의 스키마를 `JSON Schema Store`에서 제공하며, 에디터가 이를 기반으로 자동 완성·경고를 지원

## 핵심 정리

JSON Schema는 JSON 데이터 구조를 문서화하는 동시에 검증·타입 생성·에디터 지원까지 연결되는 명세 표준으로, API 계약과 설정 파일 관리에 널리 쓰입니다.

→ [[JSON Schema에 대해 설명해주세요]]
