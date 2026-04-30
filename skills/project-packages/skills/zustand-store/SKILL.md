---
name: zustand-store
description: Zustand 표준 store 패턴(State/Actions 인터페이스 분리)과 인증 사용자 store(useUserStore)를 stores/ 폴더에 박는다. Supabase 인증과 연결된 fetchUser/logout/reset 액션 포함. "zustand 세팅", "store 만들어줘", "user store 추가", "인증 store 셋업", "zustand 스토어 패턴 적용" 등에 트리거. 인증은 Supabase 사용 가정 — 다른 인증이면 fetchUser/logout 본문만 교체하면 됨.
---

# Zustand Store 표준 패턴

State와 Actions를 분리한 표준 store 패턴 + 자주 쓰는 user store 1개.

## 왜 이 패턴인가

| 결정 | 이유 |
|-----|-----|
| State / Actions 인터페이스 분리 | 타입 hover 시 가독성, 액션만 따로 export 가능 |
| 비동기 액션을 store 안에 둠 | 컴포넌트에서 `try/catch + setUser` 반복 제거 |
| `initialState` 상수 분리 + `reset()` | 로그아웃, 테스트 등에서 일관된 초기화 |
| 컴포넌트에서 selector 사용 권장 | 불필요한 리렌더 방지 |

## 워크플로우

### 1. 패키지 설치

```bash
pnpm add zustand
```

### 2. 위치 결정

| 구조 | 폴더 |
|-----|-----|
| `src/` | `src/stores/` |
| 루트 | `stores/` |

### 3. 파일 생성

`assets/user-store.ts` → `stores/user-store.ts`

전제: `lib/supabase/client.ts`가 이미 있어야 한다. 없으면 `supabase-clients` 스킬을 먼저 적용하거나, 사용자에게 인증 방식을 물어 fetchUser/logout 본문을 교체.

### 4. 사용 예시 안내

스킬 실행 후 사용자에게:

```tsx
// 컴포넌트에서
import { useUserStore } from "@/stores/user-store"

function Profile() {
  const user = useUserStore((s) => s.user)
  const fetchUser = useUserStore((s) => s.fetchUser)
  // ...
}

// 앱 부팅 시 한 번 (예: app/layout 또는 auth provider)
useEffect(() => { fetchUser() }, [])
```

### 5. 추가 store 양산 가이드 (선택)

다른 store 만들 때 같은 패턴:

```ts
interface FooState { ... }
interface FooActions { ... }
const initialState: FooState = { ... }
export const useFooStore = create<FooState & FooActions>()((set) => ({
  ...initialState,
  // actions
  reset: () => set(initialState),
}))
```

### 6. CLAUDE.md 사용 규칙 (선택)

```markdown
## Zustand 사용 규칙

- store는 항상 State / Actions 인터페이스 분리, `initialState` 상수, `reset()` 포함.
- 컴포넌트에서는 selector 사용: `useFooStore((s) => s.bar)` — store 전체 구독 금지.
- 비동기 로직은 store 내부 액션으로. 컴포넌트에서 `setX(await fetch())` 패턴 금지.
- 인증/세션 관련 상태는 항상 user-store에 모은다 (분산 금지).
```

## 산출물

- `stores/user-store.ts`
- (선택) CLAUDE.md 사용 규칙

## 비-목표

- 이 스킬은 **persist middleware (localStorage)** 를 기본으로 포함하지 않음. 필요하면 사용자가 요청 시 추가.
- 도메인별 store(예: `cart-store`, `ui-store`)는 만들지 않음. 패턴만 깔아둠.
