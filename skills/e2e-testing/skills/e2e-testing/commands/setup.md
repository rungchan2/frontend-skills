# E2E 테스트 환경 세팅

`.e2e/` 폴더 구조를 scaffold로 생성합니다.

## 실행

1. `.e2e/` 디렉토리 생성
2. `.e2e/scenarios/` 디렉토리 생성
3. `.e2e/results/` 디렉토리 생성 (`.gitkeep` 포함)
4. `.e2e/init.md` 템플릿 생성 (환경 설정만)
5. `.e2e/credentials.md` 템플릿 생성 (계정 정보)
6. `.gitignore`에 `.e2e/credentials.md`와 `.e2e/results/` 추가 확인. 누락 시 추가.
7. 유저에게 `.e2e/credentials.md`를 직접 채우라고 안내

템플릿 내용은 e2e-testing 스킬의 `references/templates.md`를 참조하세요.

$ARGUMENTS
