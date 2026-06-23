---
title: "Resource Hint"
tags: [HTML, 브라우저, 성능최적화]
status: published
---

브라우저에 앞으로 필요할 네트워크 연결이나 리소스를 미리 준비하도록 알려 렌더링 지연을 줄이는 HTML 최적화 기법입니다.

## 핵심 특징

- **선언적 최적화**: `<link rel="...">`로 브라우저에게 우선순위 힌트를 전달
- **네트워크 비용 감소**: [[DNS]], [[TCP]], [[TLS]] 연결 준비 시간을 줄일 수 있음
- **렌더링 지연 완화**: 폰트, 스크립트, 다음 페이지 리소스를 미리 준비해 사용자 체감 속도를 개선
- **과사용 주의**: 필요하지 않은 리소스를 미리 가져오면 대역폭과 메모리를 낭비할 수 있음

## preconnect

`preconnect`는 특정 origin에 대한 연결을 미리 맺어두는 힌트입니다.

```html
<link rel="preconnect" href="https://cdn.example.com" crossorigin>
```

브라우저는 리소스를 다운로드하지 않고, DNS 조회, TCP 연결, TLS 핸드셰이크 같은 연결 준비만 먼저 수행합니다. 외부 [[CDN]], 폰트 서버, API 서버처럼 곧 요청할 가능성이 높은 origin에 적합합니다.

## preload

`preload`는 현재 페이지에서 곧 필요한 특정 리소스를 높은 우선순위로 미리 다운로드하도록 지시합니다.

```html
<link rel="preload" href="/fonts/main.woff2" as="font" type="font/woff2" crossorigin>
```

폰트, 히어로 이미지, 중요한 CSS/JS처럼 초기 렌더링에 직접 영향을 주는 리소스에 사용합니다. `as` 속성을 정확히 지정해야 브라우저가 올바른 우선순위와 캐시 정책을 적용할 수 있습니다.

## prefetch

`prefetch`는 현재 화면에는 당장 필요하지 않지만, 이후 탐색에서 필요할 가능성이 높은 리소스를 낮은 우선순위로 미리 가져오는 힌트입니다.

```html
<link rel="prefetch" href="/next-page.js" as="script">
```

다음 페이지, 다음 라우트, 사용자가 곧 열 가능성이 높은 화면의 리소스를 준비할 때 유용합니다. 현재 페이지의 핵심 리소스보다 우선순위가 낮아야 하므로 즉시 필요한 리소스에는 `preload`가 더 적합합니다.

## preconnect vs preload vs prefetch

| 항목 | preconnect | preload | prefetch |
|---|---|---|---|
| 목적 | 연결 준비 | 현재 페이지 핵심 리소스 선로드 | 이후 탐색 리소스 선로드 |
| 다운로드 | 하지 않음 | 즉시 다운로드 | 낮은 우선순위로 다운로드 |
| 사용 대상 | 외부 origin | 폰트, 이미지, CSS, JS | 다음 페이지 리소스 |
| 우선순위 | 연결 준비 비용 절감 | 높음 | 낮음 |

## 언제 쓰나

- 외부 폰트나 CDN을 자주 사용하면 `preconnect`
- LCP 이미지나 웹 폰트처럼 현재 페이지 초기 렌더링에 중요하면 `preload`
- 다음 라우트의 JS/CSS처럼 곧 필요할 가능성이 높지만 당장 필요하지 않으면 `prefetch`
- 실제 병목은 [[브라우저]] 개발자 도구의 Network, Performance 패널로 확인한 뒤 적용

## 주의사항

- 너무 많은 `preconnect`는 브라우저 연결 슬롯을 낭비할 수 있음
- `preload`한 리소스를 실제로 사용하지 않으면 불필요한 다운로드가 됨
- `preload`에는 `as`, 폰트에는 `crossorigin`을 정확히 지정해야 중복 다운로드를 피할 수 있음
- `prefetch`는 사용자 네트워크 상황에 따라 생략될 수 있으므로 필수 로딩 전략으로 의존하면 안 됨

## 핵심 정리

Resource Hint는 브라우저가 미래의 네트워크 작업을 더 빨리 준비하게 만드는 힌트입니다.

`preconnect`는 연결을 준비하고,
`preload`는 현재 페이지의 중요한 리소스를 먼저 받고,
`prefetch`는 다음에 쓸 가능성이 있는 리소스를 여유 있을 때 받아둡니다.

→ [[HTML link 요소의 rel 속성 값 preconnect, preload, prefetch에 대해 설명해주세요]]
