---
name: form-validation
description: react-hook-form + zod + shadcn/ui Form 표준 패턴 셋업. 패키지 설치, shadcn form 컴포넌트 추가, 그리고 표준 폼 예시(zod 스키마 외부, z.infer 타입, FormField 래핑)를 components/forms/ 아래에 박는다. "react-hook-form 셋업", "zod 폼 검증", "form 패턴 적용", "폼 검증 표준화", "shadcn form 추가" 등에 트리거. shadcn/ui가 이미 초기화된 프로젝트 전제.
---

# Form Validation 표준 (react-hook-form + zod + shadcn)

폼 작성 표준을 한 번에 깐다.

## 왜 이 조합인가

| 요소 | 역할 |
|-----|-----|
| **zod** | 단일 진실 원천. 스키마에서 TS 타입을 자동 도출 (`z.infer`) — 타입과 검증 분리 금지 |
| **react-hook-form** | uncontrolled + 리렌더 최소화 폼 상태 관리 |
| **shadcn/ui Form** | 에러 메시지 표시, 라벨 연결, 접근성 자동 처리 |
| **@hookform/resolvers/zod** | 위 셋을 잇는 어댑터 |

이 조합 없이 `useState + onChange + 수동 검증`을 쓰면, 폼 개수만큼 다른 코드가 생기고 에러 표시 일관성이 깨진다.

## 워크플로우

### 1. 패키지 설치

```bash
pnpm add react-hook-form zod @hookform/resolvers
```

### 2. shadcn Form 컴포넌트 추가

```bash
npx shadcn@latest add form input button
```

(이미 있으면 건너뛴다.)

### 3. 표준 예시 파일 배치

`assets/form-example.tsx`를 `components/forms/login-form.tsx` 같은 곳에 복사.
실제 프로젝트에 로그인 폼이 필요한 경우 그대로 출발점으로 쓰고, 아니면 참고용으로 둔다.

> 사용자에게: "어떤 폼이 첫 폼인가요? 로그인이면 그대로 두고, 다른 거면 (회원가입/검색/필터 등) 같은 패턴으로 변환해 만들어드립니다."

### 4. 패턴 핵심 4가지

표준 예시가 보여주는 규칙:

1. **zod 스키마는 컴포넌트 밖에.** 같은 스키마를 서버 액션에서도 재검증할 수 있어야 한다.
2. **`z.infer<typeof schema>`로 타입 도출.** 별도 `interface FormValues` 작성 금지 — 스키마와 타입 동기화 깨진다.
3. **shadcn Form 래핑 필수.** `<input {...register} />` 직접 사용 금지 — 에러 표시 일관성 깨짐.
4. **서버 에러는 `form.setError`로.** 폼 컴포넌트 안에 별도 `errorMessage` state 두지 않는다.

### 5. CLAUDE.md 사용 규칙 (선택)

```markdown
## 폼 작성 규칙

- 모든 폼은 react-hook-form + zod + shadcn Form 조합 사용. useState 기반 폼 금지.
- zod 스키마는 컴포넌트 외부에 정의. 가능하면 같은 스키마를 서버 액션에서도 사용.
- 타입은 `z.infer<typeof schema>`로 도출. 별도 interface 정의 금지.
- 서버 검증 에러는 `form.setError("필드명", { message })`로 매핑. 별도 errorMessage state 두지 않음.
- 제출 중 비활성화: `disabled={form.formState.isSubmitting}`.
```

## 산출물

- `package.json`에 `react-hook-form`, `zod`, `@hookform/resolvers` 추가
- shadcn `form`, `input`, `button` 컴포넌트
- `components/forms/login-form.tsx` (참고용 예시)
- (선택) CLAUDE.md 사용 규칙

## 비-목표

- 이 스킬은 **모든 폼을 미리 만들어두지 않는다.** 첫 폼 1개 + 패턴만 박는다.
- 서버 액션 자체는 다루지 않음. (별도 스킬 영역)
