# Frontend Skills

AI Native Engineer를 위한 프론트엔드 개발 생산성 스킬 모음.

Claude Code에서 반복적인 작업을 자동화하고, 프로젝트 설정 및 문서화를 효율화하는 커스텀 스킬들을 제공합니다.

## Skills

| 스킬 | 설명 |
|------|------|
| **skill-creator** | 새로운 Claude 스킬 생성 가이드 및 도구 |
| **claude-refactoring** | CLAUDE.md 파일 분석, 리팩토링, 최적화 |
| **project-scaffolder** | 프론트엔드 프로젝트 구조 분석 및 아키텍처 문서화 |
| **guide-maker** | Notion에 사용자 가이드 문서 자동 생성 (MCP 필요) |

## Installation

### Claude Code

마켓플레이스에서 설치:
```
/plugin marketplace add <username>/frontend-skills
/plugin install frontend-skills@<username>-frontend-skills
```

또는 직접 설치:
```
/plugin install github:<username>/frontend-skills
```

### Claude.ai

1. Settings > Features로 이동
2. Skills 섹션에서 "Add custom skill" 클릭
3. 각 스킬 폴더를 zip으로 압축하여 업로드

## Usage

설치 후 자연어로 스킬 사용:

```
"프로젝트 구조 잡아줘"           → project-scaffolder
"CLAUDE.md 리팩토링해줘"        → claude-refactoring
"새 스킬 만들어줘"              → skill-creator
"가이드 문서 만들어줘"           → guide-maker
```

## Repository Structure

```
frontend-skills/
├── .claude-plugin/
│   └── marketplace.json    # 플러그인 설정
├── skills/
│   ├── skill-creator/      # 스킬 생성 가이드
│   ├── claude-refactoring/ # CLAUDE.md 리팩토링
│   ├── project-scaffolder/ # 프로젝트 구조화
│   └── guide-maker/        # Notion 가이드 생성
├── docs/                   # 참고 문서
├── CLAUDE.md
└── README.md
```

## Creating Your Own Skills

skill-creator 스킬을 사용하거나 수동으로 생성:

```bash
# 스킬 초기화
python skills/skill-creator/scripts/init_skill.py my-skill --path ./skills

# 스킬 패키징
python skills/skill-creator/scripts/package_skill.py ./skills/my-skill
```

## License

Apache 2.0
