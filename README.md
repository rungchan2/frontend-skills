# Frontend Skills

AI Native Engineer를 위한 프론트엔드 개발 생산성 [Claude Code 플러그인](https://docs.claude.com/en/docs/claude-code/plugins) 마켓플레이스.

목적별로 묶인 7개 플러그인 / 11개 스킬을 골라서 설치할 수 있다.

## Plugins

| 플러그인 | 포함 스킬 | 목적 |
|---------|---------|------|
| `supabase` | `initial-setting` | Supabase DB 스키마 개발환경 초기 세팅 (타입 생성, 스키마 CLI, client/server 바인딩) |
| `project-packages` | `setup-all`, `tailwind-cn`, `dayjs-kst` | 프로젝트 초기 세팅 시 표준 패키지 + 중앙 setup 일괄 적용 |
| `spec-generator` | `prd`, `tech-stack`, `design-system`, `mvp-roadmap` | 프로젝트 스펙 문서 생성 |
| `claudemd` | `builder`, `refactoring` | `CLAUDE.md` 메모리 파일 작성/리팩토링 |
| `guide-maker` | `guide-maker` | Notion에 사용자 가이드 자동 생성 (Notion remote MCP 자동 포함) |
| `project-scaffolder` | `project-scaffolder` | 프론트엔드 프로젝트 구조 분석 및 아키텍처 문서화 |
| `web-to-markdown` | `web-to-markdown` | 웹 페이지를 깨끗한 Markdown으로 저장 |
| `e2e-testing` | `e2e-testing` | 자연어 E2E 테스트 (agent-browser CLI 기반) |

## Installation

### 1. 마켓플레이스 등록

Claude Code에서 한 번만:

```
/plugin marketplace add rungchan2/frontend-skills
```

### 2. 원하는 플러그인만 설치

```
/plugin install supabase@frontend-skills
/plugin install project-packages@frontend-skills
/plugin install spec-generator@frontend-skills
/plugin install claudemd@frontend-skills
/plugin install guide-maker@frontend-skills
/plugin install project-scaffolder@frontend-skills
/plugin install web-to-markdown@frontend-skills
/plugin install e2e-testing@frontend-skills
```

전부 설치하지 않아도 된다 — 필요한 것만 골라서.

### 3. 호출

설치 후 슬래시 메뉴에 자동 등장. 자연어로도 트리거된다.

```
/supabase:initial-setting
/project-packages:setup-all
/spec-generator:prd
/claudemd:builder
```

또는 자연어:

```
"supabase db 세팅해줘"           → /supabase:initial-setting
"PRD 만들어줘"                   → /spec-generator:prd
"CLAUDE.md 리팩토링해줘"          → /claudemd:refactoring
"노션에 사용자 가이드 만들어줘"     → /guide-maker:guide-maker
"프로젝트 초기 세팅해줘"           → /project-packages:setup-all
```

## Notes

- **`guide-maker`**: Notion 공식 remote MCP를 자동 포함한다. 첫 사용 시 Claude Code의 `/mcp` 메뉴에서 OAuth 로그인 1회만 하면 환경변수 설정 없이 동작한다.
- **`supabase:initial-setting`**: Supabase CLI(`npx supabase`)와 프로젝트 환경변수가 필요하다. 자세한 사항은 스킬 실행 시 안내.

## Repository Structure

```
frontend-skills/
├── .claude-plugin/
│   └── marketplace.json     # 마켓플레이스 레지스트리
├── skills/                  # 각 디렉토리 = 하나의 플러그인
│   ├── supabase/
│   ├── project-packages/
│   ├── spec-generator/
│   ├── claudemd/
│   ├── guide-maker/
│   ├── project-scaffolder/
│   ├── web-to-markdown/
│   └── e2e-testing/
├── CLAUDE.md
└── README.md
```

각 플러그인 내부 구조:

```
plugin-name/
├── .claude-plugin/plugin.json   # 플러그인 매니페스트
└── skills/
    └── skill-name/
        ├── SKILL.md             # YAML frontmatter + 지침
        ├── scripts/             # (선택) 실행 코드
        ├── references/          # (선택) 참조 문서
        └── assets/              # (선택) 출력용 템플릿
```

## License

Apache 2.0
