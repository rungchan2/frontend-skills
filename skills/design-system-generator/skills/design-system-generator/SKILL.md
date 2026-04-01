---
name: design-system-generator
description: Design System 문서 작성 가이드. 일관된 UI/UX를 위한 디자인 규칙과 컴포넌트를 정의한다. 사용자가 "디자인 시스템 만들어줘", "UI 가이드라인 정리해줘", "컬러/타이포그래피 정의해줘", "컴포넌트 스타일 가이드 만들어줘" 등을 요청할 때 사용한다.
---

# Design System Generator

일관된 UI/UX를 위한 디자인 시스템 문서 생성 가이드.

## 워크플로우

```
1. 인터뷰 → 2. 팔레트 생성 → 3. 문서 생성 → 4. 검토/보완
```

## 컬러 팔레트 생성

Primary 색상 하나로 전체 컬러 시스템을 자동 생성한다.

### 스크립트 사용

```bash
# 기본 (마크다운 출력)
python scripts/generate_palette.py "#3B82F6"

# Tailwind 설정 형식
python scripts/generate_palette.py "#3B82F6" --format tailwind

# CSS 변수 형식
python scripts/generate_palette.py "#3B82F6" --format css

# 시맨틱 컬러 포함
python scripts/generate_palette.py "#3B82F6" --with-semantic

# Secondary 색상 지정 (미지정시 보색 자동 생성)
python scripts/generate_palette.py "#3B82F6" --secondary "#F97316"
```

### 출력 예시

```
## Primary Colors
| Shade | HEX |
|-------|-----|
| 50 | #F0F7FF |
| 100 | #E0EFFF |
| 500 | #3B82F6 |  ← 기준 색상
| 900 | #1E3A5F |

Secondary (보색): #F6B83B
유사색: #3BF682, #823BF6
```

## 레퍼런스 파일

| 파일 | 용도 | 언제 참조 |
|------|------|----------|
| `references/brand-recommendations.md` | 브랜드 키워드별 컬러/폰트/스타일 추천 | 브랜드 성격 파악 후 |

## 인터뷰 질문

순차적으로 질문하여 정보 수집. 한 번에 2-3개씩 질문.

### 필수 질문

**브랜드**
- "브랜드 가이드라인이 있나요?"
- "브랜드 성격 키워드 3개는? (예: 신뢰, 혁신, 친근, 럭셔리, 에너지)"

**UI/UX**
- "참고하고 싶은 서비스 UI는?"
- "타겟 디바이스 비율은? (모바일/데스크톱)"
- "다크모드 지원이 필요한가요?"

### 선택 질문 (필요시)

- "사용할 폰트가 정해져 있나요?"
- "Primary 색상이 정해져 있나요?"
- "아이콘 라이브러리 선호도는?"

## Design System 템플릿

