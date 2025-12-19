# Folder Structure Template

새 프로젝트 시작 시 사용할 폴더 구조 템플릿.

## 기본 구조 (Next.js + Supabase)

```
project-name/
│
├── app/                          # Next.js App Router
│   ├── api/                      # API Routes (외부 연동만)
│   │   ├── webhooks/            # Webhook endpoints
│   │   │   └── [service]/
│   │   │       └── route.ts
│   │   └── external/            # External API proxies
│   │       └── [service]/
│   │           └── route.ts
│   │
│   ├── auth/                    # Auth pages
│   │   ├── login/
│   │   │   └── page.tsx
│   │   ├── signup/
│   │   │   └── page.tsx
│   │   └── forgot-password/
│   │       └── page.tsx
│   │
│   ├── [role]/                  # Role-based routes
│   │   ├── dashboard/
│   │   │   └── page.tsx
│   │   ├── [feature]/
│   │   │   ├── page.tsx
│   │   │   ├── [id]/
│   │   │   │   └── page.tsx
│   │   │   └── components/      # Page-specific components
│   │   │       └── feature-form.tsx
│   │   └── layout.tsx
│   │
│   ├── layout.tsx               # Root layout
│   ├── page.tsx                 # Landing page
│   ├── globals.css              # Global styles
│   └── not-found.tsx
│
├── components/                   # React Components
│   ├── ui/                      # Base UI components (shadcn/ui)
│   │   ├── button.tsx
│   │   ├── input.tsx
│   │   ├── dialog.tsx
│   │   └── ...
│   │
│   ├── layout/                  # Layout components
│   │   ├── app-sidebar.tsx
│   │   ├── header.tsx
│   │   └── footer.tsx
│   │
│   ├── common/                  # Shared business components
│   │   ├── data-table.tsx
│   │   ├── search-input.tsx
│   │   └── status-badge.tsx
│   │
│   └── [feature]/               # Feature-specific components
│       ├── feature-list.tsx
│       ├── feature-form.tsx
│       └── feature-card.tsx
│
├── hooks/                        # Custom React Hooks
│   ├── use-[domain]-query.ts    # TanStack Query hooks
│   ├── use-debounce.ts          # Utility hooks
│   └── use-local-storage.ts
│
├── lib/                          # Core Business Logic
│   ├── services/                # Data Access Layer
│   │   ├── [domain].ts          # Domain-specific services
│   │   └── ...
│   │
│   ├── supabase/                # Supabase clients
│   │   ├── client.ts            # Browser client
│   │   ├── server.ts            # Server component client
│   │   ├── middleware.ts        # Auth middleware helper
│   │   └── service-role.ts      # Admin client (서버 전용)
│   │
│   ├── auth/                    # Authentication
│   │   ├── server.ts            # Server auth functions
│   │   ├── client.ts            # Client auth functions
│   │   ├── api-middleware.ts    # API route middleware
│   │   └── permission-utils.tsx # Permission guards
│   │
│   ├── api/                     # External API clients
│   │   ├── openai.ts
│   │   └── [service].ts
│   │
│   ├── actions/                 # Server Actions
│   │   └── [domain]-actions.ts
│   │
│   ├── utils/                   # Utility functions
│   │   ├── format.ts
│   │   ├── validation.ts
│   │   └── date.ts
│   │
│   ├── storage/                 # File storage
│   │   ├── upload.ts
│   │   └── download.ts
│   │
│   ├── constants.ts             # Global constants
│   ├── menu-configs.ts          # Navigation configs
│   └── utils.ts                 # Legacy utils (deprecated)
│
├── types/                        # TypeScript Definitions
│   ├── database.types.ts        # Auto-generated (Supabase CLI)
│   ├── models.ts                # Domain model types
│   ├── enums.ts                 # Enum types and labels
│   ├── auth.types.ts            # Auth-related types
│   ├── menu.types.ts            # Menu/navigation types
│   └── [feature].types.ts       # Feature-specific types
│
├── stores/                       # Client State Management
│   ├── user-store.ts            # User state (Zustand)
│   └── [feature]-store.ts
│
├── providers/                    # React Context Providers
│   ├── query-provider.tsx       # TanStack Query
│   ├── theme-provider.tsx       # Theme
│   └── auth-provider.tsx        # Auth state
│
├── spec/                         # Specifications & Docs
│   ├── PROJECT_ARCHITECTURE.md  # 아키텍처 개요
│   ├── database-schema.md       # DB 스키마 문서
│   ├── FOLDER_STRUCTURE.md      # 폴더 구조 설명
│   └── detailed-features/       # 기능별 상세 명세
│       └── [feature].md
│
├── documentations/               # External API Documentation
│   ├── [api-name]/
│   │   ├── README.md
│   │   └── examples/
│   └── ...
│
├── supabase/                     # Supabase Configuration
│   ├── migrations/              # Database migrations
│   │   └── YYYYMMDDHHMMSS_description.sql
│   ├── functions/               # Edge Functions
│   └── config.toml
│
├── public/                       # Static Assets
│   ├── images/
│   ├── fonts/
│   └── icons/
│
├── scripts/                      # Build/Dev scripts
│   └── db-schema.ts             # DB schema CLI tool
│
├── tests/                        # Test Files (optional)
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── .claude/                      # Claude Code configuration
│   ├── skills/                  # Custom skills
│   └── commands/                # Custom commands
│
├── CLAUDE.md                     # AI agent context
├── .cursorrules                  # Cursor AI rules (alternative)
├── .env.local                    # Environment variables
├── .eslintrc.json               # ESLint config
├── tailwind.config.ts           # Tailwind config
├── tsconfig.json                # TypeScript config
├── next.config.ts               # Next.js config
└── package.json
```

