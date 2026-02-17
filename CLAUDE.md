# CLAUDE.md

## Project Overview

Claude Code Plugin 레포지토리. AI 에이전트(Claude Code)의 기능을 확장하는 커스텀 스킬을 개발하고 마켓플레이스로 배포한다.

## 레포 구조

이 레포는 **마켓플레이스** — 각 스킬이 개별 플러그인으로 등록되어 사용자가 원하는 것만 골라 설치한다.

```
frontend-skills/
├── .claude-plugin/
│   └── marketplace.json      # 마켓플레이스 레지스트리 (각 스킬 = 개별 플러그인)
├── skills/                   # 각 스킬 디렉토리가 하나의 플러그인
│   ├── skill-creator/
│   ├── claude-refactoring/
│   ├── claudemd-builder/
│   ├── project-scaffolder/
│   ├── guide-maker/
│   ├── prd-generator/
│   ├── tech-stack-generator/
│   ├── design-system-generator/
│   ├── mvp-roadmap-generator/
│   └── web-to-markdown/
└── docs/                     # 참고 문서
```

### 설치 방식

```bash
# 마켓플레이스 등록
/plugin marketplace add heechan/frontend-skills

# 원하는 스킬만 골라 설치
/plugin install prd-generator@heechan-frontend-skills
/plugin install claudemd-builder@heechan-frontend-skills
```

## Skill 구조

각 스킬은 `SKILL.md`가 필수인 디렉토리:

```
skill-name/
├── SKILL.md              # YAML frontmatter + Markdown 지침 (필수)
├── scripts/              # 실행 가능 코드 (Python/Bash)
├── references/           # 참조 문서 (필요 시에만 컨텍스트에 로드)
└── assets/               # 출력에 사용되는 파일 (컨텍스트에 로드하지 않음)
```

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

## 현재 스킬 목록

| 스킬 | 설명 |
|------|------|
| `skill-creator` | 스킬 생성 가이드. 새 스킬 만들거나 기존 스킬 수정 시 |
| `claude-refactoring` | CLAUDE.md 리팩토링 및 정리 |
| `claudemd-builder` | CLAUDE.md 블록 기반 생성/검사/정리 |
| `project-scaffolder` | 프론트엔드 프로젝트 구조 분석/문서화 |
| `guide-maker` | Notion 사용자 가이드 생성 (MCP 필요) |
| `prd-generator` | PRD 작성 |
| `tech-stack-generator` | Tech Stack 문서 작성 |
| `design-system-generator` | Design System 문서 작성 |
| `mvp-roadmap-generator` | MVP Roadmap 문서 작성 |
| `web-to-markdown` | 웹 페이지를 Markdown으로 저장 |

## Key Commands

```bash
# 새 스킬 초기화
python skills/skill-creator/scripts/init_skill.py <name> --path ./skills

# 스킬 패키징
python skills/skill-creator/scripts/package_skill.py <skill-folder>

# 스킬 검증
python skills/skill-creator/scripts/quick_validate.py <skill-folder>
```

## Development Rules

- SKILL.md body는 500줄 미만 유지
- 상세 정보는 별도 파일로 분리 (Progressive Disclosure)
- description에 트리거 조건 포함 (body가 아닌 description이 트리거 판단 기준)
- README.md, CHANGELOG.md 등 부가 문서 불필요
- 컨텍스트 윈도우는 공공재 — Claude가 이미 아는 정보는 생략
