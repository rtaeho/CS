JavaScript의 **공식 표준 모듈 시스템**으로, `import`로 모듈을 불러오고 `export`로 내보내는 방식입니다.

## 왜 등장했는가

```
2009  CommonJS 등장 → Node.js 전용, 브라우저 사용 불가
2012  AMD 등장 → 브라우저용, 문법 복잡
2015  ES Modules 표준 제정 (ES6)
       → JavaScript 언어 자체에 모듈 시스템 내장
       → 브라우저 + Node.js 모두 사용 가능
       → 하나의 표준으로 통일
```

```
[ 과거 — 환경마다 다른 모듈 시스템 ]
서버 (Node.js):  CommonJS   → require / module.exports
브라우저:        AMD         → define / require
빌드 도구:       UMD         → 둘 다 호환하려는 시도

[ 현재 — ES Modules로 통일 ]
서버:     import / export
브라우저:  import / export
빌드 도구: import / export
```

## 기본 문법

### Named Export (이름 붙여 내보내기)

```javascript
// math.js
export const PI = 3.14159;

export function add(a, b) {
    return a + b;
}

export function subtract(a, b) {
    return a - b;
}
```

```javascript
// main.js — 필요한 것만 골라서 가져오기
import { add, subtract } from "./math.js";
add(1, 2);       // 3
subtract(5, 3);  // 2

// 별칭(alias) 사용
import { add as plus } from "./math.js";
plus(1, 2);      // 3

// 전체 가져오기
import * as math from "./math.js";
math.add(1, 2);  // 3
math.PI;         // 3.14159
```

### Default Export (기본 내보내기)

```javascript
// logger.js — 모듈당 하나만 가능
export default function log(message) {
    console.log(`[LOG] ${message}`);
}
```

```javascript
// main.js — 이름을 자유롭게 지정 가능
import log from "./logger.js";
import myLogger from "./logger.js";   // 어떤 이름이든 가능
log("안녕");  // [LOG] 안녕
```

### Named + Default 혼합

```javascript
// api.js
export default class ApiClient { ... }
export const BASE_URL = "https://api.example.com";
export function createHeaders() { ... }
```

```javascript
// main.js
import ApiClient, { BASE_URL, createHeaders } from "./api.js";
```

### Re-export (다시 내보내기)

```javascript
// index.js — 여러 모듈을 모아서 재내보내기
export { add, subtract } from "./math.js";
export { default as Logger } from "./logger.js";
export * from "./utils.js";
```

```javascript
// 사용하는 쪽 — 하나의 경로에서 모두 가져오기
import { add, Logger } from "./index.js";
```

## 동작 원리

### 3단계 처리 과정

```
import { add } from "./math.js"
         │
         ▼
┌─── ① 파싱 (Construction) ──────────────────┐
│  import/export 구문을 정적으로 분석           │
│  의존성 그래프(Module Graph) 구성             │
│  아직 코드를 실행하지 않음                     │
└────────────────────────────────────────────┘
         │
         ▼
┌─── ② 인스턴스화 (Instantiation) ───────────┐
│  export된 변수들의 메모리 공간 확보            │
│  import와 export를 같은 메모리에 연결          │
│  (Live Binding)                              │
└────────────────────────────────────────────┘
         │
         ▼
┌─── ③ 평가 (Evaluation) ───────────────────┐
│  코드를 실제로 실행하여 값 할당               │
│  한 번만 실행 (캐싱)                         │
└────────────────────────────────────────────┘
```

### Module Graph 구성

```javascript
// main.js
import { render } from "./ui.js";
import { fetchData } from "./api.js";

// ui.js
import { format } from "./utils.js";

// api.js
import { format } from "./utils.js";
```

```
         main.js
        ╱       ╲
     ui.js     api.js
        ╲       ╱
        utils.js     ← 중복 로드 없이 한 번만 로드
```

## CommonJS와의 핵심 차이

### 1. 정적 분석 vs 런타임 로딩

```javascript
// CommonJS — 런타임에 결정 (동적)
const mod = require(condition ? "./a" : "./b");   // ✓ 가능

// ESM — 파싱 타임에 결정 (정적)
import mod from condition ? "./a" : "./b";        // ✗ 불가능
// import 구문은 파일 최상위에, 정적 문자열만 가능
```

```
ESM은 코드 실행 전에 모든 의존성을 파악 가능
→ 정적 분석 가능
→ Tree Shaking 가능
→ 더 나은 최적화
```

### 2. Live Binding vs 값 복사

```javascript
// ── CommonJS — 값의 복사본 ──

// counter.js
let count = 0;
const increment = () => count++;
module.exports = { count, increment };

// main.js
const counter = require("./counter");
console.log(counter.count);   // 0
counter.increment();
console.log(counter.count);   // 0 ← 변경 반영 안 됨 (복사본)


// ── ESM — Live Binding (참조 연결) ──

// counter.js
export let count = 0;
export const increment = () => count++;

// main.js
import { count, increment } from "./counter.js";
console.log(count);   // 0
increment();
console.log(count);   // 1 ← 변경 즉시 반영 (같은 메모리)
```

