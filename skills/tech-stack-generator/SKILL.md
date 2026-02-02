---
name: tech-stack-generator
description: Tech Stack 문서 작성 가이드. 프로젝트에 사용되는 기술, 패키지, 외부 서비스를 정의한다. 사용자가 "기술 스택 정리해줘", "tech stack 문서 만들어줘", "기술 선택 문서화해줘", "사용 기술 정리해줘" 등을 요청할 때 사용한다.
---

# Tech Stack Generator

프로젝트의 기술 스택과 의존성을 정의하는 문서 생성 가이드.

## 워크플로우

```
1. 인터뷰 → 2. 패키지 버전 조회 → 3. 문서 생성 → 4. 검토/보완
```

## 패키지 버전 조회

**중요**: 패키지 버전 명시 시 반드시 최신 버전을 조회하여 기입한다.

### 스크립트 사용

```bash
# 특정 패키지 조회
python scripts/get_npm_versions.py react next typescript axios

# 카테고리별 조회
python scripts/get_npm_versions.py --category frontend
python scripts/get_npm_versions.py --category styling
python scripts/get_npm_versions.py --category state

# 마크다운 형식 출력 (문서에 바로 복사 가능)
python scripts/get_npm_versions.py react next --format markdown

# 전체 카테고리 조회
python scripts/get_npm_versions.py --all

# 카테고리 목록 확인
python scripts/get_npm_versions.py --list
```

### 카테고리 목록

- `frontend`: react, next, vue, nuxt, svelte, typescript, vite
- `styling`: tailwindcss, postcss, sass, emotion, styled-components
- `ui`: radix-ui, headlessui, mui, chakra-ui, antd
- `state`: zustand, jotai, redux, tanstack-query, swr
- `forms`: react-hook-form, zod, yup
- `backend`: express, fastify, hono, nestjs, prisma, drizzle-orm, trpc
- `testing`: vitest, jest, testing-library, playwright, cypress
- `utils`: axios, date-fns, dayjs, lodash, clsx
- `icons`: lucide-react, heroicons, phosphor-icons

### 수동 조회 (스크립트 없이)

```bash
curl -s https://registry.npmjs.org/PACKAGE_NAME/latest | jq '.version'
```

## 인터뷰 질문

순차적으로 질문하여 정보 수집. 한 번에 2-3개씩 질문.

### 필수 질문

**기존 환경**
- "기존에 사용 중인 기술이 있나요?"
- "팀의 기술 스택 선호도는?"

**규모 및 요구사항**
- "예상 트래픽/사용자 수는?"
- "연동해야 하는 외부 서비스는?"

**인프라**
- "클라우드 선호도는? (AWS/GCP/Vercel 등)"
- "CI/CD 요구사항은?"

### 선택 질문 (필요시)

- "모노레포 구성이 필요한가요?"
- "테스트 커버리지 요구사항은?"
- "모니터링/로깅 요구사항은?"

## Tech Stack 템플릿

```markdown
# Tech Stack: [서비스명]

## 1. 프론트엔드

### 코어
| 항목 | 선택 | 버전 | 선택 이유 |
|------|------|------|----------|
| 프레임워크 | | | |
| 언어 | | | |
| 스타일링 | | | |
| UI 라이브러리 | | | |

### 상태관리
- **클라이언트**:
- **서버 상태**:

### 주요 패키지
| 패키지명 | 버전 | 용도 |
|---------|------|------|
| | | |

## 2. 백엔드

### 코어
| 항목 | 선택 | 버전 | 선택 이유 |
|------|------|------|----------|
| 프레임워크 | | | |
| 언어 | | | |
| 아키텍처 | | | |
| API 스타일 | | | |

### 주요 패키지
| 패키지명 | 버전 | 용도 |
|---------|------|------|
| | | |

## 3. 데이터베이스

| 용도 | 선택 | 호스팅 | 선택 이유 |
|------|------|--------|----------|
| Primary DB | | | |
| 캐시 | | | |
| 검색엔진 | | | |
| 파일 스토리지 | | | |

## 4. 인프라 및 배포

### 호스팅
- **프론트엔드**:
- **백엔드**:

### CI/CD
- **플랫폼**:
- **스테이지**: dev → staging → production

### 모니터링
- **APM**:
- **로깅**:
- **애널리틱스**:

### 컨테이너
- **Docker**: Yes/No
- **오케스트레이션**:

## 5. 외부 API 및 서비스

| 서비스 | 선택 | 용도 | API 문서 |
|--------|------|------|---------|
| 인증 | | | |
| 결제 | | | |
| 이메일/SMS | | | |
| AI/ML | | | |

## 6. 개발 도구

| 도구 | 선택 |
|------|------|
| IDE | |
| 패키지 매니저 | |
| 모노레포 | |
| 린팅 | |
| 포매팅 | |
| 유닛 테스트 | |
| E2E 테스트 | |
| 문서화 | |
```

## 사용 예시

```
사용자: "기술 스택 정리해줘"

Claude: Tech Stack 문서를 작성하겠습니다. 먼저 몇 가지 질문을 드릴게요.

1. 기존에 사용 중인 기술이 있나요?
2. 팀의 기술 스택 선호도가 있다면 알려주세요.
```

```
사용자: "Next.js랑 TypeScript 쓰고 있어. 백엔드는 아직 안 정했어."

Claude: 좋습니다. 패키지 최신 버전을 조회하고 이어서 질문드릴게요.

[스크립트 실행: python scripts/get_npm_versions.py next typescript]

1. 예상 트래픽/사용자 수는 어느 정도인가요?
2. 연동해야 하는 외부 서비스가 있나요? (결제, 인증, AI 등)
```
