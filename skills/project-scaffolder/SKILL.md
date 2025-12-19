---
name: project-scaffolder
description: 프론트엔드 프로젝트 구조를 분석하고 정리하여 AI 에이전트가 활용할 수 있는 컨텍스트 문서를 생성하는 스킬. "프로젝트 구조 잡아줘", "폴더 구조 정리해줘", "아키텍처 문서화해줘", "프로젝트 초기 설정해줘" 등의 요청에 트리거된다. Next.js, Supabase, React 등 다양한 프론트엔드 스택에서 범용적으로 사용 가능하다.
---

# Project Scaffolder

프론트엔드 프로젝트의 구조를 분석하고, AI 에이전트(Claude, Cursor, Windsurf 등)가 활용할 수 있는 아키텍처 컨텍스트 문서를 생성한다.

## 목적

1. **프로젝트 초기 구조 설정** - 일관된 폴더/파일 구조 수립
2. **아키텍처 문서화** - AI 에이전트의 core memory/context로 활용
3. **팀 온보딩** - 새 팀원이 프로젝트 구조 빠르게 파악
4. **일관성 유지** - 코딩 규칙과 패턴 표준화

## 워크플로우

### 1. 프로젝트 스택 파악

사용자에게 확인할 사항:
- **프레임워크**: Next.js, React, Vue, Nuxt 등
- **백엔드/BaaS**: Supabase, Firebase, Prisma, 자체 API 등
- **상태관리**: TanStack Query, Zustand, Redux, Jotai 등
- **UI 라이브러리**: shadcn/ui, MUI, Chakra 등
- **기존 프로젝트 여부**: 기존 구조 분석 vs 새로 생성

### 2. 기존 프로젝트 분석 (해당 시)

분석 대상:
```bash
# 폴더 구조 파악
find . -type d -name "node_modules" -prune -o -type d -print | head -50

# 핵심 파일 확인
ls -la lib/ app/ components/ hooks/ types/ spec/
```

### 3. 아키텍처 문서 생성

`spec/PROJECT_ARCHITECTURE.md` 파일 생성:
- 3-Layer 아키텍처 정의
- 폴더 구조 및 역할
- 코딩 규칙
- 외부 연동 패턴

### 4. CLAUDE.md / .cursorrules 업데이트

AI 에이전트 컨텍스트 파일에 아키텍처 규칙 추가.

---

## 핵심 아키텍처 패턴

### 3-Layer Separation (필수)

```
┌─────────────────────────────────────────────┐
│ Component Layer (UI Logic)                  │
│ - Import hooks from /hooks/                 │
│ - NO database client, NO inline queries     │
└─────────────────┬───────────────────────────┘
                  │ imports
┌─────────────────▼───────────────────────────┐
│ Hook Layer (Query Management)               │
│ - TanStack Query hooks                      │
│ - Import service functions                  │
│ - NO database client                        │
└─────────────────┬───────────────────────────┘
                  │ imports
┌─────────────────▼───────────────────────────┐
│ Service Layer (Data Access)                 │
│ - Pure functions with database queries      │
│ - File: /lib/services/{domain}.ts           │
│ - ONLY place for database client            │
└─────────────────────────────────────────────┘
```

### 폴더 구조 표준

```
project/
├── app/                    # Next.js App Router pages
│   ├── api/               # API routes (외부 연동만)
│   └── [feature]/         # Feature pages
│
├── components/            # React Components
│   ├── ui/               # Base UI (shadcn/ui 등)
│   └── [feature]/        # Feature-specific components
│
├── hooks/                 # Custom React Hooks
│   └── use-[domain]-query.ts  # TanStack Query hooks
│
├── lib/                   # Core Business Logic
│   ├── services/         # Data Access Layer (DAL)
│   ├── supabase/         # Database client (Supabase 사용 시)
│   ├── api/              # External API clients
│   ├── auth/             # Authentication logic
│   ├── utils/            # Utility functions
│   ├── constants.ts      # Global constants
│   └── menu-configs.ts   # Navigation config
│
├── types/                 # TypeScript Definitions
│   ├── database.types.ts # Auto-generated DB types
│   ├── models.ts         # Domain model types
│   └── enums.ts          # Enum definitions
│
├── stores/               # Client State (Zustand)
├── providers/            # React Context Providers
│
├── spec/                 # Specifications & Docs
│   ├── PROJECT_ARCHITECTURE.md
│   ├── database-schema.md
│   └── detailed-features/
│
├── documentations/       # External API Docs
│   ├── [api-name]/      # Per-API documentation
│   └── ...
│
└── supabase/            # Supabase Config (해당 시)
    └── migrations/      # Database migrations
```

---

## 구성 요소별 가이드

### 1. Service Layer (`lib/services/`)

**역할**: 모든 데이터베이스 쿼리를 캡슐화하는 Data Access Layer

**파일 네이밍**: `{domain}-service.ts` 또는 `{table}.ts`

**패턴**:
```typescript
// lib/services/students.ts
import { createClient } from '@/lib/supabase/client'
import type { StudentRow, StudentInsert } from '@/types/models'

export async function getStudents(centerId: number): Promise<StudentRow[]> {
  const supabase = createClient()
  const { data, error } = await supabase
    .from('students')
    .select('*')
    .eq('center_id', centerId)

  if (error) throw error
  return data
}

export async function createStudent(data: StudentInsert): Promise<StudentRow> {
  // ...
}
```

