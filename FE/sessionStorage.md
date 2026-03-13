브라우저에 **탭/창이 열려있는 동안만 데이터를 저장하는 클라이언트 사이드 저장소**입니다.

## localStorage와의 차이

```
localStorage
→ 브라우저 닫아도 영구 유지
→ 같은 출처의 모든 탭에서 공유

sessionStorage
→ 탭/창 닫으면 데이터 삭제
→ 탭마다 독립적으로 존재 (공유 안 됨)
```

## 기본 사용법

```javascript
// localStorage와 API 동일
sessionStorage.setItem('key', 'value');
sessionStorage.getItem('key');
sessionStorage.removeItem('key');
sessionStorage.clear();
```

## 탭 독립성 - 핵심 특징

```
탭A: sessionStorage.setItem('user', 'kim')
탭B: sessionStorage.getItem('user')  → null ❌

localStorage였다면
탭A: localStorage.setItem('user', 'kim')
탭B: localStorage.getItem('user')  → 'kim' ✅
```

## 브라우저 저장소 최종 비교

||localStorage|sessionStorage|Cookie|
|---|---|---|---|
|**유지 기간**|영구|탭 닫으면 삭제|만료일 설정|
|**탭 간 공유**|✅|❌|✅|
|**용량**|~5MB|~5MB|~4KB|
|**서버 전송**|❌|❌|✅ 자동|
|**XSS 취약**|❌|❌|HttpOnly 시 안전|

## 적합한 사용 사례

```
✅ 적합
- 페이지 이동 간 임시 데이터 유지 (멀티 스텝 폼)
- 탭별 독립적인 상태 (여러 탭에서 다른 계정 조회)
- 새로고침해도 유지해야 할 일시적 데이터

❌ 부적합
- 탭 간 공유가 필요한 데이터 → localStorage
- 서버에 전달해야 할 데이터 → Cookie
- 탭 닫아도 유지해야 할 데이터 → localStorage
```

## 활용 예시 - 멀티 스텝 폼

```javascript
// 회원가입 1단계
sessionStorage.setItem('step1', JSON.stringify({
    name: 'kim',
    email: 'kim@test.com'
}));

// 회원가입 2단계 - 이전 데이터 유지
const step1Data = JSON.parse(sessionStorage.getItem('step1'));

// 가입 완료 후 세션 정리
sessionStorage.clear();
// → 탭 닫으면 어차피 자동 삭제
```

> sessionStorage는 **"탭 단위로 독립적인 임시 데이터가 필요할 때"** 사용합니다. localStorage보다 생명주기가 짧아 민감도가 낮은 임시 데이터에 상대적으로 안전하지만, 여전히 JS로 접근 가능하므로 인증 정보 저장은 피해야 합니다.
