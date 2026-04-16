웹 브라우저에서 **다른 출처(Origin)의 리소스에 접근하는 것을 기본적으로 차단**하는 보안 정책입니다.

## 출처(Origin)란?

```
https://www.example.com:443/path

프로토콜: https
호스트:   www.example.com
포트:     443

→ 이 3가지가 모두 같아야 같은 출처
```

## 같은 출처 vs 다른 출처

```
기준: https://www.example.com

https://www.example.com/api      ✅ 같은 출처 (경로만 다름)
http://www.example.com           ❌ 다른 출처 (프로토콜 다름)
https://api.example.com          ❌ 다른 출처 (호스트 다름)
https://www.example.com:8080     ❌ 다른 출처 (포트 다름)
https://www.other.com            ❌ 다른 출처 (호스트 다름)
```

## 왜 필요한가?

```
SOP 없다면

악성 사이트(evil.com) 접속
→ evil.com이 JS로 mybank.com에 요청
→ 내 쿠키/세션으로 계좌 정보 탈취 💀

SOP 있으면
→ evil.com → mybank.com 요청 차단 ✅
```

## SOP가 차단하는 것

```
❌ 다른 출처 AJAX 요청 결과 읽기
❌ 다른 출처 iframe 내용 접근
❌ 다른 출처 쿠키/localStorage 접근
```

## SOP가 차단 안 하는 것

```
✅ <img src="다른출처/image.png">   → 이미지 로드
✅ <script src="다른출처/js">       → 스크립트 로드
✅ <link href="다른출처/css">       → CSS 로드
✅ <form action="다른출처">         → 폼 전송
```

## 해결 방법

```
SOP를 완화하는 방법
→ CORS (Cross-Origin Resource Sharing)
   서버가 허용한 출처에서는 접근 가능하도록 설정
```

> SOP는 **브라우저의 보안 정책**으로, 서버끼리의 통신에는 적용되지 않습니다. 프론트엔드에서 다른 출처 API를 호출할 때 막히는 이유가 바로 SOP 때문입니다.
