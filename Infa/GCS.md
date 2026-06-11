---
title: "GCS"
tags: [클라우드, 스토리지]
status: published
---

Google Cloud Storage는 GCP에서 제공하는 객체 스토리지 서비스로, 파일·이미지·백업 등을 무제한으로 저장하고 URL로 접근할 수 있습니다.

## 핵심 특징

- **객체 스토리지**: 파일을 키-값 형태로 저장 (디렉토리 구조 없음, 경로처럼 보이는 이름만 존재)
- **버킷(Bucket)**: 파일을 담는 최상위 컨테이너 — 전 세계 고유한 이름
- **무제한 용량**: 파일 크기 최대 5TB, 개수 제한 없음
- **공개/비공개 접근**: 객체별·버킷별 IAM 권한 설정
- **CDN 연동**: Cloud CDN과 연동해 정적 파일 빠르게 서빙 가능

## S3 vs GCS 비교

| 항목 | AWS S3 | GCS |
|---|---|---|
| 제공사 | AWS | GCP |
| 버킷 위치 | 리전 단위 | 리전 / 멀티리전 / 듀얼리전 |
| 스토리지 클래스 | Standard / IA / Glacier | Standard / Nearline / Coldline / Archive |
| API 호환 | — | S3 호환 API 지원 |

## 스토리지 클래스

| 클래스 | 접근 빈도 | 최소 보관 | 용도 |
|---|---|---|---|
| **Standard** | 자주 | 없음 | 이미지, 정적 파일 |
| **Nearline** | 월 1회 이하 | 30일 | 백업 |
| **Coldline** | 분기 1회 이하 | 90일 | 재해 복구 |
| **Archive** | 연 1회 이하 | 365일 | 장기 아카이브 |

## Spring Boot 연동

```gradle
implementation 'com.google.cloud:spring-cloud-gcp-starter-storage'
```

```yaml
# application.yml
spring:
  cloud:
    gcp:
      project-id: cslog-rtaeho
      credentials:
        location: classpath:gcp-key.json
```

```java
@Service
@RequiredArgsConstructor
public class GcsService {

    private final Storage storage;

    // 파일 업로드
    public String upload(String bucketName, String fileName, byte[] content, String contentType) {
        BlobId blobId = BlobId.of(bucketName, fileName);
        BlobInfo blobInfo = BlobInfo.newBuilder(blobId)
                .setContentType(contentType)
                .build();

        storage.create(blobInfo, content);
        return String.format("https://storage.googleapis.com/%s/%s", bucketName, fileName);
    }

    // 파일 다운로드
    public byte[] download(String bucketName, String fileName) {
        return storage.readAllBytes(bucketName, fileName);
    }

    // 파일 삭제
    public void delete(String bucketName, String fileName) {
        storage.delete(BlobId.of(bucketName, fileName));
    }

    // Signed URL 생성 (비공개 파일을 임시로 공개)
    public URL generateSignedUrl(String bucketName, String fileName) {
        BlobInfo blobInfo = BlobInfo.newBuilder(bucketName, fileName).build();
        return storage.signUrl(blobInfo, 15, TimeUnit.MINUTES,
                Storage.SignUrlOption.withV4Signature());
    }
}
```

## 주요 사용 패턴

```
[이미지 업로드 흐름]
클라이언트 ──→ Spring Boot ──→ GCS 업로드
                    │
                    └──→ DB에 GCS URL 저장
                         (https://storage.googleapis.com/bucket/image.jpg)

[Signed URL — 비공개 파일 임시 접근]
클라이언트 ──→ Spring Boot ──→ Signed URL 발급 (유효기간 15분)
클라이언트 ──→ GCS 직접 접근 (Signed URL로)
```

## 언제 쓰나?

- 사용자 업로드 이미지 · 동영상 저장
- 정적 파일 서빙 (HTML, CSS, JS — [[CDN]]과 연동)
- 배포 아티팩트 (Docker 이미지, JAR) 저장
- 데이터베이스 백업 파일 보관
- 로그 파일 장기 보관
