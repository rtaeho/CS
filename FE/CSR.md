CSR(Client-Side Rendering)은 **브라우저(클라이언트)가 JavaScript를 실행하여 화면을 렌더링하는 방식**으로, 서버는 빈 HTML과 JS 번들만 전달합니다.

## 동작 흐름

```
[CSR 흐름]

1. 브라우저 → 서버: /products 요청
2. 서버 → 브라우저: 빈 HTML + JS 번들 전달
3. 브라우저: JS 다운로드 + 파싱 + 실행
4. 브라우저: JS가 API 서버에 데이터 요청
5. API 서버 → 브라우저: JSON 데이터 응답
6. 브라우저: 데이터로 화면 렌더링

┌──────────┐         ┌──────────────┐       ┌──────────────┐
│ 브라우저   │───①───→│ 웹 서버       │       │ API 서버      │
│           │←──②───│ (정적 파일)    │       │ (Spring Boot)│
│           │        └──────────────┘       │              │
│ JS 실행   │───④──────────────────────────→│              │
│ 화면 렌더링│←──⑤──────────────────────────│              │
└──────────┘                                └──────────────┘
```

## 서버가 보내는 HTML

```html
<!-- 서버가 전달하는 HTML — 거의 비어 있음 -->
<!DOCTYPE html>
<html>
<head>
    <title>쇼핑몰</title>
    <link rel="stylesheet" href="/static/css/main.css">
</head>
<body>
    <div id="root"></div>  <!-- 비어 있음 -->
    <script src="/static/js/bundle.js"></script>  <!-- 수백 KB ~ 수 MB -->
</body>
</html>

<!-- 검색 엔진 크롤러가 보는 것: -->
<!-- <div id="root"></div> ← 빈 내용 → SEO 불리 ❌ -->
```

## React CSR 코드 예시

```javascript
// index.js — 진입점
import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';

// 브라우저에서 빈 #root에 React 앱을 렌더링
ReactDOM.render(<App />, document.getElementById('root'));
```

```javascript
// App.js — 라우팅
import { BrowserRouter, Routes, Route } from 'react-router-dom';

function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/products" element={<ProductList />} />
                <Route path="/products/:id" element={<ProductDetail />} />
            </Routes>
        </BrowserRouter>
    );
}
```

```javascript
// ProductList.js — 상품 목록
function ProductList() {
    const [products, setProducts] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // 브라우저에서 API 호출
        fetch('http://api.example.com/products')
            .then(res => res.json())
            .then(data => {
                setProducts(data);
                setLoading(false);
            });
    }, []);

    if (loading) return <div>로딩 중...</div>;

    return (
        <div>
            <h1>상품 목록</h1>
            {products.map(p => (
                <div key={p.id}>
                    <span>{p.name}</span>
                    <span>{p.price}원</span>
                    <button onClick={() => addToCart(p.id)}>
                        장바구니 담기
                    </button>
                </div>
            ))}
        </div>
    );
}
```

## CSR에서 페이지 이동

```
[전통적 방식 — 매번 서버에 HTML 요청]
/products 클릭 → 서버에 요청 → 새 HTML 수신 → 전체 페이지 새로고침
/products/1 클릭 → 서버에 요청 → 새 HTML 수신 → 전체 페이지 새로고침

→ 매번 흰 화면 깜빡임 (전체 리로드)

[CSR — SPA (Single Page Application)]
최초: 빈 HTML + JS 한 번 로드
/products 클릭 → JS가 URL 변경 + 화면 교체 (서버 요청 없음)
/products/1 클릭 → JS가 URL 변경 + 화면 교체 (API만 호출)

→ 페이지 깜빡임 없음 → 네이티브 앱 같은 부드러운 전환 ✅
→ 필요한 데이터만 API로 가져옴
```

```
[SPA 페이지 전환]

/products 페이지                    /products/1 페이지
┌──────────────────────┐           ┌──────────────────────┐
│ Header (유지)         │           │ Header (유지)         │
├──────────────────────┤    →      ├──────────────────────┤
│ 상품 목록             │   클릭    │ 상품 상세              │
│ - 무선 이어폰         │           │ 무선 이어폰            │
│ - 블루투스 스피커      │           │ 가격: 45,000원        │
│ - 무선 키보드         │           │ [장바구니 담기]        │
└──────────────────────┘           └──────────────────────┘

→ Header는 그대로 유지
→ 콘텐츠 영역만 교체
→ 전체 페이지 리로드 없음
```

