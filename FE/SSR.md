SSR(Server-Side Rendering)은 **서버에서 HTML을 완성하여 클라이언트에 전달하는 렌더링 방식**으로, 브라우저가 받자마자 콘텐츠를 표시할 수 있습니다.

## CSR vs SSR

```
[CSR (Client-Side Rendering)]
서버 → 빈 HTML + JS 번들 전달 → 브라우저가 JS 실행 → 화면 렌더링

1. 브라우저: 서버에 요청
2. 서버: 빈 HTML + 큰 JS 파일 전달
3. 브라우저: JS 다운로드 + 파싱 + 실행
4. 브라우저: API 호출하여 데이터 가져옴
5. 브라우저: 데이터로 화면 그림
→ 사용자는 3~5단계 동안 빈 화면을 봄 ❌

[SSR (Server-Side Rendering)]
서버 → 완성된 HTML 전달 → 브라우저가 즉시 표시

1. 브라우저: 서버에 요청
2. 서버: 데이터 조회 + HTML 완성
3. 서버: 완성된 HTML 전달
4. 브라우저: 즉시 화면 표시 ✅
5. 브라우저: JS 다운로드 → 인터랙션 활성화 (Hydration)
```

## 시각적 차이

```
[CSR — 사용자 경험]
0초 ─── 1초 ─── 2초 ─── 3초 ─── 4초
 │       │       │       │       │
 빈 화면  빈 화면  로딩 중  화면 표시  인터랙션 가능
                         (FCP)    (TTI)

[SSR — 사용자 경험]
0초 ─── 1초 ─── 2초 ─── 3초
 │       │       │       │
 빈 화면  화면 표시  인터랙션 가능
         (FCP)    (TTI)

FCP (First Contentful Paint): 첫 콘텐츠가 보이는 시점
TTI (Time to Interactive): 사용자가 상호작용 가능한 시점

→ SSR은 FCP가 빠름 (콘텐츠를 빨리 보여줌)
→ CSR은 TTI까지 빈 화면
```

## [[CSR]]의 동작 방식

```html
<!-- 서버가 보내는 HTML — 거의 비어 있음 -->
<!DOCTYPE html>
<html>
<head>
    <title>쇼핑몰</title>
</head>
<body>
    <div id="root"></div>  <!-- 비어 있음 -->
    <script src="/bundle.js"></script>  <!-- 수 MB의 JS -->
</body>
</html>
```

```javascript
// React CSR — 브라우저에서 실행
function ProductList() {
    const [products, setProducts] = useState([]);

    useEffect(() => {
        // 브라우저에서 API 호출
        fetch('/api/products')
            .then(res => res.json())
            .then(data => setProducts(data));
    }, []);

    return (
        <div>
            {products.map(p => (
                <div key={p.id}>{p.name} - {p.price}원</div>
            ))}
        </div>
    );
}
```

```
[CSR의 문제]
검색 엔진 크롤러가 페이지를 방문하면:
→ 빈 <div id="root"></div>만 보임
→ JS를 실행하지 않는 크롤러는 콘텐츠를 인식 못 함
→ SEO 불리 ❌
```

## SSR의 동작 방식

```html
<!-- 서버가 보내는 HTML — 콘텐츠가 이미 포함됨 -->
<!DOCTYPE html>
<html>
<head>
    <title>쇼핑몰 - 상품 목록</title>
</head>
<body>
    <div id="root">
        <!-- 서버에서 렌더링된 완성된 HTML -->
        <div>
            <div>무선 이어폰 - 45,000원</div>
            <div>블루투스 스피커 - 35,000원</div>
            <div>무선 키보드 - 89,000원</div>
        </div>
    </div>
    <script src="/bundle.js"></script>
</body>
</html>
```

```
[SSR 흐름]
1. 브라우저 → 서버: /products 요청
2. 서버: DB/API에서 데이터 조회
3. 서버: React 컴포넌트를 HTML 문자열로 렌더링
4. 서버: 완성된 HTML 응답
5. 브라우저: HTML 즉시 표시 (콘텐츠 보임)
6. 브라우저: JS 다운로드 → Hydration (이벤트 핸들러 연결)
```

## [[hydration]]이란

```
SSR로 받은 HTML은 "보이기만" 하고 버튼 클릭 등 인터랙션은 안 됨
→ JS가 로드된 후 이벤트 핸들러를 연결하는 과정 = Hydration

[과정]
1. 서버: HTML 렌더링 → <button>장바구니 담기</button>
   → 화면에 보이지만 클릭해도 아무 일도 안 일어남

2. 브라우저: JS 로드 완료 → Hydration 시작
   → 기존 HTML에 onClick 핸들러 연결

3. Hydration 완료
   → 버튼 클릭 시 장바구니에 추가됨 ✅
```

## Spring Boot에서의 SSR (전통적 방식)

```java
// Spring MVC + Thymeleaf — 전통적인 SSR
@Controller
public class ProductController {

    private final ProductService productService;

    @GetMapping("/products")
    public String productList(Model model) {
        // 서버에서 데이터 조회
        List<Product> products = productService.findAll();

        // 모델에 데이터 전달
        model.addAttribute("products", products);

        // Thymeleaf 템플릿 렌더링 → 완성된 HTML 반환
        return "products/list";
    }
}
```

