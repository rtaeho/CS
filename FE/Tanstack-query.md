TanStack Query는 React, Vue, Solid, Svelte 등에서 사용할 수 있는 **비동기 상태 관리 라이브러리**입니다. 원래 "React Query"라는 이름으로 시작했지만, 다른 프레임워크도 지원하게 되면서 TanStack Query로 이름이 바뀌었습니다.

## 주요 기능

**서버 상태 관리**: API 호출로 가져온 데이터를 캐싱하고, 자동으로 리페칭하며, 동기화 상태를 관리해줍니다.

**자동 캐싱**: 같은 데이터를 여러 컴포넌트에서 요청해도 중복 요청 없이 캐시된 데이터를 재사용합니다.

**백그라운드 리페칭**: 창이 다시 포커스되거나 네트워크가 재연결되면 자동으로 데이터를 새로고침합니다.

**로딩/에러 상태 관리**: `isLoading`, `isError`, `data` 등의 상태를 자동으로 제공합니다.

## 간단한 예시

```javascript
import { useQuery } from '@tanstack/react-query';

function UserProfile({ userId }) {
  const { data, isLoading, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetch(`/api/users/${userId}`).then(res => res.json())
  });

  if (isLoading) return <div>로딩 중...</div>;
  if (error) return <div>에러 발생</div>;

  return <div>{data.name}</div>;
}
```

기존에 `useEffect` + `useState`로 복잡하게 처리하던 API 호출 로직을 훨씬 간결하고 선언적으로 작성할 수 있게 해줍니다.