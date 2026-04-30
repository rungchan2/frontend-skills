# CLAUDE.md

## Project Overview

Claude Code Plugin 레포지토리. AI 에이전트(Claude Code)의 기능을 확장하는 커스텀 스킬을 개발하고 마켓플레이스로 배포한다.

## 레포 구조

이 레포는 **마켓플레이스** — 각 플러그인이 목적별로 그룹화되어 있고, 그 안에 여러 스킬을 담는다. 사용자는 원하는 플러그인만 골라 설치한다.

```
frontend-skills/
├── .claude-plugin/
│   └── marketplace.json          # 마켓플레이스 레지스트리
├── skills/                       # 각 디렉토리가 하나의 플러그인
│   ├── supabase/                 # 그룹 플러그인 예시:
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json       #   플러그인 매니페스트
│   │   └── skills/
│   │       └── initial-setting/  #   플러그인 안의 스킬
│   │           ├── SKILL.md
│   │           └── scripts/
│   ├── project-packages/         # tailwind-cn, dayjs-kst, setup-all (확장 예정)
│   ├── spec-generator/           # prd, tech-stack, design-system, mvp-roadmap
│   ├── claudemd/                 # builder, refactoring
│   ├── guide-maker/              # 단독 (Notion MCP 포함)
│   ├── project-scaffolder/       # 단독
│   ├── web-to-markdown/          # 단독
│   └── e2e-testing/              # 단독
└── docs/                         # 참고 문서
```

### 설치 방식

```bash
# 마켓플레이스 등록
/plugin marketplace add heechan/frontend-skills

# 원하는 플러그인 골라 설치
/plugin install supabase@frontend-skills
/plugin install spec-generator@frontend-skills
/plugin install claudemd@frontend-skills
```

## Plugin / Skill 구조

각 플러그인은 `plugin.json` 매니페스트와 `skills/` 하위 디렉토리를 가진다:

```
plugin-name/                      # 플러그인 루트
├── .claude-plugin/
│   └── plugin.json               # 플러그인 매니페스트 (필수)
└── skills/
    └── skill-name/               # 스킬 디렉토리
        ├── SKILL.md              # YAML frontmatter + Markdown 지침 (필수)
        ├── scripts/              # 실행 가능 코드 (Python/Bash)
        ├── references/           # 참조 문서
        └── assets/               # 출력용 파일
```

호출: `/{plugin-name}:{skill-name}` (예: `/supabase:initial-setting`, `/spec-generator:prd`)

### SKILL.md Frontmatter

```yaml
---
name: skill-name                    # 소문자, 하이픈만, 64자 이하 (선택, 없으면 디렉토리명)
description: >                      # 권장. 트리거 판단 기준. 1024자 이하
  스킬 설명 및 트리거 조건.
disable-model-invocation: false     # true면 사용자만 호출 가능 (선택)
allowed-tools: Read, Grep, Glob     # 스킬 활성 시 허용 도구 (선택)
context: fork                       # fork면 서브에이전트로 실행 (선택)
agent: Explore                      # context: fork 시 에이전트 타입 (선택)
---
```

### Progressive Disclosure 3단계

| 단계 | 내용 | 로드 시점 | 토큰 |
|------|------|-----------|------|
| 1. Metadata | name + description | 항상 | ~100 |
| 2. SKILL.md body | 지침, 워크플로우 | 스킬 트리거 시 | <5k |
| 3. Bundled resources | scripts, references, assets | 필요 시 | 무제한 |

## 현재 플러그인 / 스킬 목록

| 플러그인 | 포함 스킬 | 설명 |
|---------|----------|------|
| `supabase` | `initial-setting` | Supabase DB 스키마 개발환경 초기 세팅 |
| `project-packages` | `setup-all` | 새 프로젝트에 표준 중앙 setup 일괄 적용 (마스터) |
| | `tailwind-cn` | shadcn 기반 cn() 유틸 + 통화 포맷 (lib/utils.ts) |
| | `dayjs-kst` | dayjs 한국 타임존/locale 중앙 setup (lib/dayjs.ts) |
| `spec-generator` | `prd` | PRD 작성 |
| | `tech-stack` | Tech Stack 문서 작성 |
| | `design-system` | Design System 문서 작성 |
| | `mvp-roadmap` | MVP Roadmap 문서 작성 |
| `claudemd` | `builder` | CLAUDE.md 블록 기반 생성/검사/정리 |
| | `refactoring` | CLAUDE.md 리팩토링 및 정리 |
| `guide-maker` | (단독) | Notion 사용자 가이드 생성 (Notion MCP 자동 포함) |
| `project-scaffolder` | (단독) | 프론트엔드 프로젝트 구조 분석/문서화 |
| `web-to-markdown` | (단독) | 웹 페이지를 Markdown으로 저장 |
| `e2e-testing` | (단독) | 자연어 E2E 테스트 (agent-browser CLI 기반) |

## Development Rules

- SKILL.md body는 500줄 미만 유지
- 상세 정보는 별도 파일로 분리 (Progressive Disclosure)
- description에 트리거 조건 포함 (body가 아닌 description이 트리거 판단 기준)
- README.md, CHANGELOG.md 등 부가 문서 불필요
- 컨텍스트 윈도우는 공공재 — Claude가 이미 아는 정보는 생략