## CSR의 배포 구조

```
[CSR은 정적 파일만 배포]

빌드:
npm run build
→ /build
   ├── index.html        (빈 HTML)
   ├── static/js/bundle.js   (React 앱 전체)
   └── static/css/main.css

배포:
빌드 결과물을 Nginx / S3 / CDN에 업로드하면 끝

┌──────────┐     ┌──────────────────┐     ┌──────────────┐
│ 브라우저   │────→│ CDN / Nginx      │     │ API 서버      │
│           │←────│ (정적 파일 전달)   │     │ (Spring Boot)│
│           │     └──────────────────┘     │              │
│           │─── API 호출 ────────────────→│              │
│           │←── JSON 응답 ───────────────│              │
└──────────┘                               └──────────────┘

→ 프론트 서버가 따로 필요 없음
→ CDN에서 정적 파일 배포 → 비용 낮음
→ API 서버만 운영하면 됨
```

## [[SSR]]과의 시간축 비교

```
[CSR 타임라인]
0ms ─── 200ms ─── 500ms ─── 1000ms ─── 1500ms ─── 2000ms
 │       │         │          │           │          │
 요청    빈 HTML    JS 다운로드  JS 실행     API 응답    화면 표시
         수신       시작        시작        수신       (FCP)
                                                     인터랙션 가능
                                                     (TTI)

→ FCP와 TTI가 거의 동시에 옴 (보이면 바로 사용 가능)
→ 하지만 그때까지 빈 화면

[SSR 타임라인]
0ms ─── 200ms ─── 500ms ─── 1000ms ─── 1500ms
 │       │         │          │           │
 요청    서버       완성된 HTML  JS 다운로드   Hydration
         렌더링     수신 (FCP)  시작         완료 (TTI)
                   화면 보임

→ FCP가 빠름 (일찍 보임)
→ 하지만 TTI까지 인터랙션 불가 (보이지만 클릭 안 됨)
```

|항목|CSR|SSR|
|---|---|---|
|**FCP (첫 콘텐츠)**|느림 (JS 실행 후)|빠름 (HTML 수신 즉시)|
|**TTI (인터랙션 가능)**|FCP와 동시|FCP보다 늦음 (Hydration 후)|
|**FCP~TTI 사이**|없음 (동시)|보이지만 클릭 안 되는 구간 존재|

## CSR의 장단점

```
[장점]
✅ 부드러운 페이지 전환 — SPA로 네이티브 앱 같은 UX
✅ 서버 부하 낮음 — 정적 파일만 배포, 서버 렌더링 없음
✅ 배포 간단 — CDN / S3에 정적 파일 업로드로 끝
✅ 프론트-백 완전 분리 — API만 있으면 됨
✅ 인터랙션 풍부 — 복잡한 UI 상호작용에 유리

[단점]
❌ 초기 로딩 느림 — JS 번들 다운로드 + 실행 + API 호출
❌ SEO 불리 — 크롤러가 빈 HTML만 봄
❌ 소셜 미디어 공유 — OG 태그가 빈 HTML에 없으면 미리보기 안 됨
❌ JS 번들 크기 — 앱이 커지면 번들도 커짐 → 초기 로딩 악화
❌ 저사양 기기 — 브라우저가 렌더링 부담
```

## SEO 문제 상세

```
[검색 엔진 크롤러가 CSR 페이지를 방문하면]

Google 크롤러:
1. /products 요청
2. <div id="root"></div> 수신
3. JS 실행하여 렌더링 시도 (Google은 가능)
4. 하지만 렌더링 예산(Crawl Budget)이 제한적
→ Google은 가능하지만 비효율적

네이버, Bing 등 다른 크롤러:
1. /products 요청
2. <div id="root"></div> 수신
3. JS 실행 안 함 (또는 제한적)
→ 콘텐츠를 인식하지 못함 ❌

소셜 미디어 (카카오톡, 슬랙 등):
1. URL 공유 시 미리보기 생성
2. HTML의 OG 태그를 읽음
3. CSR은 빈 HTML → 미리보기 없음 ❌
```

