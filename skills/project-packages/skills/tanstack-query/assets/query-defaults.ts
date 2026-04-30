/**
 * 전역 React Query 기본 설정.
 *
 * - staleTime 30분: 페이지 간 이동 시 불필요한 재요청 방지
 * - gcTime 1시간: 메모리 캐시 보존 시간
 * - refetchOnWindowFocus: false — 사용자 의도적 갱신 외엔 fetch 안 함
 * - refetchOnReconnect: 'always' — 네트워크 복구 시는 재요청
 *
 * 개별 useQuery에서 staleTime을 따로 지정하지 않는 것이 원칙.
 * 짧은 캐시가 필요한 케이스만 SHORT_CACHE_CONFIG, 실시간은 REALTIME_CONFIG 사용.
 */

export const GLOBAL_QUERY_CONFIG = {
  staleTime: 30 * 60 * 1000, // 30분
  gcTime: 60 * 60 * 1000, // 1시간
  refetchOnWindowFocus: false,
  refetchOnMount: false,
  refetchOnReconnect: "always" as const,
}

/** 자주 바뀌는 데이터에만 사용 (예: 알림 카운트). */
export const SHORT_CACHE_CONFIG = {
  staleTime: 1 * 60 * 1000,
  gcTime: 5 * 60 * 1000,
}

/** 실시간성이 중요한 데이터 (예: 출석, 채팅). */
export const REALTIME_CONFIG = {
  staleTime: 0,
  gcTime: 1 * 60 * 1000,
  refetchInterval: 30 * 1000,
}
