---
name: tailwind-cn
description: shadcn/ui 사용 프로젝트의 표준 cn() 유틸을 세팅. Tailwind class 병합 헬퍼(clsx + tailwind-merge)와 KRW 통화 포맷 등 자주 쓰는 유틸을 lib/utils.ts에 박아넣는다. 새 프로젝트 시작 시, 또는 "cn 유틸 세팅", "tailwind merge 헬퍼 추가", "shadcn utils 만들어줘", "lib/utils.ts 표준화" 같은 요청에 트리거. shadcn/ui CLI(`npx shadcn@latest init`)를 막 돌렸거나 돌리려는 시점에 사용.
---

# Tailwind cn() 유틸 표준 세팅

shadcn/ui 기반 프로젝트의 `lib/utils.ts`를 **표준 형태로 한 번에** 세팅한다.

## 왜 필요한가

- 모든 프로젝트에서 `cn()`은 사실상 동일하게 쓰인다. 매번 다시 짜거나 조금씩 다른 변형이 생기는 걸 막는다.
- `formatCurrency` 같은 한국 환경 표준 포맷도 같이 박아두면, 컴포넌트에서 `Intl.NumberFormat` 직접 호출이 사라진다.

## 워크플로우

### 1. 위치 결정

프로젝트 루트의 `tsconfig.json` 또는 `components.json`을 확인해 alias 경로를 본다.

| 프로젝트 구조 | 파일 위치 |
|------------|---------|
| `src/` 구조 (Next.js 표준 신규) | `src/lib/utils.ts` |
| 루트 직접 (`app/`, `lib/`가 루트에 있음) | `lib/utils.ts` |

`components.json`이 이미 있다면 그 안의 `aliases.utils` 값을 우선한다.

### 2. 패키지 설치

```bash
pnpm add clsx tailwind-merge
# 또는 npm install / yarn add / bun add
```

(이미 설치되어 있으면 건너뛴다.)

### 3. 파일 생성

`assets/utils.ts`를 결정한 위치에 그대로 복사한다.

기존 파일이 있다면:
- shadcn CLI가 만든 기본 `cn()`만 있는 경우 → 통째로 덮어쓴다.
- 다른 export가 추가되어 있는 경우 → `cn`과 `formatCurrency`만 표준 버전으로 교체하고 나머지는 보존한다. 사용자에게 어떤 export가 있는지 알려주고 확인받는다.

### 4. 사용 패턴 안내 (CLAUDE.md 추가)

선택적으로 프로젝트 CLAUDE.md에 다음 블록을 추가:

```markdown
## 스타일 유틸 사용 규칙

- 모든 className 결합은 `cn()` 사용. 직접 문자열 결합 금지.
  ```tsx
  // ✅
  <div className={cn("p-4", isActive && "bg-blue-500")} />
  // ❌
  <div className={`p-4 ${isActive ? "bg-blue-500" : ""}`} />
  ```
- 통화 표시는 `formatCurrency` 사용. 컴포넌트에서 `Intl.NumberFormat` 직접 호출하지 않음.
```

CLAUDE.md 갱신 여부는 사용자에게 물어본 뒤 진행한다 (강제하지 않음).

## 산출물

- `lib/utils.ts` (또는 `src/lib/utils.ts`)
- `package.json`에 `clsx`, `tailwind-merge` 추가
- (선택) CLAUDE.md에 사용 규칙 블록 추가
