JavaScript에서 **비동기 작업의 완료 또는 실패를 나타내는 객체**로, 콜백 지옥을 해결하고 비동기 흐름을 체이닝 방식으로 깔끔하게 제어할 수 있게 해줍니다.

## 핵심 개념

|항목|내용|
|---|---|
|**역할**|비동기 작업의 결과를 나중에 받겠다는 "약속"|
|**도입**|ES6 (2015)|
|**상태**|Pending → Fulfilled 또는 Rejected (한 번 결정되면 변경 불가)|
|**체이닝**|`.then()`, `.catch()`, `.finally()`로 연결|

## Promise의 3가지 상태

```
                    ┌──── resolve(값) ────→ Fulfilled (이행)
                    │                      → .then(값 처리)
Pending (대기) ─────┤
  (비동기 작업 중)    │
                    └──── reject(에러) ───→ Rejected (거부)
                                           → .catch(에러 처리)

※ 한 번 Fulfilled 또는 Rejected가 되면 다시 변경 불가 (불변)
```

```
Pending ──→ Fulfilled ──→ .then()
   │
   └─────→ Rejected ───→ .catch()
                              │
                              └─→ .finally() (성공·실패 무관하게 실행)
```

## 기본 사용법

### Promise 생성

```javascript
const promise = new Promise((resolve, reject) => {
    // 비동기 작업 수행
    const success = true;

    if (success) {
        resolve("성공 데이터");   // Fulfilled 상태로 변경
    } else {
        reject("에러 발생");      // Rejected 상태로 변경
    }
});

// 결과 처리
promise
    .then(data => console.log(data))     // "성공 데이터"
    .catch(error => console.error(error))
    .finally(() => console.log("완료"));  // 항상 실행
```

### 실제 비동기 예시

```javascript
function fetchUser(id) {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            if (id > 0) {
                resolve({ id, name: "홍길동" });
            } else {
                reject(new Error("유효하지 않은 ID"));
            }
        }, 1000);  // 1초 후 완료
    });
}

fetchUser(1)
    .then(user => console.log(user))      // { id: 1, name: "홍길동" }
    .catch(error => console.error(error));

fetchUser(-1)
    .then(user => console.log(user))
    .catch(error => console.error(error)); // Error: 유효하지 않은 ID
```

## 콜백 지옥 vs Promise 체이닝

### 콜백 지옥 (Callback Hell)

```javascript
// ❌ 콜백 중첩 → 가독성 최악, 에러 처리 어려움
getUser(1, function(user) {
    getOrders(user.id, function(orders) {
        getOrderDetail(orders[0].id, function(detail) {
            getProduct(detail.productId, function(product) {
                console.log(product);
                // 에러 처리는 각 콜백마다 해야 함
            }, function(err) { console.error(err); });
        }, function(err) { console.error(err); });
    }, function(err) { console.error(err); });
}, function(err) { console.error(err); });
```

### Promise 체이닝

```javascript
// ✅ 깔끔한 체이닝 + 에러 처리 일원화
getUser(1)
    .then(user => getOrders(user.id))
    .then(orders => getOrderDetail(orders[0].id))
    .then(detail => getProduct(detail.productId))
    .then(product => console.log(product))
    .catch(error => console.error(error));  // 에러 처리 한곳에서
```

```
[콜백 지옥]                    [Promise 체이닝]

작업1(결과 → {                  작업1()
  작업2(결과 → {                  .then(결과 → 작업2())
    작업3(결과 → {                .then(결과 → 작업3())
      작업4(결과 → {              .then(결과 → 작업4())
        // 완료                   .then(결과 => // 완료)
      })                         .catch(에러 => // 처리)
    })
  })
})
```

## 체이닝 동작 원리

`.then()`은 **새로운 Promise를 반환**하므로 체이닝이 가능합니다.

```javascript
Promise.resolve(1)
    .then(value => {
        console.log(value);    // 1
        return value + 1;      // 새 Promise(Fulfilled: 2) 반환
    })
    .then(value => {
        console.log(value);    // 2
        return value * 3;      // 새 Promise(Fulfilled: 6) 반환
    })
    .then(value => {
        console.log(value);    // 6
    });
```

```
then()이 반환하는 값에 따른 동작:

return 값          → 다음 then()에 값 전달
return Promise     → 해당 Promise가 해결될 때까지 대기
throw Error        → catch()로 이동
return 없음        → undefined 전달
```

## 에러 처리

