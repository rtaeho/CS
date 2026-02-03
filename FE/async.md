JavaScript에서 **비동기 작업을 동기 코드처럼 읽기 쉽게 작성할 수 있게 해주는 키워드**입니다.

## 왜 필요한가

### 비동기의 근본 문제

```
[ 동기 — 순서대로 실행, 기다림 ]
서버에 데이터 요청 → 3초 대기 → 응답 받음 → 다음 코드 실행
                      ↑ 이 동안 화면이 멈춤 (블로킹)

[ 비동기 — 기다리지 않고 다음으로 넘어감 ]
서버에 데이터 요청 → 다음 코드 즉시 실행 → ... → 응답 오면 처리
                     ↑ 화면이 멈추지 않음
```

비동기는 필수지만, 코드 작성이 복잡해지는 문제가 있었습니다.

## 비동기 처리 방식의 진화

### 1단계: 콜백 (Callback)

```javascript
// 콜백 지옥 (Callback Hell)
getUser(1, function(user) {
    getOrders(user.id, function(orders) {
        getProduct(orders[0].productId, function(product) {
            getReview(product.id, function(reviews) {
                console.log(reviews);
                // 계속 깊어짐...
            });
        });
    });
});
```

```
문제:
├── 가독성 최악 (들여쓰기 지옥)
├── 에러 처리 어려움
└── 흐름 파악 불가
```

### 2단계: Promise

```javascript
getUser(1)
    .then(user => getOrders(user.id))
    .then(orders => getProduct(orders[0].productId))
    .then(product => getReview(product.id))
    .then(reviews => console.log(reviews))
    .catch(error => console.error(error));
```

```
개선:
├── 들여쓰기 해소
├── 체이닝으로 순서 명확
└── catch로 에러 처리 통합

남은 문제:
├── 여전히 then 체이닝이 길어지면 복잡
└── 동기 코드처럼 자연스럽지 않음
```

### 3단계: async/await

```javascript
async function getReviewData() {
    const user = await getUser(1);
    const orders = await getOrders(user.id);
    const product = await getProduct(orders[0].productId);
    const reviews = await getReview(product.id);
    console.log(reviews);
}
```

```
개선:
├── 동기 코드와 거의 동일한 형태
├── 위에서 아래로 읽으면 흐름 파악 가능
└── try/catch로 익숙한 에러 처리
```

## async/await 기본 문법

### async 함수 선언

```javascript
// async를 붙이면 항상 Promise를 반환
async function fetchData() {
    return "hello";
}

// 위 코드는 아래와 동일
function fetchData() {
    return Promise.resolve("hello");
}

fetchData().then(data => console.log(data));  // "hello"
```

### await 키워드

```javascript
async function example() {
    // await는 Promise가 완료될 때까지 "기다린 것처럼" 동작
    const response = await fetch("/api/users");
    const data = await response.json();
    console.log(data);
}
```

```
await의 동작:

const data = await fetch("/api/users");

실제로 스레드를 멈추는 것이 아님
→ Promise가 완료되면 나머지 코드를 재개하도록 등록
→ 그동안 브라우저는 다른 작업 가능 (이벤트 처리, 렌더링 등)
```

### await는 async 함수 안에서만 사용 가능

```javascript
// ✓ 정상
async function foo() {
    const data = await fetchData();
}

// ✗ 에러 — 일반 함수에서 await 사용 불가
function bar() {
    const data = await fetchData();  // SyntaxError
}

// ✓ 최상위 레벨 await (ES2022, 모듈에서만)
const data = await fetchData();
```

## 에러 처리

### Promise — catch 체이닝

```javascript
fetchData()
    .then(data => process(data))
    .then(result => save(result))
    .catch(error => console.error(error));
```

### async/await — try/catch

```javascript
async function handleData() {
    try {
        const data = await fetchData();
        const result = await process(data);
        await save(result);
    } catch (error) {
        console.error("에러 발생:", error);
    } finally {
        console.log("완료");
    }
}
```

## 실행 흐름 상세

```javascript
async function main() {
    console.log("1");
    const data = await fetch("/api");
    console.log("2");
}

console.log("A");
main();
console.log("B");
```

