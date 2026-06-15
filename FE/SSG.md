---
title: "SSG"
tags: [React, Next.js, 렌더링]
status: published
---

Static Site Generation — 빌드 타임에 HTML을 미리 생성하여 정적 파일로 배포하는 렌더링 방식이다.

## 핵심 특징

- 빌드 시 데이터 페칭 후 HTML을 완전히 렌더링해 두어 CDN으로 배포
- 요청마다 서버 처리 불필요 → TTFB(Time To First Byte)가 가장 빠름
- 콘텐츠가 빌드 시점으로 고정되어 실시간 데이터 반영 불가
- ISR(Incremental Static Regeneration)로 주기적 재생성 가능 (Next.js 제공)
- 블로그·마케팅 페이지처럼 변경 빈도가 낮은 콘텐츠에 적합

## CSR / SSR / SSG 비교

| | 렌더링 위치 | 시점 | 데이터 신선도 |
|---|---|---|---|
| [[CSR]] | 브라우저 | 런타임 | 최신 |
| [[SSR]] | 서버 | 요청마다 | 최신 |
| SSG | 서버 | 빌드 시 | 빌드 시점 |

## 핵심 정리

SSG는 성능이 가장 우수하지만 실시간성이 없다. Next.js에서는 `generateStaticParams` 또는 `getStaticProps`로 구현한다.