```
[ CommonJS ]
counter.js  count: 0 ──복사──→ main.js  counter.count: 0
            count: 1           main.js  counter.count: 0 (여전히)

[ ESM ]
counter.js  count ◄──같은 메모리──► main.js  count
            0 → 1                          0 → 1 (함께 변경)
```

### 3. 비동기 vs 동기 로딩

```
[ CommonJS — 동기 ]
require("a") → 파일 읽기 (블로킹) → 실행 → 반환
               ↑ 완료될 때까지 멈춤

[ ESM — 비동기 ]
import "a" → 파일 다운로드 (비동기) → 파싱 → 인스턴스화 → 실행
              ↑ 다른 모듈 병렬 로드 가능
```

### 전체 비교 요약

|항목|CommonJS|ES Modules|
|---|---|---|
|문법|`require` / `module.exports`|`import` / `export`|
|로딩|동기 (블로킹)|비동기|
|분석 시점|런타임 (동적)|파싱 타임 (정적)|
|값 전달|복사본|Live Binding (참조)|
|조건부 로딩|`require(조건)` 가능|기본 불가|
|Tree Shaking|불가|가능|
|브라우저|미지원|지원|
|파일 확장자|.js|.mjs 또는 type:"module"|
|최상위 await|불가|가능|
|this|module.exports|undefined|

## Tree Shaking — ESM의 가장 큰 장점

```javascript
// utils.js
export function add(a, b) { return a + b; }
export function subtract(a, b) { return a - b; }
export function multiply(a, b) { return a * b; }
export function divide(a, b) { return a / b; }
// ... 수십 개의 유틸 함수
```

```javascript
// main.js — add만 사용
import { add } from "./utils.js";
add(1, 2);
```

```
[ CommonJS ]
번들러: "require로 가져왔으니 utils.js 전체를 포함해야 해"
결과: add, subtract, multiply, divide 모두 포함 (100KB)

[ ESM ]
번들러: "import { add }만 사용하네, 나머지는 제거"
결과: add 함수만 포함 (2KB) ← Tree Shaking
```

```
Tree Shaking 비유:
나무(모듈)를 흔들어서(shake) 떨어지는 잎(사용하지 않는 코드)을 제거

     utils.js (나무)
      ╱  │  ╲  ╲
   add sub mul div
    ✓   ✗   ✗   ✗
    │
  번들에 포함     나머지는 제거 (dead code elimination)
```

## Dynamic Import — ESM의 동적 로딩

정적 import만으로 부족할 때 사용합니다.

```javascript
// 정적 import — 항상 로드
import { add } from "./math.js";

// 동적 import — 필요할 때만 로드
const button = document.getElementById("btn");
button.addEventListener("click", async () => {
    const { add } = await import("./math.js");   // 클릭 시 로드
    console.log(add(1, 2));
});
```

```
[ 정적 import ]
페이지 로드 시 모든 모듈 다운로드
→ 초기 로딩 느림

[ Dynamic import ]
필요한 시점에 모듈 다운로드
→ 초기 로딩 빠름 (코드 스플리팅)
```

```javascript
// 조건부 로딩 — CommonJS의 조건부 require 대체
let logger;
if (process.env.NODE_ENV === "production") {
    logger = await import("./prod-logger.js");
} else {
    logger = await import("./dev-logger.js");
}
```

## 브라우저에서 사용

```html
<!-- type="module"을 반드시 명시 -->
<script type="module" src="main.js"></script>

<!-- 인라인도 가능 -->
<script type="module">
    import { add } from "./math.js";
    console.log(add(1, 2));
</script>

<!-- module 미지원 브라우저용 폴백 -->
<script nomodule src="fallback.js"></script>
```

```
module 스크립트의 특징:
├── 기본적으로 defer처럼 동작 (파싱 완료 후 실행)
├── 자동 strict mode
├── 파일마다 독립 스코프
├── 동일 모듈 중복 실행 방지
└── CORS 적용
```

## Node.js에서 사용

```javascript
// 방법 1: 파일 확장자를 .mjs로
// math.mjs
export const add = (a, b) => a + b;

// main.mjs
import { add } from "./math.mjs";


// 방법 2: package.json에 type 설정
// package.json
{
    "type": "module"     // 모든 .js 파일을 ESM으로 취급
}

// 이후 일반 .js 파일에서 import/export 사용 가능
```

## 최상위 await (Top-Level Await)

```javascript
// ESM에서만 가능 — CommonJS에서는 불가

// config.js
const response = await fetch("/api/config");
export const config = await response.json();

// main.js
import { config } from "./config.js";
// config.js의 await가 완료된 후에 main.js가 실행됨
console.log(config);  // 완전히 로드된 설정값
```

## 핵심 정리

ES Modules는 JavaScript **언어 자체에 내장된 공식 표준 모듈 시스템**입니다. `import/export`의 정적 구문 덕분에 **파싱 타임에 의존성을 분석**할 수 있어 Tree Shaking이 가능하고, **Live Binding**으로 모듈 간 값 변경이 실시간 반영됩니다. 비동기 로딩으로 브라우저에서도 사용 가능하며, Dynamic Import로 코드 스플리팅까지 지원합니다. 현재 브라우저와 Node.js 모두에서 지원되는 **모듈 시스템의 사실상 표준**이며, CommonJS를 대체하는 방향으로 생태계가 전환 중입니다.