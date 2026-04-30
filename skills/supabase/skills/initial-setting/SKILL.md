---
name: initial-setting
description: >
  Supabase 프로젝트의 DB 스키마 개발환경을 초기 세팅하는 스킬.
  database.types.ts 타입 생성 스크립트, bash 기반 DB 스키마 CLI 조회 도구
  (테이블/뷰/RPC 함수/enum 전부 조회 가능), Supabase client·server에
  Database 제네릭 타입 바인딩, CLAUDE.md에 마이그레이션 규칙과 테이블 목록까지
  한 번에 세팅한다.
  트리거: supabase db 세팅, supabase 초기 설정, db schema 세팅,
  supabase type 설정, 데이터베이스 타입 세팅, supabase 세팅해줘,
  db 스키마 cli 설치, supabase client 타입.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
---

# Supabase DB Setting

Supabase 프로젝트에서 DB 스키마 기반 개발환경을 한 번에 세팅한다.
에이전트가 4000줄+ 타입 파일을 직접 읽지 않고도 스키마를 효과적으로 파악할 수 있게 하는 것이 핵심 목적이다.

## 세팅 항목 요약

| # | 항목 | 파일 |
|---|------|------|
| 1 | DB 스키마 CLI 스크립트 | `scripts/db-schema.sh` |
| 2 | package.json 스크립트 | `db:schema`, `update-type` |
| 3 | Supabase client/server 타입 바인딩 | `client.ts`, `server.ts` |
| 4 | CLAUDE.md DB 섹션 | 마이그레이션 규칙 + 테이블/뷰/함수 목록 + CLI 가이드 |
| 5 | 타입 생성 안내 | `supabase login` → `link` → `update-type` |

---

## Step 0: 프로젝트 분석

세팅 전 아래를 파악한다:

```
분석 대상:
├─ package.json — 패키지 매니저 판별
├─ @supabase/ssr 또는 @supabase/supabase-js 설치 여부
├─ tsconfig.json — path alias (@/ 등)
├─ database.types.ts 기존 위치
├─ supabase client/server 파일 위치
├─ CLAUDE.md 존재 여부 및 기존 DB 섹션
└─ supabase 프로젝트 연결 여부
```

**패키지 매니저 판별:**
- `pnpm-lock.yaml` → pnpm / `yarn.lock` → yarn / `bun.lockb` → bun / 기본 → npm

---

## Step 1: DB 스키마 CLI 스크립트 설치

이 스킬의 `scripts/db-schema.sh`를 `{project-root}/scripts/db-schema.sh`에 복사한다.

순수 bash 스크립트로 tsx/node 설치 없이 바로 실행 가능하다.
`DB_TYPES_PATH` 환경변수로 타입 파일 위치를 오버라이드할 수 있고, 기본적으로 `src/types/`, `types/`, `lib/types/` 등을 자동 탐색한다.

복사 후 `chmod +x scripts/db-schema.sh` 실행 권한을 부여한다.
이미 `scripts/db-schema.ts` (TypeScript 버전)가 있으면 bash 버전으로 교체를 제안한다.

### CLI 지원 명령어

| 명령어 | 설명 |
|--------|------|
| `tables` | 전체 테이블 이름 목록 |
| `table <name>` | 특정 테이블 스키마 (Row/Insert/Update) |
| `views` | 전체 뷰 이름 목록 |
| `view <name>` | 특정 뷰 스키마 (Row) |
| `functions` | 전체 RPC 함수 목록 (시그니처 포함) |
| `function <name>` | 특정 함수 상세 (Args/Returns) |
| `enums` | 전체 enum 이름 목록 |
| `enum <name>` | 특정 enum 값 목록 |
| `search <keyword>` | 테이블/뷰/함수/enum 통합 검색 |

---

## Step 2: package.json 스크립트 추가

```json
{
  "scripts": {
    "db:schema": "bash scripts/db-schema.sh",
    "update-type": "supabase gen types typescript --linked --debug > {TYPES_PATH}"
  }
}
```

- `{TYPES_PATH}`: Step 0에서 파악한 database.types.ts 경로
- 기존에 동일 스크립트가 있으면 덮어쓰지 않고 확인

---

## Step 3: Supabase client/server 타입 바인딩

기존 Supabase client와 server 파일을 찾아 `Database` 제네릭 타입을 바인딩한다.
이미 `<Database>` 제네릭을 사용하고 있으면 스킵한다.

**필요한 import 추가:**
```typescript
import type { Database } from '{TYPES_IMPORT_PATH}';
```

**제네릭 적용:**
- `createBrowserClient<Database>(...)` — client.ts
- `createServerClient<Database>(...)` — server.ts

파일이 없으면 이 스킬의 `scripts/client.ts.template`, `scripts/server.ts.template`을 참고하여 생성한다 (위치는 유저에게 확인).

`@supabase/ssr` 대신 `@supabase/supabase-js`만 사용하는 프로젝트는 import를 맞춰 조정한다.
middleware.ts에도 Supabase client가 있으면 동일하게 타입 바인딩한다.

---

## Step 4: CLAUDE.md에 DB 섹션 추가