```markdown
# Design System: [서비스명]

## 1. 브랜드 아이덴티티

- **브랜드명**:
- **브랜드 성격**:
- **톤앤매너**:

## 2. 컬러 시스템

### Primary
| Shade | HEX | 용도 |
|-------|-----|------|
| 50 | | 배경 |
| 100 | | 호버 |
| 200 | | |
| 300 | | |
| 400 | | |
| 500 | | 기본 |
| 600 | | 호버 (다크) |
| 700 | | |
| 800 | | |
| 900 | | 텍스트 |

### Secondary
| Shade | HEX | 용도 |
|-------|-----|------|
| 500 | | 기본 |

### Semantic
| 이름 | Light | Main | Dark | 용도 |
|------|-------|------|------|------|
| success | #DCFCE7 | #22C55E | #16A34A | 성공, 완료 |
| warning | #FEF3C7 | #F59E0B | #D97706 | 경고, 주의 |
| error | #FEE2E2 | #EF4444 | #DC2626 | 오류, 실패 |
| info | #DBEAFE | #3B82F6 | #2563EB | 정보, 안내 |

### Neutral (Gray Scale)
| Shade | HEX |
|-------|-----|
| 50 | #F9FAFB |
| 100 | #F3F4F6 |
| 200 | #E5E7EB |
| 300 | #D1D5DB |
| 400 | #9CA3AF |
| 500 | #6B7280 |
| 600 | #4B5563 |
| 700 | #374151 |
| 800 | #1F2937 |
| 900 | #111827 |

### 배경
- **default**: #FFFFFF
- **paper**: #F9FAFB
- **elevated**: #FFFFFF

### 다크모드
- 지원 여부: Yes/No

## 3. 타이포그래피

### 폰트 패밀리
- **한글**: Pretendard
- **영문**: Inter
- **Monospace**: Fira Code

### 사이즈 스케일
| 이름 | Size | Line Height |
|------|------|-------------|
| xs | 12px | 16px |
| sm | 14px | 20px |
| base | 16px | 24px |
| lg | 18px | 28px |
| xl | 20px | 28px |
| 2xl | 24px | 32px |
| 3xl | 30px | 36px |
| 4xl | 36px | 40px |

### 헤딩 스타일
| 레벨 | Size | Weight | Line Height |
|------|------|--------|-------------|
| h1 | 36px | 700 | 40px |
| h2 | 30px | 600 | 36px |
| h3 | 24px | 600 | 32px |
| h4 | 20px | 600 | 28px |

## 4. 스페이싱 및 레이아웃

### 기본 단위
- **Base**: 4px

### 스페이싱 스케일
| 이름 | 값 |
|------|-----|
| 0 | 0px |
| 1 | 4px |
| 2 | 8px |
| 3 | 12px |
| 4 | 16px |
| 6 | 24px |
| 8 | 32px |
| 12 | 48px |
| 16 | 64px |

### Breakpoints
| 이름 | 값 | 설명 |
|------|-----|------|
| sm | 640px | 모바일 |
| md | 768px | 태블릿 |
| lg | 1024px | 데스크톱 |
| xl | 1280px | 와이드 |
| 2xl | 1536px | 울트라와이드 |

### 컨테이너
- **최대 너비**: 1280px
- **패딩**: 모바일 16px, 태블릿 24px, 데스크톱 32px

## 5. 컴포넌트 스타일

### Border Radius
| 이름 | 값 | 용도 |
|------|-----|------|
| none | 0px | 날카로운 |
| sm | 4px | 인풋, 작은 요소 |
| md | 8px | 카드, 버튼 |
| lg | 12px | 모달, 큰 카드 |
| xl | 16px | 컨테이너 |
| full | 9999px | 아바타, 뱃지 |

### 그림자
| 이름 | 값 | 용도 |
|------|-----|------|
| sm | 0 1px 2px rgba(0,0,0,0.05) | 미묘한 |
| base | 0 1px 3px rgba(0,0,0,0.1) | 기본 |
| md | 0 4px 6px rgba(0,0,0,0.1) | 카드 |
| lg | 0 10px 15px rgba(0,0,0,0.1) | 드롭다운 |
| xl | 0 20px 25px rgba(0,0,0,0.1) | 모달 |

### 버튼
- **사이즈**: sm (32px), md (40px), lg (48px)
- **변형**: solid, outline, ghost
- **상태**: default, hover, active, disabled

### 인풋
- **사이즈**: sm (32px), md (40px), lg (48px)
- **변형**: outline, filled
- **상태**: default, focus, error, disabled

## 6. 애니메이션

### 지속시간
| 이름 | 값 | 용도 |
|------|-----|------|
| fast | 150ms | 호버, 토글 |
| normal | 300ms | 페이드, 슬라이드 |
| slow | 500ms | 페이지 전환 |

### 이징
| 이름 | 값 |
|------|-----|
| default | cubic-bezier(0.4, 0, 0.2, 1) |
| enter | cubic-bezier(0, 0, 0.2, 1) |
| exit | cubic-bezier(0.4, 0, 1, 1) |

## 7. 아이콘 및 이미지

### 아이콘
- **라이브러리**: Lucide React
- **기본 사이즈**: 24px
- **Stroke Width**: 2px

### 이미지
| 이름 | Ratio | 용도 |
|------|-------|------|
| square | 1:1 | 아바타, 썸네일 |
| landscape | 16:9 | 히어로, 배너 |
| portrait | 3:4 | 카드 |
| thumbnail | 4:3 | 리스트 |

- **Placeholder**: blur
- **Lazy Loading**: Yes
```

## 사용 예시

```
사용자: "디자인 시스템 만들어줘"

Claude: Design System 문서를 작성하겠습니다. 먼저 몇 가지 질문을 드릴게요.

1. 브랜드 가이드라인이 있나요?
2. 브랜드 성격 키워드 3개를 알려주세요. (예: 신뢰, 혁신, 친근)
```

```
사용자: "가이드라인 없어. 모던하고 깔끔하고 전문적인 느낌."

Claude: 좋습니다. "모던, 깔끔, 전문적" 키워드 기반으로
references/brand-recommendations.md를 참고하여 추천드릴게요.

추천 컬러: 블루 계열 (#3B82F6) 또는 퍼플 계열 (#7C3AED)
추천 폰트: Pretendard + Inter

Primary 색상을 정해주시면 팔레트를 생성해드릴게요.
```

```
사용자: "#6366F1로 해줘"

Claude: [스크립트 실행]
python scripts/generate_palette.py "#6366F1" --with-semantic --format markdown

생성된 팔레트로 디자인 시스템 문서를 작성하겠습니다.
```
