---
name: ml-paper-writing
description: Write publication-ready ML/VLM/LLM papers for NeurIPS, ICML, ICLR, ACL, EMNLP, CVPR. Use when drafting papers from research repos, structuring arguments, verifying citations, or preparing camera-ready submissions.
version: 1.0.0
tags: [Academic Writing, NeurIPS, ICML, ICLR, ACL, EMNLP, CVPR, LaTeX, Paper Writing, Citations, VLM, LLM]
triggers: ["논문 써줘", "paper writing", "논문 작성", "related work", "abstract 써줘", "introduction 써줘", "실험 섹션", "camera-ready"]
---

# ML Paper Writing — LLM/VLM Research

NeurIPS, ICML, ICLR, ACL, EMNLP, CVPR 투고를 위한 publication-ready 논문 작성 가이드.
연구 repo의 코드/결과/실험 artifact에서 시작해 완성 초고를 제공한다.

---

## ⚠️ CRITICAL: 인용 출처 날조 금지

**AI 생성 citation의 오류율은 ~40%. 이것은 academic misconduct다.**

| 행동 | ✅ 올바른 방법 | ❌ 잘못된 방법 |
|------|-------------|-------------|
| 인용 추가 | API 검색 → 확인 → BibTeX fetch | 기억으로 BibTeX 작성 |
| 논문 불확실 | `[CITATION NEEDED]` 마크 | 비슷한 논문 추측 |
| 검증 불가 | "placeholder - verify" 명시 | 제목/저자 조작 |

검증 불가 시 반드시:
```latex
\cite{PLACEHOLDER_author2024_verify}  % TODO: 직접 확인 필요
```

---

## Core Philosophy

**논문은 협업이지만, Claude는 먼저 완성 초고를 제공한다.**

1. repo 탐색 → 결과/실험 파악
2. 핵심 contribution 식별 → 연구자와 확인
3. 문헌 검색 및 인용 검증
4. **완성 초고 제공** — 섹션별로 허락 구하지 않는다
5. 피드백 → 반복 수정

> Karpathy: "논문은 하나의 핵심을 판다. 모든 것이 그 기여를 위해 존재한다."
> Nanda: "기여를 한 문장으로 말할 수 없으면 아직 논문이 없다."

---

## Workflow 0: Research Repo에서 시작

```
[ ] Step 1: repo 구조 탐색 (코드, results/, experiments/, README)
[ ] Step 2: 핵심 결과 수치 파악
[ ] Step 3: 기존 인용 파악 (.bib, grep arxiv/doi)
[ ] Step 4: contribution 한 문장 확인 (연구자와)
[ ] Step 5: 추가 문헌 검색
[ ] Step 6: 완성 초고 제공
[ ] Step 7: 피드백 반영 반복
```

**repo 탐색 명령:**
```bash
ls -la && find . -name "*.py" | head -20
find . -name "*.md" -o -name "results*" | head -20
grep -r "arxiv\|doi\|cite" --include="*.md" --include="*.bib" | head -20
```

초고 제공 후 질문 포함 방식:
- "X를 핵심 기여로 프레이밍했습니다 — 다르게 강조하고 싶으시면 말씀해 주세요"
- "A, B, C 결과를 부각했습니다 — 더 중요한 수치가 있으면 알려주세요"

---

## Workflow 1: Section별 작성 가이드

### Abstract (5문장 공식 — Farquhar)

1. **무엇을 달성했나**: "We introduce...", "We propose...", "We demonstrate..."
2. **왜 어렵고 중요한가**
3. **어떻게 했나** (specialist keyword 포함, 검색 노출용)
4. **어떤 증거가 있나**
5. **가장 인상적인 수치/결과**

❌ 금지 오프닝:
- "Large language models have achieved remarkable success..."
- "Deep learning has revolutionized..."
- "In recent years, neural networks have..."

대신 구체적 기여부터 시작.

---

