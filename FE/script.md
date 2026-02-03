HTML 문서에서 **JavaScript 코드를 삽입하거나 외부 JS 파일을 연결하기 위한 HTML 태그**입니다.

## 두 가지 사용 방식

### 1. 인라인 스크립트 — 코드를 직접 작성

```html
<script>
    console.log("안녕하세요");
    document.getElementById("title").textContent = "변경됨";
</script>
```

### 2. 외부 스크립트 — 별도 파일 연결

```html
<script src="app.js"></script>
```

```
프로젝트 구조:
├── index.html     ← <script src="app.js">로 연결
├── app.js         ← 실제 JavaScript 코드
└── style.css
```

## 왜 필요한가

```
HTML  → 문서의 구조 (뼈대)
CSS   → 문서의 스타일 (꾸미기)
JS    → 문서의 동작 (움직임, 상호작용)
         ↑
    <script> 태그로 HTML에 연결
```

```html
<!-- HTML만 있으면 -->
<button>클릭</button>
<!-- 버튼이 보이기만 하고 아무 동작 안 함 -->

<!-- script로 JS를 연결하면 -->
<button id="btn">클릭</button>
<script>
    document.getElementById("btn").addEventListener("click", () => {
        alert("클릭됨!");
    });
</script>
<!-- 버튼을 누르면 알림이 뜸 -->
```

## 브라우저가 script 태그를 처리하는 과정

```
HTML 문서 로드
     │
     ▼
브라우저가 위에서 아래로 한 줄씩 파싱
     │
     ├── <div> → DOM 노드 생성
     ├── <p> → DOM 노드 생성
     ├── <script> → ⚠️ 파싱 중단
     │                │
     │                ├── 인라인 → 즉시 실행
     │                └── 외부(src) → 다운로드 → 실행
     │                │
     │                ▼
     │             실행 완료 후 파싱 재개
     ├── <div> → DOM 노드 생성
     ▼
파싱 완료 → DOMContentLoaded 이벤트
```

## script 위치에 따른 차이

### head에 배치 — 문제 발생

```html
<!DOCTYPE html>
<html>
<head>
    <script>
        // DOM이 아직 생성되기 전에 실행됨
        document.getElementById("title").textContent = "변경";
        // ✗ 에러! #title이 아직 없음
    </script>
</head>
<body>
    <h1 id="title">원본</h1>
</body>
</html>
```

```
파싱 순서:
<head> → <script> 실행 (이 시점에 <body>는 아직 파싱 전)
                          ↑ #title을 찾을 수 없음
```

### body 끝에 배치 — 일반적 해결법

```html
<!DOCTYPE html>
<html>
<head>
    <title>페이지</title>
</head>
<body>
    <h1 id="title">원본</h1>

    <!-- DOM이 모두 생성된 후 실행 -->
    <script>
        document.getElementById("title").textContent = "변경";
        // ✓ 정상 동작
    </script>
</body>
</html>
```

```
파싱 순서:
<head> → <body> → <h1> → <script> 실행
                    ↑ 이미 DOM에 존재
```

### defer 사용 — 현대적 해결법

```html
<head>
    <script defer src="app.js"></script>
    <!-- head에 있지만 파싱 완료 후 실행 -->
</head>
<body>
    <h1 id="title">원본</h1>
</body>
```

## script 태그의 주요 속성

|속성|설명|예시|
|---|---|---|
|**src**|외부 JS 파일 경로|`<script src="app.js">`|
|**type**|스크립트 유형|`<script type="module">`|
|**async**|비동기 다운로드, 완료 즉시 실행|`<script async src="a.js">`|
|**defer**|비동기 다운로드, 파싱 완료 후 실행|`<script defer src="a.js">`|
|**nomodule**|모듈 미지원 브라우저용 폴백|`<script nomodule src="legacy.js">`|

## type 속성 변화

```html
<!-- 과거 — type 명시 필요 -->
<script type="text/javascript">
    console.log("과거 방식");
</script>

<!-- 현재 — 생략 가능 (기본값이 text/javascript) -->
<script>
    console.log("현재 방식");
</script>

<!-- ES 모듈 사용 시 -->
<script type="module">
    import { hello } from './utils.js';
    hello();
</script>
```

### 일반 script vs module

|항목|`<script>`|`<script type="module">`|
|---|---|---|
|스코프|전역|모듈별 독립|
|import/export|불가|가능|
|기본 실행 방식|즉시|defer처럼 동작|
|strict mode|선택|자동 적용|
|중복 실행|매번 실행|한 번만 실행|

```html
<!-- 일반 script — 전역 오염 -->
<script src="a.js"></script>
<script src="b.js"></script>
<!-- a.js의 변수가 b.js에 영향 가능 -->

<!-- module — 독립적 -->
<script type="module" src="a.js"></script>
<script type="module" src="b.js"></script>
<!-- 각각 독립된 스코프 -->
```

## 실무 권장 패턴

```html
<!DOCTYPE html>
<html>
<head>
    <!-- 분석 도구 — 독립적, 빠른 실행 -->
    <script async src="analytics.js"></script>

    <!-- 메인 앱 — 순서 보장 + DOM 완료 후 실행 -->
    <script defer src="vendor.js"></script>
    <script defer src="app.js"></script>

    <!-- 또는 모듈 방식 -->
    <script type="module" src="main.js"></script>
</head>
<body>
    <div id="app"></div>
</body>
</html>
```

## 핵심 정리

`<script>`는 **HTML에 JavaScript를 연결하는 태그**로, 인라인 코드 작성 또는 외부 파일 참조가 가능합니다. 기본적으로 브라우저는 script를 만나면 **파싱을 중단**하고 스크립트를 실행하므로, 이를 방지하기 위해 `defer`(파싱 완료 후 순서대로 실행), `async`(다운로드 즉시 실행), `type="module"`(모듈 스코프 + defer 기본 동작) 등의 속성을 활용합니다.