## CSR의 성능 최적화 방법

### 코드 스플리팅

```javascript
// ❌ 모든 페이지를 한 번에 번들
import ProductList from './ProductList';
import ProductDetail from './ProductDetail';
import AdminDashboard from './AdminDashboard';

// ✅ 페이지별로 분할 → 필요한 것만 로드
const ProductList = React.lazy(() => import('./ProductList'));
const ProductDetail = React.lazy(() => import('./ProductDetail'));
const AdminDashboard = React.lazy(() => import('./AdminDashboard'));

function App() {
    return (
        <Suspense fallback={<div>로딩 중...</div>}>
            <Routes>
                <Route path="/products" element={<ProductList />} />
                <Route path="/products/:id" element={<ProductDetail />} />
                <Route path="/admin" element={<AdminDashboard />} />
            </Routes>
        </Suspense>
    );
}

// /products 접속 시 ProductList 코드만 다운로드
// AdminDashboard 코드는 /admin 접속 시에만 다운로드
```

### 사전 렌더링 (Pre-rendering)

```
[빌드 시 주요 페이지의 HTML을 미리 생성]

빌드:
/ → index.html (완성된 HTML)
/about → about.html (완성된 HTML)
/products → products.html (완성된 HTML)

→ 크롤러가 완성된 HTML을 볼 수 있음 → SEO 개선
→ 하지만 데이터가 빌드 시점에 고정됨
```

## 실무에서의 선택 기준

|서비스 유형|권장 방식|이유|
|---|---|---|
|**관리자 대시보드**|CSR ✅|SEO 불필요, 복잡한 인터랙션|
|**사내 툴**|CSR ✅|SEO 불필요, 빠른 개발|
|**웹 앱 (노션, 피그마 등)**|CSR ✅|앱에 가까운 UX 필요|
|**쇼핑몰 상품 페이지**|SSR|SEO 필수, 실시간 데이터|
|**블로그, 뉴스**|SSG|SEO 필수, 콘텐츠 고정|
|**대규모 서비스**|SSR + CSR 혼합|페이지별 최적 방식 선택|

## 백엔드 개발자 관점에서의 CSR

```
[CSR 환경에서 백엔드의 역할]

프론트엔드 (React):
→ 정적 파일 배포 (CDN)
→ 브라우저에서 API 호출

백엔드 (Spring Boot):
→ REST API만 제공
→ HTML 렌더링 담당 안 함

GET /api/products         → JSON 응답
GET /api/products/{id}    → JSON 응답
POST /api/orders          → JSON 응답

→ 백엔드는 데이터만 전달
→ 화면 렌더링은 프론트가 담당
→ 프론트-백 완전 분리
```

```java
// Spring Boot — REST API만 제공
@RestController
@RequestMapping("/api/products")
public class ProductController {

    @GetMapping
    public ResponseEntity<List<ProductResponse>> findAll() {
        return ResponseEntity.ok(productService.findAll());
        // HTML이 아닌 JSON 반환
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductResponse> findById(@PathVariable Long id) {
        return ResponseEntity.ok(productService.findById(id));
    }
}

// SSR이었다면:
// @Controller + return "products/list" (Thymeleaf 템플릿)
// CSR이면:
// @RestController + return JSON
```

## 면접 포인트

- CSR은 **브라우저가 JS를 실행하여 화면을 렌더링**하는 방식으로, 서버는 빈 HTML과 JS 번들만 전달합니다. SPA(Single Page Application)의 기반이며, 페이지 전환 시 전체 리로드 없이 부드러운 UX를 제공합니다.
- CSR의 가장 큰 단점은 **SEO**이며, 검색 엔진 크롤러가 빈 HTML만 보게 되어 콘텐츠를 인식하기 어렵습니다. 이를 보완하기 위해 SSR, SSG, Pre-rendering 등의 기법을 혼합하여 사용합니다.
- 백엔드 개발자 관점에서 CSR 환경은 **REST API만 제공**하면 되므로 프론트-백 분리가 명확해지며, 이것이 현대 웹 개발에서 가장 일반적인 구조입니다.