### Introduction (1–1.5 페이지)

```
1. Opening Hook (2–3문장): 문제 + 지금 중요한 이유
2. Background/Challenge (1단락): 기존 방법의 한계
3. Our Approach (1단락): 핵심 인사이트
4. Contribution Bullets (2–4개, 각 1–2줄):
   ✅ "We propose X that reduces Y by Z% on benchmark W"
   ❌ "We study the problem of X" (기여 아님)
5. Results Preview (2–3문장): 핵심 수치
6. Paper Organization (선택, 1–2문장)
```

---

### Method Section

- **수식 전에 직관** 먼저 — 독자가 따라올 수 있어야 함
- 각 컴포넌트: 동기 → 수식 → 구현 세부사항
- Figure/Diagram으로 전체 파이프라인 시각화 (svg-flowchart 스킬 활용)
- Notation table: 첫 등장 시 정의, 이후 일관 사용

**LLM/VLM 특화 체크:**
- [ ] 백본 모델 버전/크기 명시
- [ ] Frozen vs trainable 파라미터 구분
- [ ] Training objective 수식 명시
- [ ] 추가 파라미터 수 명시 (Table 또는 text)

---

### Experiments Section

```
구조:
1. Setup (데이터셋, 베이스라인, 구현 세부사항, 하이퍼파라미터)
2. Main Results (primary 비교 테이블)
3. Ablation Study (각 컴포넌트의 기여)
4. Analysis (오류 분석, 케이스 스터디, 시각화)
```

**VLM/LLM 실험 체크리스트:**
- [ ] 베이스라인이 공정하게 튜닝됐는가 (같은 하이퍼파라미터 탐색)
- [ ] 복수 시드 결과 또는 표준편차 보고
- [ ] 트레이닝/평가 데이터 중복 확인
- [ ] 어블레이션이 각 컴포넌트를 독립적으로 검증하는가
- [ ] 실패 케이스 포함 (리뷰어 신뢰도 ↑)

---

### Related Work

3단계 구조:
1. **Problem Context** — 다루는 문제를 연구한 선행 연구
2. **Method Context** — 유사 방법론 사용 연구
3. **Our Differentiation** — 왜 우리 방법이 다른지 명시

각 비교: "X does A, but not B. We do both by C."

---

### Conclusion

- 1단락: 기여 요약 (abstract 반복 아님 — 무엇을 배웠는가)
- 1단락: 한계 (리뷰어 신뢰도 ↑, 솔직할수록 좋음)
- 1단락: 미래 방향 (구체적으로)

---

## Workflow 2: Citation 검증

**검색 순서:**
1. Semantic Scholar API (title/author 검색)
2. arXiv (abs/pdf URL로 직접 확인)
3. DOI → BibTeX fetch

```python
# Semantic Scholar 검색 예시
import requests
r = requests.get(
    "https://api.semanticscholar.org/graph/v1/paper/search",
    params={"query": "attention is all you need", "fields": "title,authors,year,externalIds"}
)
```

**BibTeX fetch (DOI 있을 때):**
```python
import requests
doi = "10.48550/arXiv.1706.03762"
r = requests.get(f"https://doi.org/{doi}", headers={"Accept": "application/x-bibtex"})
```

검증 후 `.bib` 파일에 추가. placeholder는 반드시 `% TODO:` 주석 포함.

---

## Workflow 3: Venue별 체크리스트

### 공통
- [ ] Abstract ≤ venue limit (보통 150–250 단어)
- [ ] Introduction 1–1.5 페이지
- [ ] 모든 수식에 번호
- [ ] Figure caption 자립적 (본문 없이 이해 가능)
- [ ] 참고문헌 스타일 venue 규정 준수
- [ ] Appendix에 구현 세부사항/추가 실험

### NeurIPS / ICML / ICLR
- [ ] Broader Impact 섹션 (NeurIPS 필수)
- [ ] Code availability 명시
- [ ] Reproducibility checklist 첨부

