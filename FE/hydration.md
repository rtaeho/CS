Hydration은 **서버에서 렌더링된 정적 HTML에 JavaScript 이벤트 핸들러와 상태를 연결하여 인터랙티브한 페이지로 만드는 과정**입니다.

## 왜 필요한가

```
[SSR로 받은 HTML의 상태]

서버가 보낸 HTML:
<button>장바구니 담기</button>
<input type="text" placeholder="검색어 입력">
<div class="counter">0</div>

→ 화면에 보임 ✅
→ 버튼 클릭해도 아무 일 안 일어남 ❌
→ 입력해도 검색 안 됨 ❌
→ 카운터가 동작 안 함 ❌

→ HTML은 "그림"일 뿐, JavaScript가 연결되지 않은 상태
→ 이 HTML에 JS를 연결하는 과정 = Hydration
```

## Hydration 과정

```
[단계별 흐름]

1단계: 서버에서 완성된 HTML 수신
┌──────────────────────────────────┐
│ <h1>상품 목록</h1>                │
│ <div>무선 이어폰 - 45,000원</div>  │  ← 보이지만 동작 안 함
│ <button>장바구니 담기</button>      │     (죽은 HTML)
└──────────────────────────────────┘

2단계: JS 번들 다운로드 + 파싱
→ React, 컴포넌트 코드, 이벤트 핸들러 등 로드

3단계: Hydration 실행
→ React가 기존 HTML과 가상 DOM을 비교
→ HTML을 새로 만들지 않고 기존 HTML에 이벤트 핸들러 연결
┌──────────────────────────────────┐
│ <h1>상품 목록</h1>                │
│ <div>무선 이어폰 - 45,000원</div>  │  ← 보이고 동작도 함
│ <button onClick={...}>           │     (살아있는 HTML)
│   장바구니 담기                    │
│ </button>                        │
└──────────────────────────────────┘
```

```
[시간축]

0ms     200ms     500ms     800ms     1200ms
 │        │         │         │          │
 요청     HTML 수신   JS 로드    Hydration  완료
          화면 보임   시작       시작
          (FCP)                          (TTI)
          │←──── 보이지만 동작 안 함 ────→│
                  이 구간이 문제 ⚠️
```

## 코드로 이해하기

### 서버 측 — HTML 렌더링

```javascript
// 서버에서 React 컴포넌트를 HTML 문자열로 변환
import { renderToString } from 'react-dom/server';

app.get('/products', (req, res) => {
    const products = await fetchProducts();

    // React 컴포넌트 → HTML 문자열
    const html = renderToString(<ProductList products={products} />);

    res.send(`
        <!DOCTYPE html>
        <html>
        <body>
            <div id="root">${html}</div>
            <script>
                window.__INITIAL_DATA__ = ${JSON.stringify(products)}
            </script>
            <script src="/bundle.js"></script>
        </body>
        </html>
    `);
});
```

### 클라이언트 측 — Hydration

```javascript
// 브라우저에서 기존 HTML에 이벤트 연결
import { hydrateRoot } from 'react-dom/client';

// 서버에서 전달받은 초기 데이터
const initialData = window.__INITIAL_DATA__;

// 기존 HTML을 재사용하며 이벤트 핸들러만 연결
hydrateRoot(
    document.getElementById('root'),
    <ProductList products={initialData} />
);
```

```
[render vs hydrate 차이]

CSR:
ReactDOM.render(<App />, document.getElementById('root'));
→ 빈 #root에 HTML을 새로 생성

SSR + Hydration:
hydrateRoot(document.getElementById('root'), <App />);
→ 이미 있는 HTML을 재사용하고 이벤트만 연결
→ HTML을 새로 만들지 않음 → 빠름
```

## Hydration이 내부적으로 하는 일

