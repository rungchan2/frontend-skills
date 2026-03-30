---
name: e2e-testing
description: >
  agent-browser 기반 자연어 E2E 테스트 프레임워크.
  `.e2e/` 폴더에 마크다운 시나리오를 작성하면 agent-browser CLI로 브라우저 테스트를 자동 실행한다.
  auto/human 스텝 타입으로 결제 등 사람이 필요한 단계도 처리.
  트리거: E2E 세팅해줘, E2E 시나리오 만들어줘, 테스트 케이스 작성해줘, E2E init.
  /e2e-testing:run 으로 테스트 실행, /e2e-testing:setup 으로 scaffold 생성.
  agent-browser CLI가 설치되어 있어야 함 (npm i -g agent-browser).
---

# E2E Testing Framework

마크다운 시나리오 기반 자연어 E2E 테스트. `agent-browser` CLI + 서브 에이전트 병렬 실행.

## 요구사항

- `agent-browser` CLI 설치 (`npm i -g agent-browser`)

## 폴더 구조

```
.e2e/
├── init.md              # 환경 설정 (Base URL, 로그인 절차) - git 추적 O
├── credentials.md       # 테스트 계정 정보 - git 추적 X (gitignore)
├── results/             # 테스트 결과 - git 추적 X (gitignore)
│   └── {YYYY-MM-DD_HHmm}.md
└── scenarios/
    ├── 1-auth.md
    ├── 2-students.md
    └── ...
```

## 시나리오 형식

파일명: `{번호}-{기능명}.md`

시나리오 파일 형식 상세: `references/scenario-format.md` 참조.

## 테스트 스텝 타입

### `type: auto`
에이전트가 agent-browser로 자동 수행. 대부분의 테스트.

### `type: human`
에이전트가 수행 불가한 단계 (결제, CAPTCHA, OTP, 외부 콜백 등).
반드시 **유저 행동** 필드를 포함. 에이전트는 `HUMAN_PENDING` 기록 후 다음 auto 스텝 계속 진행.

## Setup 워크플로우

"E2E 세팅해줘" 또는 `/e2e-testing:setup` 시:

1. `.e2e/`, `.e2e/scenarios/`, `.e2e/results/` 디렉토리 생성
2. `.e2e/init.md` 템플릿 생성 (환경 설정)
3. `.e2e/credentials.md` 템플릿 생성 (계정 정보)
4. `.gitignore`에 `.e2e/credentials.md`, `.e2e/results/` 추가 확인
5. 유저에게 `credentials.md` 직접 채우라고 안내

init.md / credentials.md 템플릿: `references/templates.md` 참조.

## 시나리오 작성 워크플로우

"시나리오 만들어줘" 또는 "테스트 케이스 작성" 시:

1. 기존 시나리오 파일 목록 확인 → 다음 번호 결정
2. 요청한 기능의 실제 코드를 읽어서 UI 구조 파악
3. 시나리오 형식에 맞춰 파일 작성

작성 규칙:
- 1개 파일 = 1개 기능 영역 = 1개 에이전트가 실행
- 테스트 번호: `{시나리오번호}.{테스트번호}` (예: 2.1)
- 모든 스텝에 `type` 필드 필수
- `human` 스텝은 시나리오 후반부에 배치

## Run 워크플로우

`/e2e-testing:run` 시:

1. `.e2e/init.md` + `.e2e/credentials.md` 읽기
2. 시나리오 선택 (인자 기반)
3. 각 시나리오마다 `e2e-tester` 서브 에이전트 **병렬** 실행
4. 결과 취합 → `.e2e/results/{YYYY-MM-DD_HHmm}.md` 단일 파일 저장
