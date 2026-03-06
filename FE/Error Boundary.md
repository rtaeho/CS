React에서 **하위 컴포넌트 트리에서 발생한 JavaScript 에러를 잡아 앱 전체가 crash되는 것을 방지하는 컴포넌트**입니다.

## 핵심 개념

```
에러 없을 때
App → ErrorBoundary → ComponentA → ComponentB ✅

에러 발생 시 (ErrorBoundary 없음)
App → ComponentA → ComponentB 💥 → 앱 전체 흰 화면

에러 발생 시 (ErrorBoundary 있음)
App → ErrorBoundary → ComponentB 💥
                  ↓
           Fallback UI 렌더링 ✅ (나머지 앱은 정상)
```

## 기본 구현

Error Boundary는 **클래스 컴포넌트**로만 구현 가능합니다.

```jsx
class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  // 에러 발생 시 state 업데이트
  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  // 에러 로깅
  componentDidCatch(error, errorInfo) {
    console.error("에러 발생:", error, errorInfo);
    // Sentry 등 에러 모니터링 서비스로 전송
  }

  render() {
    if (this.state.hasError) {
      return <h1>문제가 발생했습니다.</h1>;  // Fallback UI
    }
    return this.props.children;
  }
}

// 사용
function App() {
  return (
    <ErrorBoundary>
      <UserProfile />   {/* 에러 발생해도 앱 전체 crash 방지 */}
    </ErrorBoundary>
  );
}
```

## 부분적 적용 - 핵심 활용법

```jsx
function App() {
  return (
    <div>
      <Header />  {/* ErrorBoundary 밖 → 항상 정상 렌더링 */}

      <ErrorBoundary fallback={<p>피드 로딩 실패</p>}>
        <Feed />        {/* 에러 발생 시 Fallback만 표시 */}
      </ErrorBoundary>

      <ErrorBoundary fallback={<p>추천 로딩 실패</p>}>
        <Recommendations />  {/* 독립적으로 에러 처리 */}
      </ErrorBoundary>
    </div>
  );
}
```

## Error Boundary가 잡지 못하는 에러

```jsx
// ❌ 잡지 못하는 경우
1. 이벤트 핸들러
   <button onClick={() => { throw new Error() }}>  // try-catch로 직접 처리

2. 비동기 코드
   setTimeout(() => { throw new Error() }, 1000)   // try-catch로 직접 처리

3. SSR (서버사이드 렌더링)

4. Error Boundary 자체에서 발생한 에러
```

## react-error-boundary 라이브러리

함수형 컴포넌트에서 편리하게 사용할 수 있는 라이브러리입니다.

```jsx
import { ErrorBoundary } from 'react-error-boundary';

function ErrorFallback({ error, resetErrorBoundary }) {
  return (
    <div>
      <p>에러 발생: {error.message}</p>
      <button onClick={resetErrorBoundary}>다시 시도</button>  {/* 재시도 기능 */}
    </div>
  );
}

function App() {
  return (
    <ErrorBoundary
      FallbackComponent={ErrorFallback}
      onError={(error) => console.error(error)}  // 에러 로깅
    >
      <UserProfile />
    </ErrorBoundary>
  );
}
```

## getDerivedStateFromError vs componentDidCatch

|메서드|호출 시점|용도|
|---|---|---|
|`getDerivedStateFromError`|렌더링 중|Fallback UI 표시 (state 업데이트)|
|`componentDidCatch`|커밋 후|에러 로깅, 모니터링 서비스 전송|

> Error Boundary는 **앱의 일부가 실패해도 나머지는 정상 동작**하도록 격리하는 것이 핵심입니다. 중요도에 따라 컴포넌트 단위로 세분화해서 적용하는 것이 좋습니다.