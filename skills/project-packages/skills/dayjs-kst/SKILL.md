---
name: dayjs-kst
description: 한국 서비스용 dayjs 중앙 setup 파일을 생성. timezone(Asia/Seoul) + 한국어 locale + utc/timezone plugin을 한 번에 등록하고, parseDateOnly/formatDateOnly/parseTimestamp/formatDateTime/extractTime 같은 자주 쓰는 헬퍼를 묶어 lib/dayjs.ts로 박아넣는다. "dayjs 세팅", "날짜 모듈화", "한국 타임존 설정", "date-fns 대신 dayjs", "lib/dayjs.ts 만들어줘", "날짜 포맷 헬퍼" 같은 요청에 트리거. 새 프로젝트 초기 세팅이나 기존 프로젝트의 흩어진 dayjs 호출을 중앙화할 때 사용.
---

# Dayjs KST 중앙 setup

한국 서비스에서 반복되는 dayjs 설정을 **단 한 번만** 하도록 표준 파일을 생성한다.

## 왜 필요한가

- **plugin 등록 누락**: 컴포넌트마다 `import dayjs from "dayjs"` 하면 `dayjs.tz()` 호출 시 plugin 미등록 에러가 산발적으로 발생한다.
- **timezone shift**: `YYYY-MM-DD` 같은 date-only 값을 그냥 `new Date()`로 파싱하면 로컬 타임존에 따라 하루씩 밀리는 버그가 잦다. `parseDateOnly`로 일괄 처리.
- **한국어 locale**: `dayjs().format("LL")` 같은 호출이 자동으로 한국어로 나오게.

## 워크플로우

### 1. 위치 결정

| 프로젝트 구조 | 파일 위치 |
|------------|---------|
| `src/` 구조 | `src/lib/dayjs.ts` |
| 루트 직접 | `lib/dayjs.ts` |

다른 프로젝트들과 일관성 위해 `dayjs.ts` 파일명 그대로 둔다 (`date.ts`, `date-utils.ts` 등으로 바꾸지 않음).

### 2. 패키지 설치

```bash
pnpm add dayjs
```

### 3. 파일 생성

`assets/dayjs.ts`를 결정한 위치에 복사한다.

이미 `lib/dayjs.ts`가 있다면 → 사용자에게 기존 파일 보여주고 덮어쓸지 / 헬퍼만 추가할지 물어본다.

### 4. 기존 코드 마이그레이션 안내

스킬 실행 후 사용자에게 다음을 안내한다:

> 기존 코드에서 `import dayjs from "dayjs"`를 모두 `import dayjs from "@/lib/dayjs"`로 바꿔야 합니다. 자동 변환을 원하시면 말씀해주세요.

자동 변환 요청 시:

```bash
# Next.js (alias가 @/ 인 경우)
grep -rl 'from ["\x27]dayjs["\x27]' src/ app/ components/ hooks/ 2>/dev/null \
  | xargs -I{} sed -i '' 's|from "dayjs"|from "@/lib/dayjs"|g; s|from '\''dayjs'\''|from '\''@/lib/dayjs'\''|g' {}
```

(macOS sed 기준. 작업 전 git status 깨끗한지 확인하고 실행할 것.)

### 5. 사용 패턴 안내 (CLAUDE.md 추가)

선택적으로 다음 블록을 CLAUDE.md에 추가:

```markdown
## 날짜 처리 규칙

- 모든 dayjs 호출은 `@/lib/dayjs`에서 import. 직접 `from "dayjs"` 금지.
  - 이유: timezone/locale/plugin이 등록된 인스턴스를 보장하기 위함.
- date-only 문자열(YYYY-MM-DD)은 `parseDateOnly()` 사용. `new Date()` 직접 호출 금지.
- 입력 form의 Date + "HH:mm"은 `formatDateTime()` 사용.
```

## 산출물

- `lib/dayjs.ts` (또는 `src/lib/dayjs.ts`)
- `package.json`에 `dayjs` 추가
- (선택) 기존 코드의 import 경로 일괄 변환
- (선택) CLAUDE.md에 날짜 규칙 블록

## 헬퍼 함수 요약

| 함수 | 입력 | 출력 | 용도 |
|------|-----|-----|------|
| `parseDateOnly(s)` | `"2026-04-30"` | `Dayjs \| null` | date-only 컬럼 |
| `formatDateOnly(d)` | `Date / Dayjs` | `"2026-04-30"` | UI 표시용 |
| `parseTimestamp(s)` | ISO 문자열 | `Dayjs \| null` | created_at 등 |
| `formatDateTime(date, "14:30")` | Date + 시각 | ISO 문자열 (KST) | form 입력 |
| `extractTime(d)` | 날짜값 | `"14:30"` | 시간만 표시 |
