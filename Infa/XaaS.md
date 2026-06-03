클라우드가 **어디까지 관리해 주느냐**에 따라 서비스 모델을 구분하는 체계로, 책임 경계가 올라갈수록 개발자가 신경 써야 할 인프라 범위는 줄어듭니다.

## 책임 경계 비교

```
[ 온프레미스 → IaaS → PaaS → SaaS ]

                  온프레미스  IaaS   PaaS   SaaS
Application          나       나      나    클라우드
Runtime              나       나    클라우드 클라우드
Middleware           나       나    클라우드 클라우드
OS                   나       나    클라우드 클라우드
Virtualization       나     클라우드 클라우드 클라우드
Servers              나     클라우드 클라우드 클라우드
Storage              나     클라우드 클라우드 클라우드
Networking           나     클라우드 클라우드 클라우드

나 = 직접 관리 / 클라우드 = 벤더가 관리
```

## IaaS (Infrastructure as a Service)

VM, 스토리지, 네트워크 등 **인프라만** 빌려 쓰는 모델. OS부터 위는 직접 구성.

- **예**: AWS EC2, GCP Compute Engine, Azure VM
- **적합**: 기존 온프레미스 앱을 그대로 이전, 세밀한 인프라 제어가 필요한 경우

## PaaS (Platform as a Service)

런타임·미들웨어·OS까지 관리해 주어 **코드만 올리면** 되는 모델. 인프라 걱정 없이 개발에 집중.

- **예**: Google App Engine, Heroku, AWS Elastic Beanstalk, Cloud Run
- **적합**: 빠른 프로토타이핑, 인프라 운영 인력이 없는 스타트업

## SaaS (Software as a Service)

완성된 소프트웨어를 **구독해서 바로 쓰는** 모델. 설치·업그레이드 없이 브라우저로 접근.

- **예**: Gmail, Slack, Notion, Figma, Salesforce
- **적합**: 범용 업무 도구를 직접 개발하지 않을 때

## BaaS (Backend as a Service)

인증·DB·파일 스토리지·푸시 알림 등 **백엔드 공통 기능**을 API로 제공하는 모델. 백엔드 서버를 직접 구축하지 않아도 됨.

- **예**: Firebase, Supabase, AWS Amplify
- **제공 기능**: Auth, Realtime DB, Storage, Push, Analytics
- **적합**: 프론트엔드 중심 팀, MVP 빠른 출시

## MBaaS (Mobile Backend as a Service)

BaaS 중 **모바일 앱** 특화 버전. 모바일 SDK, 오프라인 동기화, 디바이스 푸시 등 모바일 특화 기능 포함.

- **예**: Firebase (가장 대표적), Parse (구 Facebook)
- BaaS의 하위 개념으로, 현재는 Firebase가 BaaS·MBaaS 모두 포괄

## FaaS (Function as a Service)

코드를 **함수 단위로** 배포하고 이벤트 발생 시에만 실행되는 서버리스 모델. 서버 유지 비용 없이 실행 시간만 과금.

- **예**: AWS Lambda, GCP Cloud Functions, Azure Functions
- **특징**: 콜드 스타트 지연, 상태 비보존(stateless), 짧은 실행 시간 권장
- **적합**: 이벤트 기반 처리, 간헐적 트래픽, 데이터 변환 파이프라인

## 전체 비교

| 모델 | 관리 범위 | 대표 예 | 핵심 키워드 |
|---|---|---|---|
| IaaS | 인프라만 제공 | EC2, GCE | VM, 네트워크 |
| PaaS | 런타임까지 제공 | Cloud Run, Heroku | 코드만 배포 |
| SaaS | 완성 SW 제공 | Gmail, Slack | 구독, 바로 사용 |
| BaaS | 백엔드 API 제공 | Firebase, Supabase | Auth, DB, Storage |
| MBaaS | 모바일 특화 BaaS | Firebase | 모바일 SDK, 푸시 |
| FaaS | 함수 단위 실행 | Lambda | 서버리스, 이벤트 |

## 핵심 정리

- **IaaS → PaaS → SaaS** 순으로 클라우드가 더 많이 관리 — 편의성↑, 제어권↓

- **BaaS / MBaaS**: 백엔드 서버 없이 프론트만으로 서비스 출시 가능 (Firebase가 사실상 표준)

- **FaaS**: 서버 없이 함수만 배포, 이벤트 발생 시에만 실행 — 콜드 스타트가 단점

- 실무에서는 혼합 사용 → PaaS(Cloud Run)로 메인 서버 + FaaS(Lambda)로 비동기 처리 + BaaS(Supabase)로 Auth

