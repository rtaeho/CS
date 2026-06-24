---
title: "RequestBody VS ModelAttribute의 차이점을 말해주세요"
tags: [매일메일, Backend]
status: published
---

`[[@RequestBody]]`와 `[[@ModelAttribute]]`는 클라이언트 측에서 보낸 데이터를 Java 객체로 만들어줍니다. 정리하면 [[RequestBody vs ModelAttribute]]는 바인딩 대상과 변환 방식이 다릅니다.

## RequestBody

- 클라이언트가 보내는 요청의 본문을 Java 객체로 변환합니다.
- 내부적으로 [[HttpMessageConverter]]를 거치며, JSON 요청은 보통 ObjectMapper를 통해 Java 객체로 역직렬화합니다.
- 따라서 변환될 Java 객체는 Jackson이 생성할 수 있는 형태여야 합니다.
- record는 기본 생성자를 자동으로 제공하지 않지만, 모든 필드를 초기화하는 canonical constructor가 있어 Jackson이 이를 사용해 역직렬화할 수 있습니다.

## ModelAttribute

- 메서드 단위에서는 Model에 속성을 추가할 때 사용할 수 있습니다.
- 인자 단위에서는 요청 파라미터나 `multipart/form-data` 형식의 데이터를 Java 객체로 변환합니다.
- 내부적으로 `ModelAttributeMethodProcessor`를 거치며, 지정된 클래스의 생성자와 바인딩 가능한 필드를 이용해 객체로 변환합니다.

## 핵심 차이

| 항목 | @RequestBody | @ModelAttribute |
|---|---|---|
| 바인딩 대상 | 요청 본문 | 요청 파라미터, form-data |
| 대표 형식 | JSON | query string, form, multipart |
| 내부 처리 | `HttpMessageConverter` | `ModelAttributeMethodProcessor` |
| 사용 예 | REST API 요청 DTO | 검색 조건, 폼 제출, 파일 업로드 |

## 참고

- https://tecoble.techcourse.co.kr/post/2021-05-11-requestbody-modelattribute/
- https://blog.karsei.pe.kr/59
