---
title: "requestAnimationFrame에 대해서 설명해주세요"
tags: [매일메일, Frontend]
status: published
---

[[requestAnimationFrame]]은 브라우저의 화면 갱신 주기에 맞춰 콜백 함수를 실행하도록 요청하는 API입니다. 주로 부드러운 애니메이션을 구현할 때 사용합니다.

## 목적

애니메이션은 화면이 갱신되는 시점에 맞춰 상태를 바꾸는 것이 중요합니다. `requestAnimationFrame()`은 브라우저가 다음 repaint를 수행하기 직전에 콜백을 실행해 프레임 드롭을 줄이고 자연스러운 화면 변화를 만들 수 있게 합니다.

```js
const animate = () => {
  // 애니메이션 상태 업데이트
  requestAnimationFrame(animate);
};

requestAnimationFrame(animate);
```

## setTimeout, setInterval과 차이

`setTimeout()`이나 `setInterval()`도 일정 시간마다 함수를 실행할 수 있지만, 브라우저의 화면 갱신 주기와 맞지 않을 수 있습니다. 그러면 불필요한 작업이나 프레임 끊김이 생길 수 있습니다.

반면 `requestAnimationFrame()`은 화면 갱신 주기와 동기화되어 실행되므로 애니메이션에 더 적합합니다.

## 추가 장점

디스플레이 주사율이 60Hz, 120Hz, 144Hz처럼 달라도 브라우저가 적절한 타이밍에 콜백을 실행합니다. 또한 백그라운드 탭이나 hidden 상태에서는 실행을 줄이거나 중지해 배터리와 리소스를 절약합니다.

## 실행 위치

`requestAnimationFrame()` 콜백은 일반 태스크 큐나 마이크로태스크 큐가 아니라 브라우저가 관리하는 animation frame callbacks 목록에서 별도로 관리됩니다.

## 추가 학습 자료

- [requestAnimationFrame 가이드](https://inpa.tistory.com/entry/%F0%9F%8C%90-requestAnimationFrame-%EA%B0%80%EC%9D%B4%EB%93%9C)
- [HTML Standard - Animation Frames](https://html.spec.whatwg.org/multipage/imagebitmap-and-animations.html#list-of-animation-frame-callbacks)