```
[React Hydration 과정]

1. 서버 HTML과 가상 DOM 비교
   서버 HTML: <button>장바구니 담기</button>
   가상 DOM:  <button onClick={addToCart}>장바구니 담기</button>
   → 구조 일치 확인 ✅

2. 이벤트 핸들러 연결
   button → onClick={addToCart} 연결
   input → onChange={handleSearch} 연결

3. 상태(State) 초기화
   useState(initialData)로 컴포넌트 상태 설정

4. useEffect 실행
   클라이언트 전용 로직 시작 (타이머, 구독 등)

→ DOM을 새로 만들지 않고 기존 DOM에 "생명을 불어넣음"
→ 이것이 "수분 보충(Hydration)"이라는 이름의 유래
```

## Hydration 불일치 문제

서버 HTML과 클라이언트 가상 DOM이 다르면 에러가 발생합니다.

```javascript
// ❌ Hydration 불일치 발생
function Clock() {
    return <p>현재 시간: {new Date().toLocaleTimeString()}</p>;
}

// 서버 렌더링: <p>현재 시간: 10:00:00</p>
// 클라이언트 Hydration: <p>현재 시간: 10:00:03</p>
// → 불일치! → React 경고 또는 에러 ⚠️
```

```javascript
// ✅ 해결 — 클라이언트 전용 로직 분리
function Clock() {
    const [time, setTime] = useState(null);

    useEffect(() => {
        // useEffect는 클라이언트에서만 실행
        setTime(new Date().toLocaleTimeString());
        const timer = setInterval(() => {
            setTime(new Date().toLocaleTimeString());
        }, 1000);
        return () => clearInterval(timer);
    }, []);

    // 서버: "로딩 중..." 렌더링
    // 클라이언트: Hydration 후 시간 표시
    return <p>현재 시간: {time ?? '로딩 중...'}</p>;
}
```

```
[Hydration 불일치가 발생하는 대표적인 경우]

1. 시간/날짜 — 서버와 클라이언트의 시간 차이
2. 랜덤 값 — Math.random() 결과가 다름
3. window/document 접근 — 서버에는 없는 객체
4. 브라우저 전용 API — localStorage, navigator 등
5. 조건부 렌더링 — 화면 크기에 따른 분기

→ 이런 로직은 useEffect 안에서 처리해야 함
```

## Hydration의 성능 문제

```
[전체 페이지 Hydration의 문제]

페이지에 컴포넌트가 100개 있으면:
→ 100개 모두 Hydration 완료되어야 인터랙션 가능
→ 사용자가 당장 사용하지 않는 컴포넌트까지 Hydration
→ TTI 지연

┌──────────────────────────────────────┐
│ Header [Hydration 필요]              │
│ 검색바 [Hydration 필요]              │
│ 상품 목록 [Hydration 필요]            │  ← 사용자가 보는 영역
│ 상품 카드 x 20 [Hydration 필요]       │
├──────────────────────────────────────┤
│ 리뷰 섹션 [Hydration 필요]           │
│ 추천 상품 [Hydration 필요]            │  ← 스크롤해야 보이는 영역
│ 푸터 [Hydration 필요]                │     (당장 필요 없음)
└──────────────────────────────────────┘

→ 전체 Hydration이 끝나야 상단 버튼도 동작
→ 불필요한 대기 시간 발생
```

## 최적화 방법들

### 1. Selective Hydration (React 18)

```
[필요한 컴포넌트부터 우선 Hydration]

┌──────────────────────────────────────┐
│ Header [✅ 우선 Hydration]           │
│ 검색바 [✅ 우선 Hydration]           │
│ 상품 목록 [✅ 우선 Hydration]         │
├──────────────────────────────────────┤
│ 리뷰 섹션 [⏳ 나중에]                │
│ 추천 상품 [⏳ 나중에]                 │
│ 푸터 [⏳ 나중에]                      │
└──────────────────────────────────────┘

→ 사용자가 보는 영역부터 먼저 Hydration
→ 나머지는 나중에 또는 사용자가 스크롤할 때
```

