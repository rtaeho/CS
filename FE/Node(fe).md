웹 브라우저가 HTML을 파싱하여 생성하는 **[[DOM]](Document Object Model) 트리의 기본 구성 단위**입니다.

## DOM 트리 구조

```html
<div class="container">
  <h1>제목</h1>
  <p>내용</p>
</div>
```

```
Document
└── div.container        ← Element Node
    ├── h1               ← Element Node
    │   └── "제목"       ← Text Node
    └── p                ← Element Node
        └── "내용"       ← Text Node
```

## Node 종류

|종류|설명|예시|
|---|---|---|
|**Document Node**|DOM 트리 최상위|`document`|
|**Element Node**|HTML 태그|`<div>`, `<p>`, `<h1>`|
|**Text Node**|태그 안의 텍스트|`"제목"`, `"내용"`|
|**Attribute Node**|태그의 속성|`class="container"`|
|**Comment Node**|주석|`<!-- 주석 -->`|

## Node vs [[Element(fe)]]

```
Node    → DOM의 모든 구성 단위 (상위 개념)
Element → Node 중 HTML 태그에 해당하는 것 (하위 개념)

모든 Element는 Node지만
모든 Node가 Element는 아님 (Text Node 등)
```

## 주요 Node 속성/메서드

```javascript
const div = document.querySelector('div');

// 속성
div.nodeType    // 1: Element, 3: Text, 8: Comment
div.nodeName    // "DIV"
div.nodeValue   // null (Element는 null, Text는 텍스트 내용)
div.parentNode  // 부모 노드
div.childNodes  // 자식 노드 목록 (Text Node 포함)
div.children    // 자식 Element 목록 (Element만)

// 탐색
div.firstChild      // 첫 번째 자식 Node (Text Node 포함)
div.firstElementChild // 첫 번째 자식 Element
div.nextSibling     // 다음 형제 Node
div.nextElementSibling // 다음 형제 Element
```

## React에서의 Node

```jsx
// React는 Virtual DOM을 사용
// 실제 DOM Node 대신 가상의 Node 객체를 메모리에 유지

const element = <div>내용</div>;
// → Virtual DOM Node 생성
// → 실제 DOM과 비교(diffing)
// → 변경된 부분만 실제 DOM에 반영 ✅
```

> FE에서 Node는 **DOM 조작의 기본 단위**로, JavaScript로 웹 페이지를 동적으로 변경할 때 Node를 추가/삭제/수정하는 방식으로 동작합니다.