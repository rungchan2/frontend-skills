import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

/**
 * Tailwind 클래스 안전 병합.
 * - 조건부 클래스 (clsx)
 * - 충돌 클래스 자동 해소 (tailwind-merge)
 *
 * 모든 컴포넌트에서 className 합칠 때는 이 함수만 사용한다.
 * 직접 string 결합(`${a} ${b}`)은 충돌 시 의도치 않은 클래스가 우선될 수 있음.
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

/**
 * KRW 통화 포맷.
 *   formatCurrency(12000) → "₩12,000"
 */
export function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("ko-KR", {
    style: "currency",
    currency: "KRW",
  }).format(amount)
}
