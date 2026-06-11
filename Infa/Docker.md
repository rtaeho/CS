애플리케이션과 그 실행 환경을 **컨테이너**라는 격리된 단위로 패키징해 어디서든 동일하게 실행할 수 있게 해주는 플랫폼입니다.

## 핵심 개념

- **이미지(Image)**: 컨테이너를 만들기 위한 읽기 전용 템플릿 (레이어 구조)
- **컨테이너(Container)**: 이미지를 실행한 인스턴스, 격리된 프로세스
- **Dockerfile**: 이미지를 빌드하는 명령어 스크립트
- **레지스트리(Registry)**: 이미지를 저장·배포하는 저장소 (Docker Hub, GCR, ECR)

## VM vs 컨테이너

```
[ VM ]                         [ 컨테이너 ]

┌─────────┬─────────┐          ┌──────┬──────┐
│  App A  │  App B  │          │App A │App B │
├─────────┼─────────┤          ├──────┴──────┤
│Guest OS │Guest OS │          │  컨테이너 런타임  │
├─────────┴─────────┤          ├─────────────┤
│    Hypervisor     │          │    Host OS  │
├───────────────────┤          ├─────────────┤
│     Host OS       │          │  Hardware   │
├───────────────────┤          └─────────────┘
│     Hardware      │
└───────────────────┘
```

| 항목 | VM | 컨테이너 |
|---|---|---|
| 격리 단위 | OS 전체 | 프로세스 |
| 부팅 시간 | 분 단위 | 초 이내 |
| 이미지 크기 | GB | MB |
| 자원 오버헤드 | 높음 | 낮음 |
| OS 공유 | X | O (Host OS 커널 공유) |

## Dockerfile

```dockerfile
FROM eclipse-temurin:21-jdk-alpine      # 베이스 이미지
WORKDIR /app                             # 작업 디렉토리
COPY build/libs/app.jar app.jar          # 파일 복사
EXPOSE 8080                              # 포트 선언 (문서 목적)
ENTRYPOINT ["java", "-jar", "app.jar"]  # 실행 명령
```

### 레이어 캐시 활용

```dockerfile
# X 소스 변경마다 의존성 재다운로드
COPY . .
RUN ./gradlew build

# O 의존성 레이어 캐시 재사용
COPY build.gradle settings.gradle ./
RUN ./gradlew dependencies --no-daemon
COPY src ./src
RUN ./gradlew build
```

> Dockerfile 명령어 순서 = 레이어 순서. 변경 빈도가 낮은 것을 위쪽에 배치해야 캐시 효율이 높아짐.

## 주요 명령어

```bash
# 이미지 빌드
docker build -t my-app:1.0 .

# 컨테이너 실행
docker run -d -p 8080:8080 --name app my-app:1.0

# 실행 중인 컨테이너 목록
docker ps

# 로그 확인
docker logs -f app

# 컨테이너 내부 접속
docker exec -it app /bin/sh

# 이미지 푸시
docker push my-registry/my-app:1.0
```

## Docker Compose

여러 컨테이너를 함께 정의·실행하는 도구. 로컬 개발 환경이나 간단한 멀티 컨테이너 구성에 사용.

```yaml
services:
  app:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - db
    environment:
      - DB_URL=jdbc:postgresql://db:5432/cslog

  db:
    image: postgres:16
    environment:
      - POSTGRES_DB=cslog
      - POSTGRES_PASSWORD=secret
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
```

## 멀티스테이지 빌드

최종 이미지에서 빌드 도구를 제거해 **이미지 크기를 줄이는** 패턴.

```dockerfile
# 1단계: 빌드
FROM gradle:8-jdk21 AS builder
WORKDIR /app
COPY . .
RUN gradle build --no-daemon

# 2단계: 실행 (JDK 없이 JRE만)
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/build/libs/app.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## 핵심 정리

- **이미지**: 불변 템플릿 / **컨테이너**: 이미지의 실행 인스턴스

- VM 대비 경량 — OS를 통째로 올리지 않고 Host OS 커널을 공유해 부팅이 빠르고 이미지가 가벼움

- Dockerfile 레이어 순서를 변경 빈도 기준으로 정렬해야 캐시 효율↑

- 멀티스테이지 빌드로 최종 이미지에서 빌드 도구 제거 → 보안·용량 개선

- 로컬 멀티 컨테이너 → Docker Compose / 운영 오케스트레이션 → [[Kubernetes]]

→ [[XaaS]] | [[CI/CD]]

