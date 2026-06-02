**Vue.js 공식 상태관리 라이브러리**로, Flux 패턴을 기반으로 컴포넌트 간 공유 상태를 중앙에서 관리합니다.

## Vuex의 5가지 핵심 개념

```
[ Vuex 데이터 흐름 ]

Component
  │ dispatch(action)
  ▼
Actions ──→ (비동기 가능, API 호출) ──→ commit(mutation)
                                              │
                                              ▼
                                         Mutations ──→ State 변경
                                                          │
                                                    getters로 가공
                                                          │
                                                   Component에 반영
```

- **State**: 전역 상태 데이터 (단일 진실 출처)
- **Getters**: State를 가공·계산한 값 (computed와 유사)
- **Mutations**: State를 **동기적으로** 변경하는 유일한 수단
- **Actions**: 비동기 처리 후 mutation을 커밋
- **Modules**: 스토어를 여러 모듈로 분리

## 기본 사용

```javascript
// store/index.js
import { createStore } from 'vuex'

const store = createStore({
  state: () => ({
    count: 0,
    user: null,
  }),

  getters: {
    doubleCount: (state) => state.count * 2,
  },

  mutations: {
    INCREMENT(state)        { state.count++ },
    SET_USER(state, user)  { state.user = user },
  },

  actions: {
    async fetchUser({ commit }, userId) {
      const user = await api.getUser(userId)   // 비동기 가능
      commit('SET_USER', user)
    },
  },
})

// 컴포넌트에서 사용
store.state.count             // 상태 접근
store.getters.doubleCount     // getter 접근
store.commit('INCREMENT')     // 동기 변경
store.dispatch('fetchUser', 1) // 비동기 액션
```

## Modules — 스토어 분리

```javascript
const postModule = {
  namespaced: true,
  state: () => ({ posts: [] }),
  mutations: {
    SET_POSTS(state, posts) { state.posts = posts }
  },
  actions: {
    async fetchPosts({ commit }) {
      const posts = await api.getPosts()
      commit('SET_POSTS', posts)
    }
  }
}

const store = createStore({
  modules: { post: postModule }
})

// 네임스페이스 접근
store.dispatch('post/fetchPosts')
store.state.post.posts
```

## Vuex vs Pinia vs 지역 상태

| | Vuex | [[Pinia]] | 지역 상태 (`ref`/`reactive`) |
|---|---|---|---|
| 구조 | state/mutations/actions | state/actions (getters 통합) | 없음 |
| 타입스크립트 | 설정 복잡 | 기본 지원 | 기본 지원 |
| 보일러플레이트 | 많음 | 적음 | 없음 |
| Devtools | 지원 | 지원 | 제한적 |
| 권장 여부 | Vue 3에서 Pinia 권장 | Vue 3 공식 권장 | 컴포넌트 내 단순 상태 |

## 언제 전역 상태가 필요한가

- 여러 컴포넌트에서 **같은 데이터를 공유·수정**할 때
- 페이지 이동 시 상태를 유지해야 할 때
- 비동기 서버 데이터를 캐싱할 때

> 단일 컴포넌트 내에서만 쓰이는 상태는 지역 상태(`ref`)로 충분 — 전역 상태 남용 시 디버깅이 어려워짐.

## 핵심 정리

- State 변경은 반드시 Mutations를 통해서만 — 추적 가능성 확보

- 비동기는 Actions에서, 동기 변경은 Mutations에서 — 역할 분리

- Vue 3에서는 Pinia가 공식 권장 (Vuex 5 = Pinia) — 보일러플레이트 대폭 감소

→ [[Redux]] | [[Zustand]]
