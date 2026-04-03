인터넷에서 자원(Resource)을 식별하기 위한 **통합 자원 식별자**로, URL과 URN을 포함하는 상위 개념입니다.

## 구조 관계

```
URI
├── URL (Uniform Resource Locator) → 위치로 식별
└── URN (Uniform Resource Name)  → 이름으로 식별
```

## URI 구성 요소

```
https://www.example.com:8080/users/1?name=kim#section
─────   ───────────────  ────  ───────  ────────  ───────
scheme      host         port   path    query   fragment
```

|요소|설명|예시|
|---|---|---|
|**scheme**|프로토콜|`https`, `http`, `ftp`|
|**host**|서버 주소|`www.example.com`|
|**port**|포트 번호|`8080`|
|**path**|자원 경로|`/users/1`|
|**query**|추가 파라미터|`?name=kim`|
|**fragment**|페이지 내 위치|`#section`|

## URL vs URN

||[[URL]]|[[URN]]|
|---|---|---|
|**식별 방법**|위치(주소)|이름|
|**예시**|`https://example.com/book`|`urn:isbn:0451450523`|
|**자원 이동 시**|링크 깨짐|영구적으로 유효|
|**사용 빈도**|매우 흔함|거의 안 씀|

## 쉽게 구분하기

```
URI = 사람 (상위 개념)
URL = 집 주소로 사람 찾기   → "서울시 강남구 123번지에 사는 사람"
URN = 주민등록번호로 찾기   → "900101-1234567인 사람"
```

> 일반적으로 URI와 URL을 혼용해서 사용하지만, 엄밀히는 **URL ⊂ URI** 입니다. 대부분의 웹 주소는 URL이면서 동시에 URI입니다.