**규칙**:
- 모든 함수는 명시적 반환 타입 필수
- async 함수는 `Promise<T>` 반환
- 타입은 `/types/models.ts`에서 import

### 2. Hook Layer (`hooks/`)

**역할**: TanStack Query로 서버 상태 관리

**파일 네이밍**: `use-{domain}-query.ts`

**패턴**:
```typescript
// hooks/use-students-query.ts
import { useQuery, useMutation } from '@tanstack/react-query'
import { getStudents, createStudent } from '@/lib/services/students'

export function useStudentsQuery(centerId: number) {
  return useQuery({
    queryKey: ['students', centerId],
    queryFn: () => getStudents(centerId),
    enabled: !!centerId,
  })
}

export function useCreateStudentMutation() {
  return useMutation({
    mutationFn: createStudent,
    // ...
  })
}
```

**규칙**:
- Service 함수만 import (DB 클라이언트 직접 사용 금지)
- queryKey는 일관된 패턴 유지

### 3. Component Layer (`components/`, `app/`)

**역할**: UI 렌더링 및 사용자 인터랙션

**패턴**:
```typescript
// components/students/student-list.tsx
import { useStudentsQuery } from '@/hooks/use-students-query'

export function StudentList({ centerId }: { centerId: number }) {
  const { data: students, isLoading } = useStudentsQuery(centerId)
  // UI 로직만
}
```

**규칙**:
- hooks에서만 데이터 가져오기
- DB 클라이언트 import 금지
- 인라인 쿼리 정의 금지

### 4. Constants (`lib/constants.ts`)

**역할**: 비즈니스 로직 상수의 Single Source of Truth

**패턴**:
```typescript
// lib/constants.ts
export const CLASS_TIME = {
  MIN_HOUR: 14,
  MAX_HOUR: 21,
  MIN_TIME: '14:00',
  MAX_TIME: '21:00',
} as const

export const PAGINATION = {
  DEFAULT_PAGE_SIZE: 20,
  PAGE_SIZE_OPTIONS: [10, 20, 50, 100],
} as const
```

### 5. Menu Config (`lib/menu-configs.ts`)

**역할**: 네비게이션 메뉴의 중앙 집중 관리

**패턴**:
```typescript
// lib/menu-configs.ts
export function getCenterMenuData(): MenuData {
  return {
    navMain: [
      { title: "대시보드", url: "/center/dashboard", icon: Home },
      { title: "학생 관리", url: "/center/students", icon: Users },
      // ...
    ]
  }
}
```

### 6. External API Docs (`documentations/`)

**역할**: 외부 API/라이브러리 문서 중앙 저장

**구조**:
```
documentations/
├── alim-talk/          # 카카오 알림톡
├── fullcalendar/       # FullCalendar 라이브러리
├── onedrive/           # Microsoft Graph API
├── openai/             # OpenAI API
└── shadcn/             # shadcn/ui 커스터마이징
```

### 7. Spec Files (`spec/`)

**역할**: 시스템 명세 및 설계 문서

**필수 파일**:
- `PROJECT_ARCHITECTURE.md` - 프로젝트 아키텍처 개요
- `database-schema.md` - DB 스키마 문서
- `detailed-features/` - 기능별 상세 명세

---

## 출력물

### 1. `spec/PROJECT_ARCHITECTURE.md`

프로젝트 아키텍처 전체 문서:
- 기술 스택
- 폴더 구조
- 3-Layer 패턴
- 코딩 규칙
- 외부 연동 목록

### 2. CLAUDE.md / .cursorrules 업데이트

AI 에이전트용 규칙 추가:
```markdown
## Data Layer Architecture - SOLID Principles (MANDATORY)

CRITICAL: This project follows strict 3-layer architecture.

- Component Layer: hooks에서만 데이터 import
- Hook Layer: service 함수만 import
- Service Layer: DB 클라이언트 사용 (유일한 장소)

### 금지 패턴
- ❌ Component에서 DB 클라이언트 직접 사용
- ❌ Hook에서 인라인 쿼리 정의
- ❌ Service 외부에서 Supabase/Prisma 호출
```

---

## 스택별 변형

### Supabase + Next.js

```
lib/supabase/
├── client.ts      # Browser client
├── server.ts      # Server component client
├── middleware.ts  # Auth middleware
└── service-role.ts # Admin client (서버 전용)
```

### Firebase + Next.js

```
lib/firebase/
├── client.ts      # Firebase app init
├── auth.ts        # Auth functions
├── firestore.ts   # Firestore queries
└── storage.ts     # Storage functions
```

### Prisma + Next.js

```
lib/prisma/
├── client.ts      # Prisma client singleton
└── ...

prisma/
├── schema.prisma  # Database schema
└── migrations/    # Migration files
```

---

## 참조 문서

상세 패턴은 `references/` 폴더 참조:
- `architecture-patterns.md` - 아키텍처 패턴 상세
- `folder-structure-template.md` - 폴더 구조 템플릿