```
출력 순서: A → 1 → B → 2

A        console.log("A")          동기 실행
1        main() 진입, console.log("1")  동기 실행
         await fetch("/api")       여기서 main 일시 중단
B        console.log("B")          main 밖의 코드 계속 실행
         ... fetch 응답 도착 ...
2        console.log("2")          main 재개
```

```
┌─── 콜 스택 ──────────────────────────────────┐
│                                                │
│  console.log("A")   → 실행                    │
│  main()             → 진입                    │
│  console.log("1")   → 실행                    │
│  await fetch(...)   → main을 콜 스택에서 제거  │
│  console.log("B")   → 실행                    │
│                                                │
│  ... fetch 완료 후 ...                         │
│                                                │
│  main 재개           → 콜 스택에 복귀           │
│  console.log("2")   → 실행                    │
└────────────────────────────────────────────────┘
```

## 병렬 실행

### 순차 실행 — 느림

```javascript
async function sequential() {
    const user = await getUser();      // 1초
    const orders = await getOrders();  // 1초
    const reviews = await getReviews(); // 1초
    // 총 3초
}
```

```
getUser   ██████████
getOrders            ██████████
getReviews                      ██████████
                                          총 3초
```

### 병렬 실행 — Promise.all

```javascript
async function parallel() {
    const [user, orders, reviews] = await Promise.all([
        getUser(),      // 1초
        getOrders(),    // 1초
        getReviews()    // 1초
    ]);
    // 총 1초
}
```

```
getUser   ██████████
getOrders ██████████
getReviews██████████
                    총 1초 (가장 긴 것 기준)
```

### Promise.allSettled — 하나가 실패해도 나머지 결과 받기

```javascript
async function resilient() {
    const results = await Promise.allSettled([
        getUser(),
        getOrders(),
        getReviews()
    ]);

    results.forEach(result => {
        if (result.status === "fulfilled") {
            console.log("성공:", result.value);
        } else {
            console.log("실패:", result.reason);
        }
    });
}
```

## 자주 하는 실수

### 1. 불필요한 순차 실행

```javascript
// ✗ 서로 의존성 없는데 순차 실행
async function bad() {
    const user = await getUser();
    const config = await getConfig();   // user와 무관한데 기다림
}

// ✓ 병렬 실행
async function good() {
    const [user, config] = await Promise.all([
        getUser(),
        getConfig()
    ]);
}
```

### 2. forEach에서 await 무시

```javascript
// ✗ await가 작동하지 않음
const ids = [1, 2, 3];
ids.forEach(async (id) => {
    await processItem(id);   // forEach는 await를 기다리지 않음
});

// ✓ for...of 사용 (순차)
for (const id of ids) {
    await processItem(id);
}

// ✓ Promise.all 사용 (병렬)
await Promise.all(ids.map(id => processItem(id)));
```

### 3. await 빠뜨리기

```javascript
// ✗ await 빠뜨림 — data는 Promise 객체
async function bad() {
    const data = fetch("/api");        // Promise 객체가 담김
    console.log(data);                  // Promise { <pending> }
}

// ✓ await로 결과값 받기
async function good() {
    const response = await fetch("/api");
    const data = await response.json();
    console.log(data);                  // 실제 데이터
}
```

## async/await의 본질

```
async/await는 Promise의 문법적 설탕(Syntactic Sugar)

// 이 코드는
async function foo() {
    const a = await bar();
    return a + 1;
}

// 내부적으로 이렇게 동작
function foo() {
    return bar().then(a => a + 1);
}
```

```
async/await      →  작성하기 쉬움 (개발자용)
     │
     ▼ 변환
Promise          →  실제 동작 방식 (엔진 내부)
     │
     ▼ 기반
Event Loop       →  비동기 실행의 근본 메커니즘
```

## 핵심 정리

async/await는 **Promise 기반 비동기 코드를 동기 코드처럼 읽기 쉽게 작성하는 문법**입니다. async 함수는 항상 Promise를 반환하고, await는 Promise 완료를 기다리는 것처럼 동작하지만 **실제로 스레드를 블로킹하지 않습니다.** 서로 의존성이 없는 비동기 작업은 `Promise.all`로 병렬 실행해야 성능을 극대화할 수 있으며, forEach 안에서는 await가 작동하지 않으므로 `for...of` 또는 `Promise.all + map`을 사용해야 합니다.