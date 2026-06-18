[[Next.js]]에서 `"use server"` 디렉티브로 선언하는 서버 전용 비동기 함수로, 클라이언트 코드에서 직접 호출할 수 있습니다.

## 핵심 특징

- 클라이언트 번들에 포함되지 않아 서버 로직·민감 정보를 클라이언트에 노출하지 않음
- HTML `<form>`의 `action` 속성에 바인딩해 JS 없이도 서버와 상호작용 가능 → Progressive Enhancement 지원
- Next.js 서버에서 DB 직접 접근 가능 → 별도 백엔드 API 엔드포인트 불필요
- [[서버 컴포넌트]] 내부에서 정의하거나, 파일 최상단에 `"use server"` 선언으로 별도 모듈로 분리

## 선언 방식

```tsx
// actions.ts
"use server";

export async function createPost(data: FormData) {
  const title = data.get("title") as string;
  await db.post.create({ data: { title } });
}
```

```tsx
// 클라이언트 컴포넌트에서 사용
<form action={createPost}>
  <input name="title" />
  <button type="submit">등록</button>
</form>
```

## 핵심 정리

Server Action은 클라이언트-서버 경계를 함수 호출로 추상화해 네트워크 왕복을 줄이고, 서버 로직을 안전하게 캡슐화합니다.
