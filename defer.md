HTML에서 외부 스크립트를 **파싱과 병렬로 다운로드하되, HTML 파싱이 완전히 끝난 후 선언 순서대로 실행하게 하는 `<script>` 태그 속성**입니다.

## 동작 원리

```
[ defer 없이 (기본) ]
HTML 파싱 ████████ ── 중단 ──────────── 재개 ████████
                      다운로드 ██████
                              실행 ████

[ defer 사용 ]
HTML 파싱 ██████████████████████████████████████████
JS 다운로드  ██████████                  실행 ████
                                         ↑ 파싱 완료 후 실행
```

```
핵심:
다운로드 → 파싱과 동시에 (병렬)
실행     → 파싱이 완전히 끝난 후
→ HTML 파싱을 전혀 방해하지 않음
```

## 왜 필요한가

### 문제 상황 — script가 DOM보다 먼저 실행

```html
<head>
    <script src="app.js"></script>
</head>
<body>
    <h1 id="title">안녕</h1>
</body>
```

```javascript
// app.js
const el = document.getElementById("title");
el.textContent = "변경";   // ✗ 에러! — <h1>이 아직 파싱 전
```

```
파싱 순서:
<head> → <script> 만남 → 파싱 중단 → 다운로드 → 실행
                                                ↑ 이 시점에 <h1>은 아직 없음
```

### defer로 해결

```html
<head>
    <script defer src="app.js"></script>
</head>
<body>
    <h1 id="title">안녕</h1>
</body>
```

```
파싱 순서:
<head> → <script defer> 만남 → 다운로드 시작 (파싱 계속)
       → <body> → <h1> 파싱 완료
       → 파싱 완전히 끝남
       → app.js 실행
         ↑ 이 시점에 <h1>이 이미 DOM에 존재 ✓
```

## defer의 핵심 특징

### 1. 실행 순서 보장

```html
<script defer src="a.js"></script>   <!-- 200KB -->
<script defer src="b.js"></script>   <!-- 10KB -->
<script defer src="c.js"></script>   <!-- 50KB -->
```

```
다운로드 (병렬, 완료 시점은 제각각):
a.js  ██████████████████████       (200KB, 가장 느림)
b.js  ████                          (10KB, 가장 빠름)
c.js  ██████████                    (50KB)

실행 (파싱 완료 후, 반드시 선언 순서대로):
HTML 파싱 완료 → a.js 실행 → b.js 실행 → c.js 실행
                 ↑ b.js가 먼저 다운됐어도 a.js 먼저 실행
```

### 2. DOMContentLoaded 전에 실행

```
시간축 ──────────────────────────────────────────→

HTML 파싱  ████████████████████████████
defer 실행                              ██ ██ ██
DOMContentLoaded                                 ↑ defer 모두 완료 후 발생
```

```javascript
// defer 스크립트가 실행된 후에 DOMContentLoaded가 발생
document.addEventListener("DOMContentLoaded", () => {
    // 이 시점에서 defer 스크립트는 모두 실행 완료
    console.log("모든 defer 스크립트 실행 완료 후 호출됨");
});
```

### 3. DOM이 완전히 구성된 상태에서 실행

```javascript
// defer 스크립트 안에서는 DOM 접근이 안전
// DOMContentLoaded 리스너를 별도로 걸 필요 없음

// ✗ defer 없이 — 이벤트 리스너 필요
document.addEventListener("DOMContentLoaded", () => {
    document.getElementById("title").textContent = "변경";
});

// ✓ defer 사용 시 — 바로 접근 가능
document.getElementById("title").textContent = "변경";
```

## defer vs 다른 방식 비교

|항목|기본 script|body 끝 배치|defer|async|
|---|---|---|---|---|
|파싱 차단|✓|✗|✗|실행 시만|
|다운로드 시점|파싱 중단 후|파싱 끝 무렵|파싱과 병렬|파싱과 병렬|
|실행 시점|즉시|파싱 거의 끝|파싱 완료 후|다운로드 즉시|
|순서 보장|✓|✓|✓|✗|
|DOM 접근|위험|안전|안전|보장 안 됨|

### defer vs body 끝 배치

```html
<!-- 방법 1: body 끝 배치 -->
<body>
    <h1>내용</h1>
    <script src="app.js"></script>   <!-- 파싱 거의 끝난 후 다운로드 시작 -->
</body>

<!-- 방법 2: defer -->
<head>
    <script defer src="app.js"></script>  <!-- 파싱과 동시에 다운로드 시작 -->
</head>
<body>
    <h1>내용</h1>
</body>
```

```
[ body 끝 배치 ]
HTML 파싱 ██████████████████████████████████████
JS 다운로드                                     █████████
JS 실행                                                  ████
                                                ↑ 파싱 끝나고 다운로드 시작

[ defer ]
HTML 파싱 ██████████████████████████████████████
JS 다운로드  █████████                     실행 ████
             ↑ 파싱과 동시에 다운로드        ↑ 파싱 끝나면 바로 실행

→ defer가 다운로드를 미리 시작하므로 더 빠름
```

## defer가 작동하지 않는 경우

### 1. 인라인 스크립트

```html
<!-- defer 무시됨 — 외부 파일(src)에만 적용 가능 -->
<script defer>
    console.log("defer 무시됨, 즉시 실행");
</script>
```

### 2. 동적으로 생성한 스크립트

```javascript
// 동적 생성 스크립트는 기본이 async처럼 동작
const script = document.createElement("script");
script.src = "app.js";
document.head.appendChild(script);

// defer처럼 동작시키려면 명시적으로 설정
script.defer = true;
script.async = false;   // async가 우선하므로 false로 명시
```

### 3. module 스크립트는 이미 defer

```html
<!-- type="module"은 기본적으로 defer처럼 동작 -->
<script type="module" src="app.js"></script>

<!-- 따라서 defer를 붙여도 중복일 뿐 -->
<script type="module" defer src="app.js"></script>  <!-- defer 불필요 -->
```

## 실무 활용 패턴

```html
<!DOCTYPE html>
<html>
<head>
    <!-- 메인 앱 — defer로 순서 보장 + 파싱 비차단 -->
    <script defer src="vendor.js"></script>
    <script defer src="utils.js"></script>
    <script defer src="app.js"></script>

    <!-- 독립적 서드파티 — async -->
    <script async src="analytics.js"></script>
</head>
<body>
    <div id="app"></div>
    <!-- body 끝에 script를 둘 필요 없음 -->
</body>
</html>
```

```
판단 기준:

스크립트가 DOM을 조작하는가?
    │
    ├── Yes → defer ✓
    │
    └── No → 다른 스크립트에 의존하는가?
                │
                ├── Yes → defer ✓ (순서 보장)
                │
                └── No → async ✓ (독립적)
```

## 핵심 정리

defer는 **다운로드를 파싱과 병렬로 처리하면서도, 실행은 HTML 파싱 완료 후 선언 순서대로** 보장하는 속성입니다. body 끝 배치보다 **다운로드를 미리 시작**할 수 있어 더 빠르고, async와 달리 **실행 순서가 보장**되므로 의존성이 있는 메인 애플리케이션 스크립트에 적합합니다. 인라인 스크립트에는 적용되지 않으며, `type="module"`은 기본적으로 defer 동작을 포함합니다.