```javascript
// React 18 — Suspense로 Selective Hydration
import { Suspense } from 'react';

function ProductPage() {
    return (
        <div>
            {/* 즉시 Hydration */}
            <Header />
            <SearchBar />
            <ProductList />

            {/* 지연 Hydration — 스크롤 시 또는 나중에 */}
            <Suspense fallback={<div>로딩 중...</div>}>
                <ReviewSection />
                <RecommendedProducts />
            </Suspense>
        </div>
    );
}
```

### 2. Progressive Hydration

```
[사용자 상호작용 시 Hydration]

초기: 모든 컴포넌트가 정적 HTML
→ 사용자가 검색바 클릭 → 검색바만 Hydration
→ 사용자가 장바구니 버튼 클릭 → 장바구니만 Hydration

→ 필요한 시점에 필요한 부분만 활성화
```

### 3. Island Architecture (Astro)

```
[페이지 대부분은 정적 HTML, 인터랙티브한 부분만 Hydration]

┌──────────────────────────────────────┐
│ Header (정적 HTML — Hydration 안 함)  │
│                                      │
│ ┌─────────────────┐                  │
│ │ 검색바 (Island)  │ ← Hydration ✅  │
│ └─────────────────┘                  │
│                                      │
│ 상품 설명 (정적 HTML — Hydration 안 함)│
│                                      │
│ ┌─────────────────┐                  │
│ │ 장바구니 (Island) │ ← Hydration ✅ │
│ └─────────────────┘                  │
│                                      │
│ 푸터 (정적 HTML — Hydration 안 함)    │
└──────────────────────────────────────┘

→ 인터랙티브한 "섬(Island)"만 Hydration
→ 나머지는 순수 HTML → JS 로드량 대폭 감소
```

### 4. React Server Components (RSC)

```
[서버 컴포넌트는 Hydration 자체가 불필요]

서버 컴포넌트:
→ 서버에서만 실행 → JS 번들에 포함 안 됨
→ Hydration 불필요 → 성능 향상

클라이언트 컴포넌트:
→ 인터랙션이 필요한 부분만 'use client' 선언
→ 이 부분만 Hydration
```

```javascript
// 서버 컴포넌트 — Hydration 불필요
async function ProductInfo({ id }) {
    const product = await db.product.findById(id);
    return (
        <div>
            <h1>{product.name}</h1>
            <p>{product.description}</p>
        </div>
    );
}

// 클라이언트 컴포넌트 — Hydration 필요
'use client';
function AddToCartButton({ productId }) {
    const [added, setAdded] = useState(false);
    return (
        <button onClick={() => {
            addToCart(productId);
            setAdded(true);
        }}>
            {added ? '담김 ✅' : '장바구니 담기'}
        </button>
    );
}
```

## Hydration 최적화 방식 비교

|방식|원리|프레임워크|
|---|---|---|
|**Selective Hydration**|중요한 컴포넌트부터 우선 처리|React 18|
|**Progressive Hydration**|사용자 상호작용 시 처리|Angular, Vue|
|**Island Architecture**|인터랙티브 부분만 처리|Astro|
|**Server Components**|서버 전용 컴포넌트는 아예 제외|Next.js 13+|

## 면접 포인트

- Hydration은 [[SSR]]로 전달된 **정적 HTML에 JavaScript를 연결하여 인터랙티브하게 만드는 과정**이며, "수분 보충"이라는 의미처럼 죽어있는 HTML에 생명을 불어넣는 것입니다.
- Hydration의 핵심 문제는 **FCP와 TTI 사이의 간격**으로, 화면은 보이지만 인터랙션이 안 되는 구간이 발생합니다. 이를 해결하기 위해 Selective Hydration, Island Architecture, React Server Components 등의 최적화 기법이 등장했습니다.
- 서버 HTML과 클라이언트 가상 DOM이 **불일치하면 에러가 발생**하므로, 시간/랜덤 값/브라우저 전용 API 등은 반드시 useEffect 안에서 처리해야 합니다.