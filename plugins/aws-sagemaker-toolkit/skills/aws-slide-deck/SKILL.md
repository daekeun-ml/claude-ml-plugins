---
name: aws-slide-deck
description: Turn an existing AWS markdown guide/decision doc into an AWS-themed PPTX using the myslide skill and the md/ppt-build scaffold. Reuses the established dark reInvent style (title/table/section helpers), enforces a color-semantic convention (one accent per option, e.g. orange=Option B, teal=Option A), builds comparison-table and architecture slides, requires a design-spec approval gate for 8+ slides, and runs two-phase QA. Use when asked to make slides/발표자료/PPTX from an AWS doc.
allowed-tools: Read, Write, Edit, Bash, Skill, AskUserQuestion
argument-hint: "<source .md path> [dark|light] [slide count]"
triggers: ["슬라이드", "슬라이드 만들어", "발표자료", "pptx", "슬라이드로", "deck", "슬라이드 덱", "ppt로", "프레젠테이션"]
level: 2
---

# AWS Slide Deck — md 문서 → AWS 테마 PPTX

기존 AWS 마크다운 가이드/의사결정 문서를 **myslide** 스킬 + `md/ppt-build/` 스캐폴드로 PPTX화하는 스킬.

## When to Activate
- 완성된 `.md` 문서(가이드·비교표·아키텍처)를 "슬라이드/발표자료/PPTX로 만들어줘" 요청
- 기존 덱(`HyperPod-스토리지-추천전략.pptx` 등)과 같은 룩으로 새 덱이 필요할 때

## The Insight
슬라이드는 **문서를 그대로 옮기는 게 아니라, 색·표·아키텍처 도식으로 "결정과 대조"를 시각화**하는 것.
그리고 이미 검증된 스캐폴드(`ppt-build/`)와 재사용 함수가 있으니 **처음부터 만들지 말고 재사용**한다.

## The Approach
1. **소스·테마 확인** — 어떤 `.md`, dark(reInvent 기본) vs light(L100/교육), 슬라이드 수.
2. **myslide 스킬 호출** — `Skill(myslide:myslide, args="<md path> 기반 ... 한국어")`. 테마 레퍼런스·slide-patterns 로드.
3. **기존 스캐폴드 재사용** — `md/ppt-build/`의 `node_modules`(pptxgenjs·sharp), 재사용 함수 `title()`·`kicker()`·`table()`·`section()`·`mkShadow()`·`iconPng()`. 가장 유사한 기존 `create_*.js`를 템플릿으로 복제.
4. **색 의미 규약 정하기** — 옵션당 액센트 1개 고정(예: 🟠 orange=권장/Option B, 🔵 teal=Option A, 🟢 green=양쪽 공통, 🟣 magenta=카드 보더, 핑크=섹션 번호만). 덱 전체 일관.
5. **디자인 스펙 게이트** — 8+ 슬라이드면 `design-specs/*.md` 작성 → 승인 대기(AskUserQuestion). 3~7이면 스펙만, 1~2면 생략.
6. **배경 에셋** — `create_aws_slide.py backgrounds --output-dir /tmp/myslide-assets/` (비어있으면 재생성).
7. **빌드** — `node create_<deck>.js` → `.pptx` 출력(저장소 루트 컨벤션에 맞춰).
8. **두 단계 QA** — ① `qa_validate.py`(bounds·폰트≥15pt·connector) → ② 시각 QA(kiro/subagent, 정렬·대비·레이아웃 다양성).

## Slide Composition (AWS 문서 → 슬라이드 매핑)
- 문서 §0 TL;DR → **의사결정 카드 슬라이드**(table)
- 운영 비교표 → **대형 comparison table**(dimension|A|B, 헤더 purple)
- "두 옵션의 실체"/아키텍처 → **native architecture 슬라이드**(ROUNDED_RECTANGLE + AWS 아이콘 + 화살표)
- 권장 로직 → **2컬럼(choose A / choose B)** + 하단 권장 디폴트 바
- ❓오해 정정 → **경고형 content card**(오렌지 보더)
- 확인사항 → **체크리스트 + Thank You**

## Gotchas
- **레이아웃 3연속 금지** — 같은 패턴 반복 피하고, 섹션/표/카드/아키텍처를 섞음.
- **폰트 ≥15pt** — 표 셀·프로세스 카드 포함. 넘치면 폰트 줄이지 말고 텍스트 줄이기.
- **ROUNDED_RECTANGLE + line 보더** — 액센트는 얇은 바 오버레이 말고 border color로.
- **색 5개 이내** — 규약 외 색(lavender·salmon 등) 금지.
- **아이콘 매핑** — `myslide/icons/`에 실제 있는지 확인(예: ALB는 `elb.svg`로 대용, `alb.svg` 없음). privatelink·acm·cognito 등 fuzzy 검색.
- **저장 위치** — 기존 `.pptx`들이 있는 저장소 루트 컨벤션을 따를 것(하위 폴더 아님).
- **승인 없이 8+ 빌드 금지** — 스펙 승인 후 빌드.

## Example
```
사용자: 이 md를 슬라이드로 만들어줘
→ myslide 호출 → ppt-build/create_hyperpod_storage.js를 템플릿으로 복제
  → 색 규약(orange=Endpoint, teal=Ingress) → 12슬라이드 design-spec → 승인
  → 배경 생성 → node create_*.js → qa_validate → 시각 QA
```

## Related
- `myslide:myslide` — 실제 PPTX 생성 엔진(이 스킬이 호출)
- `aws-architecture-decision` / `aws-tech-guide` — 슬라이드의 소스 문서를 만드는 스킬
- `svg-flowchart` — 아키텍처 다이어그램 SVG 보강
