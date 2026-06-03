**비동기 작업(fetch, 이벤트 리스너 등)을 외부에서 취소할 수 있게 해주는 웹 API**입니다.

## 핵심 구조

```
AbortController
  ├── signal: AbortSignal  ← fetch나 이벤트에 전달하는 취소 신호
  └── abort(): void        ← 호출 시 signal.aborted = true, abort 이벤트 발생
```

## fetch 취소

```javascript
const controller = new AbortController()

// fetch에 signal 전달
fetch('/api/data', { signal: controller.signal })
  .then(res => res.json())
  .then(data => console.log(data))
  .catch(err => {
    if (err.name === 'AbortError') {
      console.log('요청이 취소됨')   // 정상 취소 — 에러가 아님
    } else {
      console.error('네트워크 오류', err)
    }
  })

// 취소 실행
controller.abort()
```

## React에서의 활용 — useEffect 클린업

```javascript
useEffect(() => {
  const controller = new AbortController()

  fetch('/api/posts', { signal: controller.signal })
    .then(res => res.json())
    .then(data => setPosts(data))
    .catch(err => {
      if (err.name !== 'AbortError') throw err
    })

  // 컴포넌트 언마운트 or 의존성 변경 시 요청 취소
  return () => controller.abort()
}, [userId])
```

> React Strict Mode에서 useEffect가 두 번 실행될 때, 첫 번째 실행의 fetch를 취소하지 않으면 stale 응답이 상태에 반영될 수 있음.

## 타임아웃 구현

```javascript
// AbortSignal.timeout() — 일정 시간 후 자동 취소 (모던 API)
fetch('/api/data', { signal: AbortSignal.timeout(5000) })

// 수동 타임아웃
const controller = new AbortController()
const timeoutId = setTimeout(() => controller.abort(), 5000)

fetch('/api/data', { signal: controller.signal })
  .finally(() => clearTimeout(timeoutId))
```

## abort 이벤트 감지

```javascript
const controller = new AbortController()

controller.signal.addEventListener('abort', () => {
  console.log('취소됨:', controller.signal.reason)
})

controller.abort('사용자가 취소')  // reason 전달 가능
```

## 여러 요청을 한 번에 취소

```javascript
const controller = new AbortController()

// 같은 signal을 여러 fetch에 공유
Promise.all([
  fetch('/api/a', { signal: controller.signal }),
  fetch('/api/b', { signal: controller.signal }),
  fetch('/api/c', { signal: controller.signal }),
])

// 한 번의 abort()로 전부 취소
controller.abort()
```

## 핵심 정리

- `controller.signal`을 fetch에 전달, `controller.abort()`로 취소 — abort 시 `AbortError` 발생

- React `useEffect` 클린업에서 반드시 `abort()` 호출 — 언마운트 후 stale 상태 업데이트 방지

- 취소는 정상 흐름 — `err.name === 'AbortError'` 분기로 네트워크 에러와 구분해야 함

→ [[비동기]] | [[Promise]]

