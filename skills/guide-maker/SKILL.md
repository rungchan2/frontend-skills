---
name: guide-maker
description: Place 프로젝트 사용자 가이드 문서를 Notion에 생성하는 스킬. 사용자가 특정 기능/페이지에 대한 가이드 문서 작성을 요청할 때 사용한다. "가이드 만들어줘", "사용자 매뉴얼 작성해줘", "도움말 문서 생성해줘", "Notion에 문서 작성해줘" 등의 요청에 트리거된다. Notion MCP (MCP_DOCKER)를 통해 place-guide 페이지 하위에 새 문서를 생성한다.
---

# Guide Maker

Place 프로젝트 기능에 대한 사용자 가이드를 Notion에 생성한다.

## 사전 요구사항

- Notion MCP (`MCP_DOCKER`) 연결 필요
- place-guide 페이지 ID: `2cdd59039b5b806d9e74dee25bfaa1f1`

## 워크플로우

### 1. 기능 파악

사용자에게 어떤 기능/페이지에 대한 가이드를 작성할지 확인:
- 기능명 (예: 출결관리, 학생등록, 수강료 관리)
- 해당 기능의 코드 위치 확인 (app/ 폴더)

### 2. 코드 분석

해당 기능의 실제 구현 분석:
- 페이지 컴포넌트 읽기
- 주요 기능 파악 (버튼, 폼, 테이블 등)
- 사용자 흐름 이해

### 3. Notion 페이지 생성

`mcp__MCP_DOCKER__API-post-page`로 새 페이지 생성:

```json
{
  "parent": { "page_id": "0656783731824d52aa4ac9523521bd14" },
  "properties": { "title": [{ "text": { "content": "📑 [기능명]" } }] }
}
```

### 4. 콘텐츠 작성

`mcp__MCP_DOCKER__API-patch-block-children`으로 블록 추가.
문서 구조는 references/guide-format.md 참조.

### 5. 완료

생성된 페이지 URL 전달: `https://www.notion.so/[page_id_without_hyphens]`

## 문서 구조

1. **페이지 위치** - 네비게이션 경로
2. **기능 개요** - 불릿 리스트로 주요 기능
3. **Part별 Step-by-step** - 단계별 설명 (이미지 플레이스홀더 포함)
4. **테이블 컬럼 설명** - 해당 시
5. **자주 묻는 질문** - FAQ 토글

## Notion 블록 레퍼런스

### 헤딩 (H2, H3)
```json
{ "type": "heading_2", "heading_2": { "rich_text": [{ "text": { "content": "제목" } }] } }
{ "type": "heading_3", "heading_3": { "rich_text": [{ "text": { "content": "소제목" } }] } }
```

### 단락
```json
{ "type": "paragraph", "paragraph": { "rich_text": [{ "text": { "content": "내용" } }] } }
```

### 굵은 텍스트 (annotations)
```json
{ "text": { "content": "굵은 텍스트" }, "annotations": { "bold": true } }
```

### 불릿/번호 리스트
```json
{ "type": "bulleted_list_item", "bulleted_list_item": { "rich_text": [{ "text": { "content": "항목" } }] } }
{ "type": "numbered_list_item", "numbered_list_item": { "rich_text": [{ "text": { "content": "항목" } }] } }
```

### 구분선
```json
{ "type": "divider", "divider": {} }
```

### 콜아웃 (Tip, 주의, 알림 등)
```json
{
  "type": "callout",
  "callout": {
    "icon": { "emoji": "💡" },
    "color": "blue_background",
    "rich_text": [{ "text": { "content": "팁 내용" } }]
  }
}
```

색상 옵션: `blue_background`, `yellow_background`, `red_background`, `green_background`, `gray_background`

아이콘 가이드:
- 💡 팁 (blue_background)
- ⚠️ 주의 (yellow_background)
- 🚨 위험 (red_background)
- ⚡ 빠른팁 (green_background)
- 📱 알림 (green_background)
- ⏰ 시간 (yellow_background)
- 📸 이미지 플레이스홀더 (gray_background)

### 토글 (FAQ용)
```json
{
  "type": "toggle",
  "toggle": {
    "rich_text": [{ "text": { "content": "Q: 질문" } }],
    "children": [
      { "type": "paragraph", "paragraph": { "rich_text": [{ "text": { "content": "A: 답변" } }] } }
    ]
  }
}
```

### 테이블
```json
{
  "type": "table",
  "table": {
    "table_width": 3,
    "has_column_header": true,
    "children": [
      {
        "type": "table_row",
        "table_row": {
          "cells": [
            [{ "text": { "content": "헤더1" } }],
            [{ "text": { "content": "헤더2" } }],
            [{ "text": { "content": "헤더3" } }]
          ]
        }
      },
      {
        "type": "table_row",
        "table_row": {
          "cells": [
            [{ "text": { "content": "데이터1" } }],
            [{ "text": { "content": "데이터2" } }],
            [{ "text": { "content": "데이터3" } }]
          ]
        }
      }
    ]
  }
}
```

### 이미지 플레이스홀더 (콜아웃으로 표현)
```json
{
  "type": "callout",
  "callout": {
    "icon": { "emoji": "📸" },
    "color": "gray_background",
    "rich_text": [{ "text": { "content": "스크린샷: [화면 설명]" } }]
  }
}
```

## 작성 가이드

- 버튼명, 메뉴명은 **굵게** 표시
- 정중한 어투 사용 (~합니다, ~됩니다)
- Step당 콜아웃 최대 2개
- 모든 Step에 이미지 플레이스홀더 포함
- FAQ는 실제 사용자 관점 질문으로 작성
