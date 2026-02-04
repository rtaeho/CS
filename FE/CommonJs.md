Node.js에서 시작된 **JavaScript 모듈 시스템**으로, `require()`로 모듈을 불러오고 `module.exports`로 내보내는 방식입니다.

## 왜 필요했는가

```
[ 초기 JavaScript — 모듈 시스템 없음 ]

<script src="a.js"></script>
<script src="b.js"></script>
<script src="c.js"></script>

a.js: var name = "Kim";
b.js: var name = "Lee";     // a.js의 name을 덮어씀
c.js: console.log(name);    // "Lee" — 의도한 건 "Kim"이었는데?

→ 모든 변수가 전역 스코프에 노출
→ 파일 간 이름 충돌
→ 의존 관계 불명확
→ 대규모 프로젝트 불가능
```

```
[ CommonJS 등장 (2009) ]

// a.js
const name = "Kim";
module.exports = name;       // 명시적으로 내보내기

// b.js
const name = require("./a"); // 명시적으로 가져오기
console.log(name);           // "Kim"

→ 파일마다 독립된 스코프
→ 의존 관계 명확
→ Node.js의 기본 모듈 시스템으로 채택
```

## 기본 문법

### 내보내기 (exports)

```javascript
// ── 방법 1: module.exports 직접 할당 ──

// 단일 값 내보내기
module.exports = function add(a, b) {
    return a + b;
};

// 객체로 여러 값 내보내기
module.exports = {
    add: (a, b) => a + b,
    subtract: (a, b) => a - b,
};


// ── 방법 2: exports에 속성 추가 ──

exports.add = (a, b) => a + b;
exports.subtract = (a, b) => a - b;
```

### 가져오기 (require)

```javascript
// 단일 값
const add = require("./math");
add(1, 2);  // 3

// 객체에서 구조 분해
const { add, subtract } = require("./math");
add(1, 2);       // 3
subtract(5, 3);  // 2

// Node.js 내장 모듈
const fs = require("fs");
const path = require("path");

// npm 패키지
const express = require("express");
```

## module.exports vs exports 차이

```javascript
// exports는 module.exports를 가리키는 참조(별칭)

// 내부적으로 이렇게 초기화됨
var module = { exports: {} };
var exports = module.exports;   // 같은 객체를 참조
```

```javascript
// ✓ 정상 — 속성 추가는 같은 객체에 반영
exports.name = "Kim";
exports.age = 25;
// module.exports === { name: "Kim", age: 25 }

// ✗ 문제 — exports에 새 객체를 할당하면 참조가 끊김
exports = { name: "Kim" };
// module.exports는 여전히 {} (빈 객체)
// require 결과: {} ← 의도와 다름

// ✓ 새 객체를 할당하려면 module.exports 사용
module.exports = { name: "Kim" };
```

```
메모리 구조:

[ 초기 상태 ]
module.exports ──→ { }
exports ──────────→ { }  (같은 객체)

[ exports = { name: "Kim" } 이후 ]
module.exports ──→ { }           ← require가 반환하는 것
exports ──────────→ { name: "Kim" }  ← 참조가 끊김, 무의미
```

## require()의 동작 원리

```
require("./math")
     │
     ▼
① 경로 해석 (Resolution)
   "./math" → /project/math.js
     │
     ▼
② 캐시 확인
   이미 로드한 적 있으면 캐시에서 반환
     │
     ├── 캐시 있음 → 캐시된 module.exports 반환 (끝)
     │
     └── 캐시 없음 → 계속
     │
     ▼
③ 파일 읽기
   math.js 파일 내용을 읽음
     │
     ▼
④ 래핑 (Wrapping)
   파일 내용을 함수로 감싸서 독립 스코프 생성
     │
     ▼
⑤ 실행
   래핑된 함수를 실행하여 module.exports 생성
     │
     ▼
⑥ 캐싱
   결과를 캐시에 저장
     │
     ▼
⑦ 반환
   module.exports를 호출자에게 반환
```

### ④ 래핑 상세

```javascript
// 개발자가 작성한 코드
const name = "Kim";
module.exports = name;

// Node.js가 내부적으로 래핑한 코드
(function(exports, require, module, __filename, __dirname) {
    const name = "Kim";
    module.exports = name;
});

// → 이 덕분에:
// - const name이 전역을 오염시키지 않음 (함수 스코프)
// - require, module, exports를 사용할 수 있음
// - __filename, __dirname에 접근 가능
```

### ② 캐싱 — 한 번만 실행

```javascript
// counter.js
let count = 0;
count++;
console.log("counter 로드됨");
module.exports = { getCount: () => count };

// main.js
const a = require("./counter");  // "counter 로드됨" 출력
const b = require("./counter");  // 출력 없음 (캐시에서 반환)
const c = require("./counter");  // 출력 없음

console.log(a === b);  // true — 같은 객체
console.log(b === c);  // true
```

```
첫 번째 require:  파일 읽기 → 실행 → 캐시 저장 → 반환
두 번째 require:  캐시 확인 → 즉시 반환 (실행 안 함)

→ 모듈은 싱글톤처럼 동작
```

