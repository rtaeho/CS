---
title: "requestAnimationFrame"
tags: [JavaScript, 브라우저, 애니메이션]
status: published
---

requestAnimationFrame은 브라우저의 화면 갱신 주기에 맞춰 애니메이션 콜백 실행을 예약하는 Web API입니다.

## 핵심 특징

- 브라우저가 다음 repaint 전에 콜백을 실행합니다.
- 디스플레이 주사율에 맞춰 실행 주기가 조정됩니다.
- 백그라운드 탭이나 hidden 상태에서는 실행 빈도가 줄거나 멈춰 리소스를 아낍니다.
- `setTimeout`, `setInterval`보다 애니메이션 프레임 타이밍에 적합합니다.

## 사용 예시

```js
let start;

function animate(timestamp) {
  if (start === undefined) {
    start = timestamp;
  }

  const elapsed = timestamp - start;
  box.style.transform = `translateX(${Math.min(elapsed / 10, 300)}px)`;

  if (elapsed < 3000) {
    requestAnimationFrame(animate);
  }
}

requestAnimationFrame(animate);
```

## setInterval과 차이

| 항목 | setInterval | requestAnimationFrame |
|---|---|---|
| 기준 | 지정한 시간 간격 | 브라우저 화면 갱신 주기 |
| 애니메이션 | 프레임 타이밍과 어긋날 수 있음 | repaint 직전에 실행 |
| 백그라운드 탭 | 계속 실행될 수 있음 | 줄거나 중지됨 |
| 용도 | 일반 반복 작업 | 화면 업데이트/애니메이션 |

## 실행 큐

requestAnimationFrame 콜백은 일반 태스크 큐나 마이크로태스크 큐가 아니라 브라우저의 animation frame callbacks 목록에서 관리됩니다. 브라우저는 렌더링 단계에 맞춰 이 콜백들을 실행합니다.

## 핵심 정리

requestAnimationFrame은 화면 갱신과 동기화된 애니메이션을 만들기 위한 API입니다.

렌더링 타이밍에 맞춰 실행되므로 부드러운 애니메이션과 불필요한 작업 감소에 유리합니다.

→ [[requestAnimationFrame에 대해서 설명해주세요]]
