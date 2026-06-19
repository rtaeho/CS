---
title: "FOUT"
tags: [CSS, 폰트, 성능]
status: published
---

웹 폰트가 로드되기 전에 시스템 기본 폰트로 텍스트가 먼저 표시되었다가, 로드 완료 후 대상 폰트로 교체되는 현상입니다.

## 핵심 특징

- Flash of Unstyled Text의 약자입니다
- 폰트 교체 시 레이아웃이 흔들리는 시각적 불안정감을 줍니다
- CSS `font-display: swap` 속성 적용 시 의도적으로 FOUT를 허용합니다

## 관련 현상

| 현상 | 설명 |
|---|---|
| FOUT | 기본 폰트 표시 후 웹 폰트로 교체 |
| FOIT | 폰트 로드 전까지 텍스트를 보이지 않게 처리 (Flash of Invisible Text) |

## 해결 방법

- `<link rel="preload">` 로 폰트를 미리 로드합니다
- `font-display: optional` 로 폰트가 캐시에 없으면 기본 폰트만 사용합니다
- 폰트 파일 크기를 최적화하여 로드 시간을 단축합니다

## 핵심 정리

- FOUT는 완전히 막기보다 허용 범위를 줄이는 방향으로 관리합니다
- `preload`로 폰트를 미리 가져오는 것이 가장 효과적인 대응 방법입니다
