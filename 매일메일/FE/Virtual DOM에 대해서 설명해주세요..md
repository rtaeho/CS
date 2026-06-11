---
title: "Virtual DOM에 대해서 설명해주세요."
tags: [React, 렌더링]
status: published
---

[[Virtual DOM]]은 React에서 사용되는 핵심 개념으로, **실제 DOM을 JS 객체 형태로 복제한 가벼운 사본**이라고 할 수 있습니다. 브라우저의 DOM은 구조적으로 복잡하고, 이를 직접 조작하는 작업은 성능 비용이 상당히 높습니다. Virtual DOM은 이를 개선하여 웹 애플리케이션의 성능을 최적화하기 위해 등장했습니다.

Virtual DOM의 핵심 아이디어는 **상태 변경이 발생할 때마다 전체 UI를 Virtual DOM에 반영하고, 이를 이전 상태와 비교하여 필요한 부분에 한해서 최소한의 DOM 업데이트를 수행**하는 것입니다. Virtual DOM을 업데이트하고 비교하는 일은, 실제 DOM을 조작하지 않고 메모리 상에서 업데이트와 비교가 이뤄지기 때문에 가볍고 빠르게 수행됩니다.

React에서 Virtual DOM을 활용되는 구체적인 과정은 다음과 같습니다.

1. **상태 변경**: 컴포넌트의 상태나 props가 변경되면 Virtual DOM이 다시 생성됩니다.
2. **재조정(Reconciliation)**: 비교 알고리즘을 이용해 새로운 Virtual DOM과 이전 Virtual DOM 간의 차이를 계산합니다.
3. **re-render**: 계산된 차이에 따라 실제 DOM에서 필요한 부분만 업데이트합니다.

Virtual DOM은 이처럼 DOM 업데이트의 비용을 줄이고, 브라우저 렌더링 성능을 개선합니다.

## [](https://www.maeil-mail.kr/question/142#react%EB%8A%94-%EB%B9%84%EA%B5%90diffing-%EC%95%8C%EA%B3%A0%EB%A6%AC%EC%A6%98%EC%9D%84-%EC%96%B4%EB%96%BB%EA%B2%8C-%ED%9A%A8%EC%9C%A8%ED%99%94%ED%96%88%EB%82%98%EC%9A%94-)React는 비교(diffing) 알고리즘을 어떻게 효율화했나요?

React는 O(n³)의 복잡도를 가질 수 있는 트리 비교 문제를, 휴리스틱을 통해 O(n)으로 최적화했습니다.

휴리스틱 알고리즘은 크게 두 가지 가정을 두고 있습니다

### [](https://www.maeil-mail.kr/question/142#1-%EC%84%9C%EB%A1%9C-%EB%8B%A4%EB%A5%B8-%ED%83%80%EC%9E%85%EC%9D%98-%EB%91%90-%EC%9A%94%EC%86%8C%EB%8A%94-%EC%84%9C%EB%A1%9C-%EB%8B%A4%EB%A5%B8-%ED%8A%B8%EB%A6%AC%EB%A5%BC-%EB%A7%8C%EB%93%A4%EC%96%B4%EB%82%B8%EB%8B%A4)1. 서로 다른 타입의 두 요소는 서로 다른 트리를 만들어낸다.

DOM 요소의 타입이 다르면(ex. `<div>` → `<span>`) 비교를 수행하지 않고, 해당 요소와 그 자식들을 모두 새로 생성합니다. 자식 요소들의 내용이 같더라도 이전의 트리를 모두 버리고 완전히 새로 만듭니다. 이는 비효율적으로 보일 수 있지만, 실제 애플리케이션에서 타입이 다른 경우는 보통 완전히 다른 컴포넌트로 교체되는 상황이 많기 때문에 이 가정이 대부분의 경우 효율적입니다.

만약 동일한 타입의 요소라면, 동일한 내역은 유지하고 변경된 속성만 갱신합니다.

```jsx
<div className="before" title="stuff" />

<div className="after" title="stuff" />
```

예를 들어, 이 예시에서는 `className`만 수정합니다.

### [](https://www.maeil-mail.kr/question/142#2-%EA%B0%9C%EB%B0%9C%EC%9E%90%EA%B0%80-key-prop%EC%9D%84-%ED%86%B5%ED%95%B4-%EC%97%AC%EB%9F%AC-%EB%A0%8C%EB%8D%94%EB%A7%81-%EC%82%AC%EC%9D%B4%EC%97%90%EC%84%9C-%EC%96%B4%EB%96%A4-%EC%9E%90%EC%8B%9D-%EC%97%98%EB%A6%AC%EB%A8%BC%ED%8A%B8%EA%B0%80-%EB%B3%80%EA%B2%BD%EB%90%98%EC%A7%80-%EC%95%8A%EC%95%84%EC%95%BC-%ED%95%A0%EC%A7%80-%ED%91%9C%EC%8B%9C%ED%95%B4-%EC%A4%84-%EC%88%98-%EC%9E%88%EB%8B%A4)2. 개발자가 key prop을 통해, 여러 렌더링 사이에서 어떤 자식 엘리먼트가 변경되지 않아야 할지 표시해 줄 수 있다.

같은 레벨의 자식들을 비교할 때 개발자가 입력한 `key` prop을 사용하여 요소를 식별합니다. 이를 통해 리스트 내역의 일부가 수정됐을 때 모든 아이템 요소들을 불필요하게 갱신하지 않고, 실제 변경된 요소만 감지하여 효율적으로 갱신합니다.