CLAUDE.md에 아래 섹션을 추가한다. 이미 DB 관련 섹션이 있으면 병합한다.

이 섹션은 세 가지 역할을 한다:
1. 에이전트에게 마이그레이션 규칙을 알려줌 (MCP로 DDL 실행 방지)
2. 테이블/뷰/함수 목록을 핵심 메모리로 제공 (매번 CLI 안 돌려도 됨)
3. 스키마 CLI 사용법 안내 (상세 스키마가 필요할 때)

### 추가할 내용 템플릿

```markdown
## Database Schema Tools

### 마이그레이션 규칙 (CRITICAL)

- **마이그레이션은 반드시 Supabase CLI로만 생성/적용한다.** MCP `apply_migration`은 절대 사용하지 않는다.
- MCP Supabase 도구는 **데이터 조회/삽입/삭제에만** 사용하며, 유저가 명시적으로 요청한 경우에만 사용한다.
- 스키마 변경(DDL) 워크플로우:

\```bash
npx supabase migration new <name>         # 1. 마이그레이션 파일 생성
# 생성된 .sql 파일에 DDL 작성
npx supabase db push --linked             # 2. 원격 DB에 적용
{PKG_RUN} update-type                     # 3. TypeScript 타입 재생성
\```

### Type 동기화

DB 스키마 변경(마이그레이션 적용) 후 반드시 타입을 재생성해야 한다:

\```bash
{PKG_RUN} update-type    # Supabase → {TYPES_PATH} 재생성
\```

### 테이블 목록 ({N}개)

| 테이블 | 목적 |
|--------|------|
| `{table_name}` | {한 줄 설명} |
| ... | ... |

### 뷰 목록

| 뷰 | 목적 |
|----|------|
| `{view_name}` | {한 줄 설명} |

### RPC 함수

| 함수 | Args | Returns | 목적 |
|------|------|---------|------|
| `{function_name}` | `{args}` | `{returns}` | {한 줄 설명} |

### Schema CLI (CRITICAL)

**`{TYPES_PATH}`를 직접 읽지 말 것.** 대신 CLI로 필요한 부분만 조회:

\```bash
{PKG_RUN} db:schema tables                 # 전체 테이블 목록
{PKG_RUN} db:schema table {example_table}  # 특정 테이블 스키마 (Row/Insert/Update)
{PKG_RUN} db:schema views                  # 전체 뷰 목록
{PKG_RUN} db:schema view {example_view}    # 특정 뷰 스키마
{PKG_RUN} db:schema functions              # 전체 RPC 함수 목록 (시그니처 포함)
{PKG_RUN} db:schema function {example_fn}  # 특정 함수 상세 (Args/Returns)
{PKG_RUN} db:schema enums                  # 전체 enum 목록
{PKG_RUN} db:schema enum {example_enum}    # 특정 enum 값
{PKG_RUN} db:schema search {keyword}       # 테이블/뷰/함수/enum 통합 검색
\```
```

### 테이블/뷰/함수 목록 작성 방법

CLI를 실행하여 목록을 수집한 뒤, 유저에게 각 항목의 목적을 확인하거나 테이블 컬럼명/컨텍스트로 추론한다.
이 목록은 에이전트의 핵심 메모리 역할을 하므로 간결하되 정확해야 한다.

**동적 값:**
- `{PKG_RUN}`: `npm run` / `pnpm run` / `yarn` / `bun run`
- `{TYPES_PATH}`: 실제 database.types.ts 경로
- `{N}`: 테이블 개수
- 테이블/뷰/함수 예시는 실제 프로젝트 것으로 교체

---

## Step 5: 타입 생성 안내

Supabase 타입 생성은 `supabase login`이 필요하므로 직접 실행하지 않는다.
세팅 완료 후 아래를 출력한다:

```
✅ Supabase DB 세팅 완료!

다음 단계를 진행해 주세요:

1. Supabase CLI 로그인 (아직 안 했다면):
   npx supabase login

2. 프로젝트 연결 (아직 안 했다면):
   npx supabase link --project-ref <your-project-ref>

3. 타입 생성:
   {PKG_RUN} update-type

4. 스키마 CLI 테스트:
   {PKG_RUN} db:schema tables

세팅된 항목:
  ✓ scripts/db-schema.sh — DB 스키마 CLI (bash, tables/views/functions/enums)
  ✓ package.json — db:schema, update-type 스크립트
  ✓ CLAUDE.md — 마이그레이션 규칙 + 테이블/뷰/함수 목록 + CLI 가이드
  ✓ {client_path} — Database 제네릭 타입
  ✓ {server_path} — Database 제네릭 타입
```

---

## Edge Cases

- **database.types.ts가 이미 존재**: 덮어쓰지 않음. `update-type` 스크립트만 추가
- **client.ts/server.ts가 없는 프로젝트**: 유저에게 생성 위치 확인 후 템플릿에서 생성
- **@supabase/supabase-js만 사용**: `createClient` import를 맞춰 조정
- **middleware.ts에도 Supabase client 존재**: 동일하게 타입 바인딩
- **모노레포**: 앱 디렉토리 기준으로 경로 설정
- **Views/Functions 없는 프로젝트**: CLAUDE.md에서 해당 섹션 생략
