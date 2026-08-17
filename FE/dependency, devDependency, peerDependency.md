---
title: "dependency, devDependency, peerDependency"
tags: [npm, 패키지매니저, 의존성]
status: published
---

npm이 `package.json`에서 패키지의 용도에 따라 구분하는 세 가지 의존성 유형입니다.

## 핵심 특징

- **dependency**: 프로덕션 환경에서도 필요한 패키지입니다. `react`처럼 애플리케이션 실행에 직접적인 영향을 미치는 패키지가 해당하며, 배포 환경에도 함께 설치됩니다.
- **devDependency**: 개발 과정에서만 필요한 패키지입니다. `eslint`, `jest`, `webpack`처럼 코드 품질 검증, 테스트, 번들링에 쓰이지만 실제 서비스 운영에는 불필요해 프로덕션 환경에는 설치되지 않습니다.
- **peerDependency**: 호환성을 위해 특정 버전의 다른 패키지가 필요하다는 사실만 명시하는 의존성입니다. 주로 라이브러리 개발 시 사용하며, 직접 설치되지 않고 사용하는 쪽의 패키지 버전에 맞춰 호환성 문제를 줄입니다.

## 잘못 설정했을 때 문제

- `devDependency`에 있어야 할 패키지를 `dependency`에 넣으면 배포된 애플리케이션 크기가 불필요하게 커지고, 보안 취약점이 늘어날 수 있습니다.
- 반대로 `dependency`에 있어야 할 패키지를 `devDependency`에 넣으면, 운영 환경에서 해당 패키지가 누락되어 애플리케이션이 정상적으로 실행되지 않을 수 있습니다.

## 사용 예 (package.json)

```json
{
  "dependencies": {
    "react": "^18.2.0"
  },
  "devDependencies": {
    "eslint": "^8.0.0",
    "jest": "^29.0.0"
  },
  "peerDependencies": {
    "react": ">=17.0.0"
  }
}
```

관련 명령어는 [[npm install과 npm ci]] 참고.

## 핵심 정리

dependency는 실행에, devDependency는 개발에만 필요한 패키지를 구분하고, peerDependency는 사용하는 쪽 패키지와의 버전 호환성을 명시합니다.

→ [[dependency, devDependency, peerDependency에 대해서 설명해주세요]]
