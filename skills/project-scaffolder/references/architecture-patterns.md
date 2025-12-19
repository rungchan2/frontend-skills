# Architecture Patterns Reference

프로젝트 아키텍처 패턴 상세 가이드.

## 목차

1. [3-Layer Architecture](#3-layer-architecture)
2. [Type System](#type-system)
3. [Constants Pattern](#constants-pattern)
4. [Menu Configuration](#menu-configuration)
5. [External API Integration](#external-api-integration)
6. [Authentication Pattern](#authentication-pattern)
7. [File Storage Pattern](#file-storage-pattern)

---

## 3-Layer Architecture

### 계층 간 의존성 규칙

```
Component → Hook → Service → Database
    ↓         ↓        ↓
   UI      Query    Pure Fn
  Only     Mgmt     + DB Client
```

**허용되는 import 방향**:
- Component → Hook ✅
- Component → Service ❌
- Hook → Service ✅
- Hook → DB Client ❌
- Service → DB Client ✅

### Service Layer 패턴

```typescript
// lib/services/[domain].ts

// 1. Imports
import { createClient } from '@/lib/supabase/client'
import type { DomainRow, DomainInsert, DomainUpdate } from '@/types/models'

// 2. Read Operations
export async function getAll(filter?: Filter): Promise<DomainRow[]> {
  const supabase = createClient()
  const { data, error } = await supabase
    .from('table_name')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) throw error
  return data
}

export async function getById(id: number): Promise<DomainRow | null> {
  const supabase = createClient()
  const { data, error } = await supabase
    .from('table_name')
    .select('*')
    .eq('id', id)
    .single()

  if (error && error.code !== 'PGRST116') throw error
  return data
}

// 3. Write Operations
export async function create(input: DomainInsert): Promise<DomainRow> {
  const supabase = createClient()
  const { data, error } = await supabase
    .from('table_name')
    .insert(input)
    .select()
    .single()

  if (error) throw error
  return data
}

export async function update(id: number, input: DomainUpdate): Promise<DomainRow> {
  const supabase = createClient()
  const { data, error } = await supabase
    .from('table_name')
    .update(input)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data
}

export async function remove(id: number): Promise<void> {
  const supabase = createClient()
  const { error } = await supabase
    .from('table_name')
    .delete()
    .eq('id', id)

  if (error) throw error
}
```

### Hook Layer 패턴

```typescript
// hooks/use-[domain]-query.ts

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import * as domainService from '@/lib/services/[domain]'
import type { DomainRow, DomainInsert } from '@/types/models'

// Query Keys - 일관된 패턴
export const domainKeys = {
  all: ['domain'] as const,
  lists: () => [...domainKeys.all, 'list'] as const,
  list: (filters: object) => [...domainKeys.lists(), filters] as const,
  details: () => [...domainKeys.all, 'detail'] as const,
  detail: (id: number) => [...domainKeys.details(), id] as const,
}

// List Query
export function useDomainListQuery(filters?: object) {
  return useQuery({
    queryKey: domainKeys.list(filters ?? {}),
    queryFn: () => domainService.getAll(filters),
  })
}

// Detail Query
export function useDomainDetailQuery(id: number) {
  return useQuery({
    queryKey: domainKeys.detail(id),
    queryFn: () => domainService.getById(id),
    enabled: !!id,
  })
}

// Create Mutation
export function useCreateDomainMutation() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (input: DomainInsert) => domainService.create(input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: domainKeys.lists() })
    },
  })
}

// Update Mutation
export function useUpdateDomainMutation() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: DomainUpdate }) =>
      domainService.update(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: domainKeys.detail(id) })
      queryClient.invalidateQueries({ queryKey: domainKeys.lists() })
    },
  })
}

// Delete Mutation
export function useDeleteDomainMutation() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (id: number) => domainService.remove(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: domainKeys.lists() })
    },
  })
}
```

---

## Type System

### 타입 파일 구조

```
types/
├── database.types.ts   # Auto-generated (Supabase CLI)
├── models.ts           # Domain model types (Row, Insert, Update)
├── enums.ts            # Database enums
└── [feature].types.ts  # Feature-specific types
```

### models.ts 패턴

```typescript
// types/models.ts
import type { Database } from './database.types'

// Table Row Types
export type UserRow = Database['public']['Tables']['users']['Row']
export type StudentRow = Database['public']['Tables']['students']['Row']
export type ClassRow = Database['public']['Tables']['classes']['Row']

// Insert Types
export type UserInsert = Database['public']['Tables']['users']['Insert']
export type StudentInsert = Database['public']['Tables']['students']['Insert']

// Update Types
export type UserUpdate = Database['public']['Tables']['users']['Update']
export type StudentUpdate = Database['public']['Tables']['students']['Update']

// Custom Types (with joins)
export type StudentWithClass = StudentRow & {
  classes: ClassRow | null
}
```

### enums.ts 패턴

```typescript
// types/enums.ts
import type { Database } from './database.types'

export type UserRole = Database['public']['Enums']['user_role']
export type AttendanceStatus = Database['public']['Enums']['attendance_status']
export type PaymentStatus = Database['public']['Enums']['payment_status']

// Enum values for UI
export const USER_ROLE_LABELS: Record<UserRole, string> = {
  headquarter: '본사',
  branch: '지사',
  center: '가맹점',
  viewer: '뷰어',
}

export const ATTENDANCE_STATUS_LABELS: Record<AttendanceStatus, string> = {
  present: '출석',
  absent: '결석',
  late: '지각',
  // ...
}
```

---

## Constants Pattern

### 상수 정의 원칙

1. **그룹화**: 관련 상수는 객체로 묶기
2. **as const**: 타입 추론을 위해 항상 사용
3. **JSDoc**: 각 상수에 설명 추가
4. **유틸 함수**: 상수 기반 헬퍼 함수 함께 정의

```typescript
// lib/constants.ts

/**
 * 프로젝트 전역 상수
 * Single Source of Truth
 */

// =====================================================================
// 비즈니스 로직 상수
// =====================================================================

/**
 * 수업 시간 관련 상수
 */
export const CLASS_TIME = {
  /** 수업 시작 가능 최소 시간 (시) */
  MIN_HOUR: 14,
  /** 수업 종료 가능 최대 시간 (시) */
  MAX_HOUR: 21,
  /** 수업 시작 가능 최소 시간 (HH:mm) */
  MIN_TIME: '14:00',
  /** 수업 종료 가능 최대 시간 (HH:mm) */
  MAX_TIME: '21:00',
} as const

/**
 * 기본 수업 시간 설정
 */
export const DEFAULT_CLASS_DURATION = {
  /** 기본 수업 시간 (분) */
  MINUTES: 90,
  /** Zone당 기본 시간 (분) */
  ZONE_MINUTES: 30,
} as const

// =====================================================================
// UI 관련 상수
// =====================================================================

/**
 * 페이지네이션 기본값
 */
export const PAGINATION = {
  DEFAULT_PAGE_SIZE: 20,
  PAGE_SIZE_OPTIONS: [10, 20, 50, 100],
} as const

/**
 * 토스트 메시지 지속 시간 (ms)
 */
export const TOAST_DURATION = {
  SHORT: 2000,
  DEFAULT: 4000,
  LONG: 6000,
} as const

/**
 * 디바운스/스로틀 지연 시간 (ms)
 */
export const DEBOUNCE_DELAY = {
  SEARCH: 300,
  AUTOSAVE: 1000,
  RESIZE: 100,
} as const

// =====================================================================
// 헬퍼 함수
// =====================================================================

/**
 * 시간이 허용 범위 내인지 확인
 */
export function isTimeInAllowedRange(time: string): boolean {
  if (!time) return false
  const [hour] = time.split(':').map(Number)
  return hour >= CLASS_TIME.MIN_HOUR && hour < CLASS_TIME.MAX_HOUR
}
```

---

## Menu Configuration

### 메뉴 구조 정의

```typescript
// types/menu.types.ts
import { LucideIcon } from 'lucide-react'

export interface MenuItem {
  title: string
  url: string
  icon?: LucideIcon
  isActive?: boolean
  requireCenterAdmin?: boolean
  requireBranchAdmin?: boolean
  items?: MenuItem[]  // Submenu
}

export interface MenuData {
  navMain: MenuItem[]
}
```

### 역할별 메뉴 설정

```typescript
// lib/menu-configs.ts
import { Home, Users, Settings } from 'lucide-react'
import type { MenuData } from '@/types/menu.types'

export function getCenterMenuData(): MenuData {
  return {
    navMain: [
      {
        title: '대시보드',
        url: '/center/dashboard',
        icon: Home,
        isActive: true,
      },
      {
        title: '관리자',
        url: '#',
        icon: Settings,
        requireCenterAdmin: true,
        items: [
          { title: '관리자 대시보드', url: '/center/admin/dashboard' },
          { title: '강사 관리', url: '/center/admin/instructors' },
        ],
      },
      {
        title: '학생 관리',
        url: '/center/students',
        icon: Users,
      },
    ],
  }
}

export function getBranchMenuData(): MenuData {
  // 지사용 메뉴
}

export function getHeadquarterMenuData(): MenuData {
  // 본사용 메뉴
}
```

---

## External API Integration

### 외부 API 클라이언트 구조

```
lib/api/
├── index.ts           # Export all clients
├── openai.ts          # OpenAI API client
├── alimtalk.ts        # Kakao Alimtalk client
└── onedrive.ts        # Microsoft Graph client
```

### API 클라이언트 패턴

```typescript
// lib/api/openai.ts
import OpenAI from 'openai'

// Singleton client
let client: OpenAI | null = null

function getClient(): OpenAI {
  if (!client) {
    client = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    })
  }
  return client
}

export async function generateSummary(text: string): Promise<string> {
  const openai = getClient()
  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [{ role: 'user', content: text }],
  })
  return response.choices[0].message.content ?? ''
}
```

### 외부 문서 저장

```
documentations/
├── [api-name]/
│   ├── README.md          # 사용법 요약
│   ├── api-reference.md   # API 레퍼런스
│   └── examples/          # 예제 코드
```

---

## Authentication Pattern

### Supabase Auth 구조

```
lib/auth/
├── README.md           # Auth 시스템 문서
├── server.ts           # Server-side auth
├── client.ts           # Client-side auth
├── middleware.ts       # Auth middleware
├── api-middleware.ts   # API route auth
└── permission-utils.tsx # Permission guards
```

### 인증 체크 패턴

```typescript
// Server Component
import { getServerAuth } from '@/lib/auth/server'

export default async function Page() {
  const auth = await getServerAuth()
  if (!auth) redirect('/auth/login')
  // ...
}

// API Route
import { withCenter } from '@/lib/auth/api-middleware'

export const GET = withCenter(async (request, auth) => {
  const centerId = auth.centerId!
  // ...
})

// Client Component
import { useUserStore } from '@/stores/user-store'

export function Component() {
  const user = useUserStore(state => state.user)
  // ...
}
```

---

## File Storage Pattern

### 스토리지 구조

```
lib/storage/
├── README.md           # Storage 시스템 문서
├── index.ts            # Main exports
├── upload.ts           # Upload functions
├── download.ts         # Download functions
└── utils.ts            # Utility functions
```

### 업로드 패턴

```typescript
// lib/storage/upload.ts
import { createClient } from '@/lib/supabase/client'

export interface UploadOptions {
  userId: string
  userRole: 'headquarter' | 'branch' | 'center'
  centerId?: number
  branchId?: string
  category: FolderCategory
}

export async function uploadFile(
  file: File,
  options: UploadOptions
): Promise<UploadResult> {
  const supabase = createClient()
  const bucket = getBucketForRole(options.userRole)
  const path = buildPath(options, file.name)

  const { data, error } = await supabase.storage
    .from(bucket)
    .upload(path, file)

  if (error) throw error

  // Save to files table
  await saveFileRecord(data, options)

  return { path, bucket, url: getPublicUrl(bucket, path) }
}
```
