프론트엔드에서 컴포넌트, 함수, 훅 등의 최소 단위가 독립적으로 올바르게 동작하는지 검증하는 테스트입니다.

## 프론트엔드 유닛 테스트 대상

|대상|예시|
|---|---|
|**유틸 함수**|날짜 포맷팅, 금액 변환, 유효성 검사|
|**컴포넌트**|버튼 클릭 시 동작, 조건부 렌더링|
|**커스텀 훅**|상태 변경, API 호출 로직|
|**상태 관리**|Redux reducer, Zustand store|

## 대표 도구

|도구|역할|
|---|---|
|**Jest**|테스트 러너 + assertion 라이브러리|
|**React Testing Library**|사용자 관점에서 컴포넌트 테스트|
|**Vitest**|Vite 기반 프로젝트에 최적화된 테스트 러너|

## 테스트 예시

### 1. 유틸 함수 테스트

```javascript
// formatPrice.js
export const formatPrice = (price) => {
  return price.toLocaleString() + '원';
};

// formatPrice.test.js
describe('formatPrice', () => {
  test('금액에 콤마와 원을 붙인다', () => {
    expect(formatPrice(10000)).toBe('10,000원');
  });

  test('0원을 올바르게 처리한다', () => {
    expect(formatPrice(0)).toBe('0원');
  });
});
```

### 2. 컴포넌트 테스트 (React Testing Library)

```javascript
// LoginButton.jsx
export const LoginButton = ({ isLoggedIn, onLogin, onLogout }) => {
  return isLoggedIn
    ? <button onClick={onLogout}>로그아웃</button>
    : <button onClick={onLogin}>로그인</button>;
};

// LoginButton.test.jsx
import { render, screen, fireEvent } from '@testing-library/react';

describe('LoginButton', () => {
  test('로그아웃 상태이면 로그인 버튼을 보여준다', () => {
    render(<LoginButton isLoggedIn={false} onLogin={() => {}} />);
    expect(screen.getByText('로그인')).toBeInTheDocument();
  });

  test('로그인 버튼 클릭 시 onLogin이 호출된다', () => {
    const onLogin = jest.fn();
    render(<LoginButton isLoggedIn={false} onLogin={onLogin} />);
    fireEvent.click(screen.getByText('로그인'));
    expect(onLogin).toHaveBeenCalledTimes(1);
  });
});
```

### 3. 커스텀 훅 테스트

```javascript
// useCounter.js
import { useState } from 'react';
export const useCounter = (initial = 0) => {
  const [count, setCount] = useState(initial);
  const increment = () => setCount(c => c + 1);
  return { count, increment };
};

// useCounter.test.js
import { renderHook, act } from '@testing-library/react';

describe('useCounter', () => {
  test('초기값이 올바르게 설정된다', () => {
    const { result } = renderHook(() => useCounter(5));
    expect(result.current.count).toBe(5);
  });

  test('increment 호출 시 count가 1 증가한다', () => {
    const { result } = renderHook(() => useCounter(0));
    act(() => result.current.increment());
    expect(result.current.count).toBe(1);
  });
});
```

## BE vs FE 유닛 테스트 차이

|항목|BE (Java)|FE (React)|
|---|---|---|
|테스트 대상|Service, Repository|컴포넌트, 훅, 유틸 함수|
|Mock 대상|DB, 외부 API|API 호출, 브라우저 API|
|도구|JUnit, Mockito|Jest, React Testing Library|
|검증 관점|비즈니스 로직 결과|렌더링 결과 + 사용자 인터랙션|