```javascript
// 1. catch() — 체인 전체의 에러를 한곳에서 처리
fetchData()
    .then(data => process(data))
    .then(result => save(result))
    .catch(error => {
        // 위 어디서든 에러 발생 시 여기로
        console.error("에러:", error.message);
    });

// 2. then의 두 번째 인자 vs catch
promise.then(
    data => console.log(data),     // 성공
    error => console.error(error)  // 실패 (이 then에서 발생한 에러만)
);

// catch는 체인 전체의 에러를 잡으므로 catch 사용이 권장됨

// 3. finally — 성공·실패 무관하게 항상 실행
fetchData()
    .then(data => console.log(data))
    .catch(error => console.error(error))
    .finally(() => {
        hideLoadingSpinner();  // 로딩 스피너 숨기기
    });
```

## Promise 정적 메서드

### Promise.all — 모두 성공해야

```javascript
const p1 = fetch("/api/users");
const p2 = fetch("/api/orders");
const p3 = fetch("/api/products");

// 모든 Promise가 Fulfilled되면 결과 배열 반환
// 하나라도 Rejected되면 즉시 catch로
Promise.all([p1, p2, p3])
    .then(([users, orders, products]) => {
        console.log("모두 성공", users, orders, products);
    })
    .catch(error => {
        console.error("하나라도 실패:", error);
    });
```

### Promise.allSettled — 결과 상관없이 모두 완료 대기

```javascript
Promise.allSettled([p1, p2, p3])
    .then(results => {
        results.forEach(result => {
            if (result.status === "fulfilled") {
                console.log("성공:", result.value);
            } else {
                console.log("실패:", result.reason);
            }
        });
    });
```

### Promise.race — 가장 빠른 하나

```javascript
// 가장 먼저 완료(성공 또는 실패)된 Promise의 결과 반환
const timeout = new Promise((_, reject) =>
    setTimeout(() => reject(new Error("타임아웃")), 3000)
);

Promise.race([fetch("/api/data"), timeout])
    .then(response => console.log("응답 수신"))
    .catch(error => console.error("3초 초과"));
```

### Promise.any — 하나라도 성공하면

```javascript
// 가장 먼저 성공한 Promise의 결과 반환
// 모두 실패해야 catch
Promise.any([
    fetch("https://server1.com/api"),
    fetch("https://server2.com/api"),
    fetch("https://server3.com/api"),
])
    .then(response => console.log("가장 빠른 성공:", response))
    .catch(error => console.error("모두 실패"));
```

### 정적 메서드 비교

|메서드|성공 조건|실패 조건|용도|
|---|---|---|---|
|`Promise.all`|모두 성공|하나라도 실패|병렬 작업 후 합산|
|`Promise.allSettled`|항상 완료 대기|실패 없음|결과와 무관하게 모두 대기|
|`Promise.race`|가장 빠른 하나|가장 빠른 게 실패|타임아웃 구현|
|`Promise.any`|하나라도 성공|모두 실패|가장 빠른 성공 서버|

## Promise vs async/await

```javascript
// Promise 체이닝
function getUserData(id) {
    return getUser(id)
        .then(user => getOrders(user.id))
        .then(orders => getOrderDetail(orders[0].id))
        .then(detail => detail)
        .catch(error => console.error(error));
}

// async/await (Promise의 문법적 설탕)
async function getUserData(id) {
    try {
        const user = await getUser(id);
        const orders = await getOrders(user.id);
        const detail = await getOrderDetail(orders[0].id);
        return detail;
    } catch (error) {
        console.error(error);
    }
}
```

|항목|Promise 체이닝|async/await|
|---|---|---|
|**가독성**|체인이 길면 복잡|동기 코드처럼 읽힘|
|**에러 처리**|`.catch()`|`try/catch`|
|**디버깅**|스택 트레이스 파악 어려움|일반 함수처럼 디버깅 가능|
|**병렬 처리**|`Promise.all` 사용|`await Promise.all` 사용|
|**본질**|Promise 직접 사용|Promise 기반 문법적 설탕|

## [[마이크로태스크 큐]]

Promise의 콜백(`.then`)은 일반 콜백(setTimeout)보다 **먼저 실행**됩니다.

```javascript
console.log("1");

setTimeout(() => console.log("2"), 0);       // 매크로태스크 큐

Promise.resolve().then(() => console.log("3")); // 마이크로태스크 큐

console.log("4");

// 출력 순서: 1 → 4 → 3 → 2
```

```
Call Stack 비움
    │
    ▼
마이크로태스크 큐 (Promise.then) ← 먼저 실행
    │
    ▼
매크로태스크 큐 (setTimeout) ← 나중에 실행
```
