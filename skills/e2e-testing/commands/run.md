# E2E 테스트 실행

자연어 E2E 테스트를 실행합니다.

## 사용법
- `/e2e-testing:run` - 전체 시나리오 테스트
- `/e2e-testing:run auth` - 파일명에 auth가 포함된 시나리오
- `/e2e-testing:run 1` - 1번 시나리오만
- `/e2e-testing:run 1 3` - 1번, 3번 시나리오
- `/e2e-testing:run 1-3` - 1~3번 시나리오

## 실행

1. `.e2e/init.md`에서 환경 설정(Base URL, 환경)을 읽으세요.
2. `.e2e/credentials.md`에서 테스트 계정 정보를 읽으세요. 없으면 유저에게 생성하라고 안내하세요.
3. `.e2e/scenarios/` 디렉토리에서 시나리오 파일 목록을 확인하세요.
4. 인자에 맞는 시나리오를 선택하세요. 인자가 없으면 전체 시나리오를 실행하세요.
5. 각 시나리오마다 `e2e-tester` 서브 에이전트를 **병렬로** Task tool로 실행하세요.
   - 프롬프트에 init.md 내용 + credentials.md 내용 + 시나리오 내용을 포함하세요.
6. 모든 서브 에이전트 완료 후 결과를 취합하여 `.e2e/results/{YYYY-MM-DD_HHmm}.md` 단일 파일로 저장하세요.
7. 유저에게 전체 결과를 테이블 형식으로 보고하세요.

$ARGUMENTS
