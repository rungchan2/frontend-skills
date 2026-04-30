---
name: package-map
description: 기능별 표준 패키지 룩업 표. "PDF 파싱하려면 뭘 써야 해?", "이미지 크롭 라이브러리 추천", "차트 어떤 거 써?", "토스트는 어느 라이브러리?", "스프레드시트 다루는 패키지" 같은 "이 기능 → 어떤 패키지" 질문에 트리거. 본인 표준 답을 통일하는 reference 스킬. 새로운 기능을 시작할 때 매번 다른 라이브러리를 고르지 않도록 함.
---

# 기능별 표준 패키지 매핑

새 기능 만들 때 "어떤 라이브러리 쓰지?"에 대한 본인 표준 답.
같은 기능에 매 프로젝트마다 다른 패키지를 골라 학습 비용이 누적되는 걸 막는다.

## 사용 방법

사용자가 "X 기능 만들려면 뭐 써야 해?"라고 물으면 아래 표에서 찾아 답한다.
표에 없는 기능이면 솔직히 "아직 표준 정해진 게 없다"고 답하고, 사용자가 결정한 답을 이 표에 추가하도록 제안.

---

## 인프라 / 유틸 (project-packages 스킬에서 자동 처리)

| 기능 | 표준 패키지 | 적용 스킬 |
|-----|-----------|----------|
| Tailwind className 병합 | `clsx` + `tailwind-merge` | `tailwind-cn` |
| 통화 포맷 (KRW) | `Intl.NumberFormat` (formatCurrency 헬퍼) | `tailwind-cn` |
| 날짜 처리 (KST) | `dayjs` + utc/timezone plugin + ko locale | `dayjs-kst` |
| 클라이언트 캐싱 | `@tanstack/react-query` | `tanstack-query` |
| 전역 상태 | `zustand` | `zustand-store` |
| 폼 검증 | `react-hook-form` + `zod` + `@hookform/resolvers` | `form-validation` |
| BaaS / Auth | `@supabase/ssr` + `@supabase/supabase-js` | `supabase-clients` |

## UI

| 기능 | 표준 패키지 | 비고 |
|-----|-----------|-----|
| 컴포넌트 라이브러리 | `shadcn/ui` (CLI 기반) | Radix + Tailwind |
| 아이콘 | `lucide-react` | shadcn 기본 |
| 토스트 | `sonner` | shadcn 통합 잘 됨 |
| 다이얼로그 / 모달 | shadcn `dialog` | Radix 기반 |
| 드롭다운 / 콤보박스 | shadcn `select`, `command` | Radix 기반 |
| 차트 | `recharts` | shadcn `chart` 컴포넌트 사용 |
| 테이블 (복잡) | `@tanstack/react-table` + shadcn `table` | 정렬/필터/페이지네이션 |
| 캘린더 / 날짜 선택 | shadcn `calendar` (react-day-picker) | dayjs와 별개로 입력용 |
| 풀캘린더 (이벤트 뷰) | `@fullcalendar/react` | 일정/스케줄 화면 |
| 드래그앤드롭 | `@dnd-kit/core` | react-beautiful-dnd 비추 (유지보수 중단) |
| 애니메이션 | `framer-motion` | 페이지 트랜지션, 마이크로 인터랙션 |

## 데이터 / 파일

| 기능 | 표준 패키지 | 비고 |
|-----|-----------|-----|
| 파일 업로드 (Supabase) | `@supabase/storage-js` (이미 supabase-js에 포함) | RLS 정책 신경 |
| 이미지 크롭 | `react-easy-crop` | |
| 이미지 압축 (클라이언트) | `browser-image-compression` | 업로드 전 사전처리 |
| PDF 생성 (서버) | `@react-pdf/renderer` | React 컴포넌트로 PDF 렌더 |
| PDF 미리보기 | `react-pdf` | viewer |
| 엑셀 생성/파싱 | `xlsx` (sheetjs) | |
| CSV 파싱 | `papaparse` | |
| QR 코드 | `qrcode.react` | 생성 |
| QR 스캔 | `html5-qrcode` | 카메라 입력 |

## 서버 / API

| 기능 | 표준 패키지 | 비고 |
|-----|-----------|-----|
| HTTP 클라이언트 (필요 시) | `fetch` 우선 / 복잡하면 `ky` | axios 지양 |
| Cron / 스케줄링 | Vercel Cron (vercel.json) | self-hosted면 `node-cron` |
| 결제 (국내) | `@portone/browser-sdk` | PortOne (구 아임포트) |
| 알림톡 / SMS | `aligo` API 직접 호출 | |
| 이메일 | Resend (`resend` SDK) | |
| Sentry | `@sentry/nextjs` | 에러 추적 |
| Google Analytics | `@next/third-parties/google` | Next.js 공식 |

## 검색 / 입력

| 기능 | 표준 패키지 | 비고 |
|-----|-----------|-----|
| 디바운스 / 쓰로틀 | `es-toolkit` (lodash 대체) | 트리쉐이킹 우수 |
| 한글 자모 검색 | `hangul-js` | 초성 검색 등 |
| Markdown 렌더 | `react-markdown` + `remark-gfm` | |
| 코드 하이라이트 | `shiki` | rehype-pretty-code 통해서 |
| Rich Text Editor | `@tiptap/react` | ProseMirror 기반 |

## 테스트

| 기능 | 표준 패키지 | 비고 |
|-----|-----------|-----|
| 단위 테스트 | `vitest` | jest보다 빠르고 ESM 친화적 |
| 컴포넌트 테스트 | `@testing-library/react` | |
| E2E | `@playwright/test` 또는 `agent-browser` | 자연어 시나리오는 agent-browser |
| Mock 서버 | `msw` | |

## 개발 도구

| 기능 | 표준 패키지 | 비고 |
|-----|-----------|-----|
| 린터 | Biome 또는 ESLint + Prettier | 신규는 Biome 추천 |
| 타입 체크 | `typescript` | strict 항상 켬 |
| Git hook | `simple-git-hooks` + `lint-staged` | husky 대체 |
| 환경변수 검증 | `@t3-oss/env-nextjs` + `zod` | 빌드 타임 검증 |

---

## 표 갱신 정책

- 새 프로젝트에서 표에 없는 라이브러리를 골랐다면, 그 결정을 **이 SKILL.md에 추가하는 PR을 만든다.**
- 동일 기능에 다른 라이브러리 쓰는 게 정당한 이유가 있을 때만 허용 (예: 이 프로젝트는 폼이 없으므로 react-hook-form 미설치).
- 표가 정답이 아니라 **현재 본인 표준의 스냅샷**이다. 더 좋은 게 나오면 갱신.