## 모듈 경로 해석 규칙

```javascript
require("./math")       // 상대 경로 → 현재 디렉토리의 math.js
require("../utils")     // 상대 경로 → 상위 디렉토리의 utils.js
require("express")      // 패키지명 → node_modules에서 탐색
require("fs")           // 내장 모듈 → Node.js 코어 모듈
```

### 파일 확장자 탐색 순서

```
require("./math")

1. ./math.js          있으면 반환
2. ./math.json         있으면 반환
3. ./math.node         있으면 반환 (C++ 애드온)
4. ./math/index.js     디렉토리인 경우
5. ./math/package.json의 main 필드
```

### node_modules 탐색 순서

```
require("express")

/project/src/node_modules/express      ← 현재 디렉토리부터
/project/node_modules/express          ← 상위로 올라가며 탐색
/node_modules/express                  ← 루트까지
```

## CommonJS의 핵심 특징

### 1. 동기적 로딩

```javascript
// require는 파일을 동기적으로 읽고 실행
const a = require("./a");  // a.js 로드 완료될 때까지 블로킹
const b = require("./b");  // a 완료 후 b 로드
console.log("시작");       // a, b 모두 로드된 후 실행
```

```
실행 순서:
a.js 로드 ████████
b.js 로드          ████████
"시작"                      ██

→ 서버(Node.js)에서는 시작 시 1회만 로드하므로 문제 없음
→ 브라우저에서는 네트워크 I/O를 블로킹하므로 부적합
```

### 2. 값의 복사본 반환

```javascript
// counter.js
let count = 0;
module.exports = { count };

// main.js
const counter = require("./counter");
console.log(counter.count);  // 0

// counter.js에서 count를 변경해도
// main.js의 counter.count는 변하지 않음 (복사본)
```

### 3. 런타임 로딩

```javascript
// 조건부 로딩 가능 — 런타임에 결정
if (process.env.NODE_ENV === "production") {
    const logger = require("./prod-logger");
} else {
    const logger = require("./dev-logger");
}

// 동적 경로도 가능
const moduleName = "math";
const mod = require(`./${moduleName}`);
```

## CommonJS vs ES Modules (ESM)

|항목|CommonJS|ES Modules|
|---|---|---|
|문법|`require` / `module.exports`|`import` / `export`|
|로딩 방식|동기 (블로킹)|비동기|
|실행 시점|런타임|파싱 타임 (정적 분석 가능)|
|값 전달|복사본|참조 (live binding)|
|조건부 로딩|가능|기본 불가 (dynamic import로 가능)|
|Tree Shaking|불가|가능|
|환경|Node.js|브라우저 + Node.js|
|파일 확장자|.js (기본)|.mjs 또는 package.json type:"module"|

### 문법 비교

```javascript
// ── CommonJS ──
const { readFile } = require("fs");
const add = (a, b) => a + b;
module.exports = { add };

// ── ES Modules ──
import { readFile } from "fs";
export const add = (a, b) => a + b;
```

### Tree Shaking 차이

```javascript
// CommonJS — 번들러가 어떤 것을 쓰는지 정적 분석 불가
const utils = require("./utils");   // 전체를 가져옴
utils.add(1, 2);                    // add만 쓰지만 전부 포함

// ES Modules — 정적 분석으로 사용하지 않는 코드 제거 가능
import { add } from "./utils";      // add만 가져옴
add(1, 2);                          // subtract 등은 번들에서 제거
```

```
번들 크기:
CommonJS:  utils.js 전체 포함 (100KB)
ESM:       add 함수만 포함 (2KB)  ← Tree Shaking
```

## 현재 상태와 흐름

```
2009        2015         2020~         현재
─────      ──────       ──────        ──────
CommonJS    ES Modules   Node.js ESM   ESM이 표준
등장        표준 제정     정식 지원      CommonJS는 레거시

브라우저:   ✗            ✓             ✓
Node.js:   ✓ (기본)     ✓ (지원)       ✓ (권장)
번들러:     ✓            ✓ (선호)       ✓ (기본)
```

|상황|권장|
|---|---|
|신규 프로젝트|ESM|
|기존 Node.js 프로젝트|CommonJS 유지 또는 점진적 ESM 전환|
|브라우저|ESM (또는 번들러 사용)|
|npm 라이브러리 배포|둘 다 지원 (dual package)|

## 핵심 정리

CommonJS는 **Node.js의 기본 모듈 시스템**으로, `require()`로 동기적으로 모듈을 로드하고 `module.exports`로 내보냅니다. 파일마다 독립 스코프를 제공하고, 한 번 로드된 모듈은 캐싱되어 싱글톤처럼 동작합니다. 그러나 **동기 로딩, Tree Shaking 불가, 브라우저 미지원**이라는 한계로 인해 현재는 **ES Modules(import/export)**이 표준으로 자리 잡았고, CommonJS는 기존 Node.js 생태계에서 레거시로 유지되고 있습니다.