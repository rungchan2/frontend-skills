/**
 * 타입 안전 query key 팩토리.
 *
 * 컴포넌트/훅에서 직접 ['users', userId] 같은 배열을 쓰지 말고
 * 반드시 이 파일의 키만 사용한다.
 *
 * 이유:
 * - invalidate 시 prefix 매칭이 안 맞으면 캐시 정합성 깨짐
 * - key를 한 곳에 모아두면 어떤 캐시가 있는지 한눈에 파악 가능
 *
 * 도메인이 추가될 때마다 이 파일만 늘어난다.
 */

export const queryKeys = {
  users: {
    all: ["users"] as const,
    me: () => [...queryKeys.users.all, "me"] as const,
    detail: (id: string) => [...queryKeys.users.all, "detail", id] as const,
  },
  // 예시. 프로젝트에 맞게 실제 도메인으로 교체:
  // posts: {
  //   all: ["posts"] as const,
  //   list: (filter: string) => [...queryKeys.posts.all, "list", filter] as const,
  //   detail: (id: string) => [...queryKeys.posts.all, "detail", id] as const,
  // },
} as const
