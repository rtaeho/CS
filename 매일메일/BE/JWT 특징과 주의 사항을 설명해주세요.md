---
title: "JWT 특징과 주의 사항을 설명해주세요"
tags: [매일메일, Backend]
status: published
---

[[JWT]]는 JSON 형식의 클레임을 안전하게 전달하기 위한 토큰 형식입니다. 일반적으로 [[인증]]과 [[인가]]를 구현할 때 사용합니다.

## 구조

JWT는 Header, Payload, Signature로 구성됩니다.

```text
Header.Payload.Signature
```

Header에는 토큰 타입과 서명 알고리즘이 들어가고, Payload에는 만료 시간, 사용자 ID, 권한 같은 클레임이 들어갑니다. Signature는 Header와 Payload가 변조되지 않았는지 검증하는 데 사용합니다.

## 특징

- 토큰 자체에 필요한 정보를 포함할 수 있습니다.
- 서버가 세션 상태를 저장하지 않아도 되는 Stateless 인증에 적합합니다.
- 서버가 여러 대인 환경에서도 세션 불일치 문제를 줄일 수 있습니다.
- 서명을 통해 토큰 변조 여부를 검증할 수 있습니다.

## 주의사항

JWT의 Payload는 쉽게 디코딩할 수 있으므로 민감 정보를 담으면 안 됩니다. 비밀 키는 충분히 복잡해야 하며 안전한 공간에서 관리해야 합니다.

토큰이 탈취되면 만료 전까지 사용될 수 있으므로 짧은 Access Token 만료 시간, Refresh Token Rotation, 탈취 감지, 블랙리스트 전략 등을 고려해야 합니다.

또한 `none` 알고리즘 공격처럼 서명 검증을 우회하려는 공격에 대비해 검증 라이브러리 설정을 확인해야 합니다.

## 정리

JWT는 서버 확장성과 Stateless 인증에 유리하지만, 탈취와 민감 정보 노출, 즉시 무효화 어려움 같은 단점이 있습니다. 따라서 짧은 만료 시간, 안전한 저장소, 강한 키 관리, Refresh Token 전략이 함께 필요합니다.

## 추가 학습 자료

- [직접 만들어보며 이해하는 JWT](https://hudi.blog/self-made-jwt/)
- [Refresh Token과 Sliding Sessions를 활용한 JWT의 보안 전략](https://blog.ull.im/engineering/2019/02/07/jwt-strategy.html)
- [Auth0 - Refresh Token Rotation](https://auth0.com/docs/secure/tokens/refresh-tokens/refresh-token-rotation)
