# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Code Skills 레포지토리. AI 에이전트(Claude Code)의 기능을 확장하는 커스텀 스킬을 개발하고 관리한다. Claude Code 마켓플레이스 배포용.

## Repository Structure

```
frontend-skills/
├── .claude-plugin/
│   └── marketplace.json  # 플러그인 마켓플레이스 설정
├── skills/               # 스킬 모음
│   ├── skill-creator/    # 스킬 생성 가이드 및 도구
│   │   └── scripts/      # init_skill.py, package_skill.py
│   ├── claude-refactoring/  # CLAUDE.md 리팩토링
│   ├── project-scaffolder/  # 프로젝트 구조 분석/문서화
│   └── guide-maker/      # Notion 가이드 생성 (MCP 필요)
└── docs/                 # Skills 시스템 참고 문서
```

## Skill Structure

모든 스킬은 SKILL.md 파일 필수:

```
skill-name/
├── SKILL.md              # YAML frontmatter + Markdown 지침 (필수)
├── scripts/              # 실행 가능한 스크립트 (선택)
├── references/           # 참조 문서 (선택)
└── assets/               # 템플릿, 이미지 등 (선택)
```

### SKILL.md Frontmatter

```yaml
---
name: skill-name          # 소문자, 하이픈만, 64자 이하
description: 스킬 설명 및 트리거 조건 (1024자 이하)
---
```

## Key Commands

```bash
# 새 스킬 초기화
python skills/skill-creator/scripts/init_skill.py <name> --path ./skills

# 스킬 패키징
python skills/skill-creator/scripts/package_skill.py <skill-folder>

# 스킬 검증
python skills/skill-creator/scripts/quick_validate.py <skill-folder>
```

## Marketplace Configuration

`.claude-plugin/marketplace.json` 구조:
```json
{
  "name": "heechan-frontend-skills",
  "plugins": [{
    "name": "frontend-skills",
    "skills": ["./skills/skill-creator", ...]
  }]
}
```

## Development Rules

- SKILL.md body는 500줄 미만 유지
- 상세 정보는 `references/` 로 분리
- Description은 3인칭, 트리거 조건 포함
- README.md, CHANGELOG.md 등 부가 문서 불필요
