---
name: tanstack-query
description: TanStack Query 표준 setup 3종 (전역 캐시 설정, queryKey 팩토리, QueryProvider) + devtools를 한 번에 박는다. lib/query-defaults.ts에 GLOBAL_QUERY_CONFIG/SHORT_CACHE_CONFIG/REALTIME_CONFIG 정의, lib/query-keys.ts에 도메인별 query key, providers/query-provider.tsx에 클라이언트 Provider. "tanstack query 세팅", "react-query 셋업", "QueryClient 만들어줘", "queryKey 팩토리 추가", "react query provider", "리액트 쿼리 캐시 설정" 등에 트리거. SWR이 아니라 TanStack Query 사용 프로젝트가 전제.
---

# TanStack Query 표준 setup

새 프로젝트에 React Query 인프라 3개를 한 번에 깐다.

## 왜 이 3개를 묶는가

| 파일 | 역할 |
|------|------|
| `lib/query-defaults.ts` | staleTime/gcTime 같은 캐시 정책 — 컴포넌트마다 다르면 동작 예측 불가 |
| `lib/query-keys.ts` | 도메인별 queryKey 팩토리 — invalidate prefix 매칭 깨짐 방지 |
| `providers/query-provider.tsx` | QueryClient lifecycle 관리 + devtools — SSR 안전 |

이 셋이 합쳐져야 "캐시가 의도대로 동작하는" 환경이 된다.

## 워크플로우

### 1. 패키지 설치

```bash
pnpm add @tanstack/react-query
pnpm add -D @tanstack/react-query-devtools
```

### 2. 위치 결정

| 구조 | 파일들 |
|-----|-------|
| `src/` | `src/lib/query-defaults.ts`, `src/lib/query-keys.ts`, `src/providers/query-provider.tsx` |
| 루트 | `lib/query-defaults.ts`, `lib/query-keys.ts`, `providers/query-provider.tsx` |

### 3. 파일 생성

| asset | 대상 위치 |
|-------|---------|
| `query-defaults.ts` | `lib/query-defaults.ts` |
| `query-keys.ts` | `lib/query-keys.ts` |
| `query-provider.tsx` | `providers/query-provider.tsx` |

### 4. 루트 layout에 Provider 적용

`app/layout.tsx`에 `<QueryProvider>` 래핑:

```tsx
import { QueryProvider } from "@/providers/query-provider"

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ko">
      <body>
        <QueryProvider>{children}</QueryProvider>
      </body>
    </html>
  )
}
```

기존 layout이 있다면 안전하게 children만 감싸도록 편집한다.

### 5. queryKey 도메인 채우기 안내

`assets/query-keys.ts`는 `users` 예시만 있고 `posts`는 주석. 사용자에게:

> "주요 도메인이 뭔가요? (예: posts, comments, projects). 알려주시면 query-keys.ts에 미리 박아드립니다. 일단 지금은 users만 들어가 있어요."

도메인 받으면 같은 패턴으로 추가.

### 6. CLAUDE.md 사용 규칙 (선택)

```markdown
## React Query 사용 규칙

- 모든 useQuery/useMutation은 `lib/query-keys.ts`의 키만 사용. 인라인 배열 금지.
  - 이유: invalidate 시 prefix 매칭 정합성 보장.
- staleTime/gcTime은 개별 훅에서 오버라이드하지 않는다. 짧은 캐시는 SHORT_CACHE_CONFIG, 실시간은 REALTIME_CONFIG 사용.
- 새 도메인이 생기면 query-keys.ts에 먼저 추가하고 훅 작성.
```

## 산출물

- `lib/query-defaults.ts`, `lib/query-keys.ts`
- `providers/query-provider.tsx`
- `app/layout.tsx`에 Provider 적용
- (선택) CLAUDE.md 사용 규칙

## 비-목표

- 이 스킬은 **개별 useQuery 훅을 만들지 않는다.** 인프라만 깐다.
- SWR과 병행 사용 권장하지 않음 — 클라이언트 캐싱 도구는 하나로 통일.
