"use client"

import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { ReactQueryDevtools } from "@tanstack/react-query-devtools"
import { useState, type ReactNode } from "react"
import { GLOBAL_QUERY_CONFIG } from "@/lib/query-defaults"

/**
 * QueryClient는 useState로 lazy 생성.
 * 모듈 스코프에 직접 만들면 SSR + suspense 환경에서 요청 간 상태가 섞일 수 있다.
 *
 * 사용:
 *   // app/layout.tsx
 *   import { QueryProvider } from "@/providers/query-provider"
 *   <QueryProvider>{children}</QueryProvider>
 */
export function QueryProvider({ children }: { children: ReactNode }) {
  const [client] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: GLOBAL_QUERY_CONFIG,
          mutations: { retry: 0 },
        },
      }),
  )

  return (
    <QueryClientProvider client={client}>
      {children}
      {process.env.NODE_ENV === "development" && <ReactQueryDevtools />}
    </QueryClientProvider>
  )
}
