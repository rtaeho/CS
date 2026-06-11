---
title: "PWA"
tags: [웹, 최적화]
status: published
---

웹 기술로 만들었지만 **네이티브 앱처럼 설치·오프라인 동작·푸시 알림이 가능한** 웹 애플리케이션입니다 (Progressive Web App).

## 3가지 핵심 요건

```
1. HTTPS         — Service Worker 등록 필수 조건
2. Web App Manifest — 앱 이름, 아이콘, 시작 URL 정의
3. Service Worker — 오프라인 캐싱, 백그라운드 처리
```

## Web App Manifest

```json
// manifest.json
{
  "name": "My App",
  "short_name": "App",
  "start_url": "/",
  "display": "standalone",    // 브라우저 UI 없이 앱처럼 표시
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "icons": [
    { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
  ]
}
```

```html
<link rel="manifest" href="/manifest.json">
```

## Service Worker

**브라우저와 네트워크 사이에 위치하는 프록시 스크립트**. 네트워크 요청을 가로채 캐시에서 응답하거나 백그라운드 작업을 수행.

```javascript
// service-worker.js

// 설치 — 핵심 리소스 사전 캐싱
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open('v1').then((cache) =>
      cache.addAll(['/', '/index.html', '/main.js', '/style.css'])
    )
  )
})

// 요청 가로채기 — Cache First 전략
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((cached) =>
      cached ?? fetch(event.request)   // 캐시 없으면 네트워크
    )
  )
})
```

```javascript
// main.js — Service Worker 등록
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/service-worker.js')
}
```

## 캐싱 전략

| 전략 | 동작 | 적합한 리소스 |
|---|---|---|
| **Cache First** | 캐시 → 없으면 네트워크 | 이미지, 폰트, CSS |
| **Network First** | 네트워크 → 실패 시 캐시 | API 데이터, HTML |
| **Stale-While-Revalidate** | 캐시 즉시 반환 + 백그라운드 갱신 | 뉴스 피드, 목록 |
| **Cache Only** | 캐시만 | 오프라인 전용 리소스 |
| **Network Only** | 네트워크만 | 결제, 인증 |

## PWA vs 네이티브 앱

| | PWA | 네이티브 앱 |
|---|---|---|
| 설치 | 브라우저에서 바로 | 앱스토어 심사 필요 |
| 업데이트 | 서버 배포 즉시 반영 | 앱스토어 배포 후 사용자 업데이트 |
| 기기 접근 | 제한적 (카메라, GPS 가능) | 완전 접근 |
| 성능 | 네이티브보다 낮음 | 높음 |
| 개발 비용 | 낮음 (웹 기술 재사용) | 높음 (iOS/Android 각각) |

## 핵심 정리

- Service Worker가 핵심 — 네트워크 프록시로서 오프라인 캐싱, 백그라운드 동기화, 푸시 알림 담당

- Manifest로 홈 화면 설치·스플래시 화면 등 앱 경험 제공

- 캐싱 전략은 리소스 유형에 따라 다르게 — 정적 파일은 Cache First, API는 Network First

→ [[CSR]] | [[SSR]] | [[렌더링]]