```html
<!-- templates/products/list.html (Thymeleaf) -->
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>상품 목록</title>
</head>
<body>
    <h1>상품 목록</h1>
    <div th:each="product : ${products}">
        <span th:text="${product.name}">상품명</span>
        <span th:text="${product.price + '원'}">가격</span>
    </div>
</body>
</html>

<!-- 서버가 렌더링한 결과 HTML -->
<body>
    <h1>상품 목록</h1>
    <div>
        <span>무선 이어폰</span>
        <span>45,000원</span>
    </div>
    <div>
        <span>블루투스 스피커</span>
        <span>35,000원</span>
    </div>
</body>
```

## Next.js에서의 SSR (현대적 방식)

```javascript
// Next.js SSR — getServerSideProps
export async function getServerSideProps() {
    // 서버에서 실행됨 (매 요청마다)
    const res = await fetch('http://api.example.com/products');
    const products = await res.json();

    return {
        props: { products }  // 컴포넌트에 전달
    };
}

export default function ProductList({ products }) {
    return (
        <div>
            <h1>상품 목록</h1>
            {products.map(p => (
                <div key={p.id}>
                    <span>{p.name}</span>
                    <span>{p.price}원</span>
                </div>
            ))}
        </div>
    );
}

// 서버에서 이 컴포넌트를 HTML로 렌더링하여 전달
// 브라우저는 완성된 HTML을 받고 → Hydration으로 인터랙션 활성화
```

## 렌더링 방식 비교

|항목|CSR|SSR|SSG|
|---|---|---|---|
|**렌더링 위치**|브라우저|서버 (매 요청)|서버 (빌드 시)|
|**초기 로딩 속도**|느림|빠름|가장 빠름|
|**SEO**|불리 ❌|유리 ✅|유리 ✅|
|**서버 부하**|낮음|높음 (매 요청 렌더링)|낮음|
|**데이터 실시간성**|실시간|실시간|빌드 시점 데이터|
|**인터랙션**|JS 로드 후 즉시|Hydration 후|Hydration 후|

```
CSR:  빌드 → 정적 파일 배포 → 브라우저가 렌더링
SSR:  요청 → 서버가 매번 렌더링 → 완성된 HTML 전달
SSG:  빌드 시 HTML 생성 → 정적 파일 배포 → CDN에서 전달

SSG (Static Site Generation):
→ 빌드 시점에 HTML을 미리 생성
→ 블로그, 문서 사이트 등 데이터가 자주 안 바뀌는 경우 적합
```

## 언제 어떤 방식을 사용하는가

|서비스 유형|권장 방식|이유|
|---|---|---|
|**블로그, 문서 사이트**|SSG|콘텐츠가 자주 안 바뀜, SEO 중요|
|**쇼핑몰 상품 페이지**|SSR|SEO 중요 + 실시간 데이터(가격, 재고)|
|**관리자 대시보드**|CSR|SEO 불필요, 복잡한 인터랙션|
|**소셜 미디어 피드**|SSR + CSR 혼합|초기 로딩 SSR, 이후 CSR|
|**마케팅 랜딩 페이지**|SSG|최고 성능, SEO 최적화|

## SSR의 장단점

```
[장점]
✅ 빠른 초기 로딩 (FCP) — 콘텐츠가 즉시 보임
✅ SEO 유리 — 크롤러가 완성된 HTML을 인식
✅ 소셜 미디어 공유 — OG 태그가 서버에서 설정됨
✅ 저사양 기기 지원 — 서버가 렌더링 부담

[단점]
❌ 서버 부하 — 매 요청마다 렌더링
❌ TTFB 증가 — 서버 렌더링 시간만큼 응답 지연
❌ Hydration 비용 — JS 로드 전까지 인터랙션 불가
❌ 서버 인프라 필요 — CDN만으로 배포 불가
```

```
TTFB (Time To First Byte): 서버가 첫 바이트를 응답하는 시간

CSR:  서버가 빈 HTML 즉시 응답 → TTFB 빠름
      → 하지만 콘텐츠가 보이려면 JS 실행까지 기다려야 함

SSR:  서버가 렌더링 완료 후 응답 → TTFB 느림
      → 하지만 응답 받으면 즉시 콘텐츠가 보임
```

## Spring Boot 기반 서비스에서의 일반적 구조

```
[백엔드 개발자 관점에서의 SSR vs CSR]

전통적 SSR (Spring MVC + Thymeleaf):
→ Spring이 HTML을 렌더링하여 반환
→ 백엔드가 프론트까지 담당
→ 모놀리식 구조

현대적 분리 구조 (가장 일반적):
→ Spring Boot: REST API만 제공
→ Next.js / Nuxt.js: SSR 담당 (프론트 서버)
→ 프론트-백 분리

┌──────────┐     ┌──────────────┐     ┌──────────────┐
│ 브라우저   │────→│ Next.js 서버  │────→│ Spring Boot  │
│           │←────│ (SSR 담당)    │←────│ (REST API)   │
└──────────┘     └──────────────┘     └──────────────┘
  HTML 수신        HTML 렌더링          데이터 제공
```

## 면접 포인트

- SSR은 **서버에서 완성된 HTML을 전달**하므로 초기 로딩(FCP)이 빠르고 SEO에 유리하지만, 매 요청마다 서버가 렌더링해야 하므로 **서버 부하가 증가**합니다.
- CSR은 **브라우저가 JS로 렌더링**하므로 서버 부하가 적고 인터랙션이 풍부하지만, 초기에 빈 화면이 보이고 **SEO에 불리**합니다.
- 현대 웹 서비스에서는 CSR/SSR을 이분법으로 선택하지 않고, **Next.js 등을 활용하여 페이지별로 SSR, SSG, CSR을 혼합**하는 것이 일반적이며, 백엔드 개발자는 REST API를 제공하고 SSR은 프론트 서버가 담당하는 분리 구조가 보편적입니다.