---

## 최소 구조 (새 프로젝트 시작용)

```
project-name/
├── app/
│   ├── api/
│   ├── auth/
│   │   └── login/page.tsx
│   ├── dashboard/
│   │   └── page.tsx
│   ├── layout.tsx
│   ├── page.tsx
│   └── globals.css
│
├── components/
│   ├── ui/                      # shadcn/ui init
│   └── layout/
│       └── app-sidebar.tsx
│
├── hooks/
│   └── .gitkeep
│
├── lib/
│   ├── services/
│   │   └── .gitkeep
│   ├── supabase/
│   │   ├── client.ts
│   │   └── server.ts
│   ├── constants.ts
│   └── utils.ts
│
├── types/
│   ├── database.types.ts
│   └── models.ts
│
├── stores/
│   └── user-store.ts
│
├── providers/
│   └── query-provider.tsx
│
├── spec/
│   └── PROJECT_ARCHITECTURE.md
│
├── supabase/
│   └── migrations/
│
├── CLAUDE.md
└── package.json
```

---

## 역할별 라우트 구조

### Multi-tenant (역할별 대시보드)

```
app/
├── center/              # 가맹점 (Center)
│   ├── dashboard/
│   ├── students/
│   ├── classes/
│   └── layout.tsx
│
├── branch/              # 지사 (Branch)
│   ├── dashboard/
│   ├── centers/
│   ├── reports/
│   └── layout.tsx
│
├── headquarter/         # 본사 (HQ)
│   ├── dashboard/
│   ├── branches/
│   ├── analytics/
│   └── layout.tsx
│
└── admin/               # 시스템 관리자
    ├── users/
    ├── settings/
    └── layout.tsx
```

---

## 파일 네이밍 컨벤션

### Components
```
PascalCase.tsx
- StudentList.tsx
- DataTable.tsx
- AppSidebar.tsx
```

### Hooks
```
use-kebab-case.ts (또는 camelCase)
- use-students-query.ts
- use-debounce.ts
- use-local-storage.ts
```

### Services
```
kebab-case.ts (또는 table name)
- students.ts
- student-service.ts
- attendance-check-service.ts
```

### Types
```
kebab-case.types.ts (또는 domain.ts)
- models.ts
- enums.ts
- auth.types.ts
- menu.types.ts
```

### Constants
```
SCREAMING_SNAKE_CASE for values
camelCase for objects

- CLASS_TIME = { MIN_HOUR: 14, ... }
- PAGINATION = { DEFAULT_PAGE_SIZE: 20, ... }
```

---

## Import Aliases (tsconfig.json)

```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./*"],
      "@/components/*": ["./components/*"],
      "@/lib/*": ["./lib/*"],
      "@/hooks/*": ["./hooks/*"],
      "@/types/*": ["./types/*"],
      "@/stores/*": ["./stores/*"],
      "@/providers/*": ["./providers/*"]
    }
  }
}
```

---

## 기능 추가 시 체크리스트

### 새 도메인/기능 추가

1. **Types** 정의
   - [ ] `types/models.ts`에 Row, Insert, Update 타입 추가
   - [ ] 필요시 `types/[feature].types.ts` 생성

2. **Service** 생성
   - [ ] `lib/services/[domain].ts` 생성
   - [ ] CRUD 함수 구현 (명시적 반환 타입)

3. **Hook** 생성
   - [ ] `hooks/use-[domain]-query.ts` 생성
   - [ ] Query, Mutation hooks 구현

4. **Component** 생성
   - [ ] `components/[feature]/` 폴더 생성
   - [ ] List, Form, Card 등 컴포넌트 구현

5. **Page** 생성
   - [ ] `app/[role]/[feature]/page.tsx` 생성
   - [ ] 필요시 `[id]/page.tsx` 생성

6. **Menu** 추가
   - [ ] `lib/menu-configs.ts`에 메뉴 항목 추가

7. **Spec** 문서화
   - [ ] `spec/detailed-features/[feature].md` 작성

### 외부 API 연동 추가

1. [ ] `lib/api/[service].ts` 클라이언트 생성
2. [ ] `documentations/[service]/` 문서 저장
3. [ ] `.env.local`에 API 키 추가
4. [ ] 필요시 `app/api/external/[service]/route.ts` 프록시 생성
