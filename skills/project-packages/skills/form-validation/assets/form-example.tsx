"use client"

import { zodResolver } from "@hookform/resolvers/zod"
import { useForm } from "react-hook-form"
import { z } from "zod"
import { Button } from "@/components/ui/button"
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { Input } from "@/components/ui/input"

/**
 * 표준 form 패턴.
 *
 * 1. zod 스키마는 컴포넌트 밖에 — 재사용/테스트 용이
 * 2. z.infer로 타입 자동 도출 — 별도 interface 작성 금지
 * 3. shadcn/ui의 Form 컴포넌트로 래핑 — 일관된 에러 표시
 * 4. onSubmit 안에 try/catch 두지 않음 — react-hook-form의 setError로 서버 에러 매핑
 */

const loginSchema = z.object({
  email: z.string().email("올바른 이메일 형식이 아닙니다"),
  password: z.string().min(8, "비밀번호는 최소 8자 이상이어야 합니다"),
})

type LoginInput = z.infer<typeof loginSchema>

export function LoginForm() {
  const form = useForm<LoginInput>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: "", password: "" },
  })

  async function onSubmit(values: LoginInput) {
    // 서버 액션 또는 fetch 호출
    // 서버에서 "이메일 없음" 같은 필드별 에러가 오면:
    //   form.setError("email", { message: "..." })
    console.log(values)
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>이메일</FormLabel>
              <FormControl>
                <Input type="email" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="password"
          render={({ field }) => (
            <FormItem>
              <FormLabel>비밀번호</FormLabel>
              <FormControl>
                <Input type="password" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit" disabled={form.formState.isSubmitting}>
          로그인
        </Button>
      </form>
    </Form>
  )
}