### ACL / EMNLP
- [ ] Limitations 섹션 (ACL 2021+ 필수)
- [ ] Ethics statement
- [ ] Human evaluation이 있으면 IRB/crowdworker 정보

### CVPR / ICCV / ECCV
- [ ] Supplementary material 분리
- [ ] Qualitative results 포함 (시각화)
- [ ] Comparison figure (테이블만으로 부족)

---

## Workflow 4: 논문 구조 점검 (제출 전)

**30분 자기 리뷰:**

```
Narrative check:
[ ] 제목만 보고 기여를 추측할 수 있는가
[ ] Abstract 5문장이 완결성 있는가
[ ] Introduction 마지막에 contribution이 bullet으로 명시됐는가
[ ] Main table에 베이스라인 대비 명확한 Δ가 있는가
[ ] Ablation이 각 컴포넌트를 독립 검증하는가

Clarity check:
[ ] Figure 1이 논문의 핵심 아이디어를 시각화하는가
[ ] Method의 핵심 수식 바로 앞에 직관적 설명이 있는가
[ ] 모든 notation이 처음 등장 시 정의됐는가

Reviewer 관점 check:
[ ] "왜 이 베이스라인?" 질문에 답이 있는가
[ ] "왜 이 데이터셋?" 질문에 답이 있는가
[ ] 한계가 솔직하게 논의됐는가
[ ] Reproducibility: 하이퍼파라미터, 시드, 환경 명시
```

---

## Tool Usage

**Skills (main agent invokes directly):**
- `svg-flowchart` 스킬: 아키텍처 다이어그램
- `reviewer-angle` 스킬: 리뷰어 반론 사전 점검
- `latex-polish` 스킬: LaTeX 기계적 일관성
- `claim-evidence-map` 스킬: 주장-증거 매핑
- `ablation-matrix` 스킬: 어블레이션 설계
- `rebuttal-drafter` 스킬: 리뷰 답변
- `citation-workflow` 스킬: Semantic Scholar / arXiv / DOI 기반 인용 검증 및 BibTeX fetch
- `figure-storyboard` 스킬: 제출 전 figure 구성 점검
- `abstract-writer` 스킬: abstract / intro 구조 점검 및 재작성
- `related-work-miner` 스킬: related work taxonomy 설계

**Subagents (delegate via Agent tool):**
- Agent(subagent_type="academic-writer"): 완성 초고 prose 작성 — Method / Experiments / Related Work / Ablation 섹션
- Agent(subagent_type="literature-scout"): 멀티소스 문헌 서베이 (arXiv + Semantic Scholar + OpenReview), citation graph 확장, gap 분석
- Agent(subagent_type="paper-scout"): 개별 논문 심층 요약 (TL;DR / Contribution / Method / Relevance / Limitations)
- Agent(subagent_type="paper-architect"): 논문 구조 무결성 검증 — figure storyboard, claim-evidence map, related work taxonomy 3-pass
- Agent(subagent_type="experiment-designer"): 실험 스펙 설계 (falsifiable, 베이스라인, 평가 프로토콜)
- Agent(subagent_type="vqa-eval-analyst"): eval 결과 집계, bootstrap CI, 오류 분석
- Agent(subagent_type="rebuttal-writer"): 리뷰어 응답 초안 (venue 자수 제한 준수, 증거 매핑)
- Agent(subagent_type="tex-polisher"): LaTeX 소스 기계적 일관성 — math-mode, citation style, macro, float placement
- Agent(subagent_type="compute-planner"): GPU-hour 비용 산출, 실험 의존성 DAG, 예산 내 Pareto-efficient 서브셋

---

## References

- `references/writing-guide.md` — Nanda/Karpathy/Farquhar/Lipton/Steinhardt 철학
- `references/checklists.md` — venue별 제출 체크리스트
- `references/reviewer-guidelines.md` — 리뷰어 평가 기준 요약
