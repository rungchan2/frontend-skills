import { create } from "zustand"
import { createClient } from "@/lib/supabase/client"
import type { User } from "@supabase/supabase-js"

/**
 * 인증 사용자 상태 store.
 *
 * 패턴:
 * - State와 Actions를 별도 인터페이스로 분리 (타입 가독성)
 * - 비동기 액션은 store 내부에서 supabase client 호출 → set으로 반영
 * - selector 사용을 권장: useUserStore((s) => s.user) 식으로 구독 최소화
 *
 * 컴포넌트에서:
 *   const user = useUserStore((s) => s.user)
 *   const fetchUser = useUserStore((s) => s.fetchUser)
 */

interface UserState {
  user: User | null
  isLoading: boolean
  error: string | null
}

interface UserActions {
  fetchUser: () => Promise<void>
  logout: () => Promise<void>
  reset: () => void
}

const initialState: UserState = {
  user: null,
  isLoading: false,
  error: null,
}

export const useUserStore = create<UserState & UserActions>()((set) => ({
  ...initialState,

  fetchUser: async () => {
    set({ isLoading: true, error: null })
    try {
      const supabase = createClient()
      const {
        data: { user },
        error,
      } = await supabase.auth.getUser()
      if (error) throw error
      set({ user, isLoading: false })
    } catch (e) {
      set({
        error: e instanceof Error ? e.message : "Unknown error",
        isLoading: false,
      })
    }
  },

  logout: async () => {
    const supabase = createClient()
    await supabase.auth.signOut()
    set(initialState)
  },

  reset: () => set(initialState),
}))
