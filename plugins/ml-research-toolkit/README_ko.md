# ML Research Toolkit

*[English](README.md) · 한국어*

VLM/LLM 논문 연구를 위한 Claude Code 플러그인입니다. 아이디어 → 문헌 조사 → 실험 설계 → 학습 진단 → 평가 → 해석성 → 논문 작성 → 리뷰 대응까지, 연구 파이프라인 전 단계를 스킬과 서브에이전트로 묶었습니다. 설명은 한국어, 기술 용어·라이브러리·API는 영어 그대로 씁니다.

---

## Skills (21) — 연구 단계별

### 아이디어 · 문헌
| skill | 하는 일 |
|---|---|
| `idea-brainstorming` | 문제를 직교하는 novelty 축으로 매핑해 후보 아이디어를 생성하고, 경쟁 연구와 대조하며 스트레스 테스트합니다. |
| `deep-interview` | 소크라테스식 심층 인터뷰로 모호한 아이디어를 명확한 실험 스펙으로 결정화합니다(수학적 모호도 게이팅). |
| `paper-lookup` | 특정 claim/method의 선행연구를 Semantic Scholar·arXiv·OpenReview에서 서베이합니다. |
| `related-work-miner` | Related Work를 나열이 아니라 "입장의 taxonomy"로 설계하고, 각 군집과의 차별점 문장을 만듭니다. |
| `arxiv-verify` | 인용 전에 arXiv/ACL/venue 메타데이터(저자·연도·venue·arXiv ID)를 원문으로 확인합니다. |
| `citation-workflow` | Semantic Scholar/arXiv/DOI로 BibTeX를 검증·수집하고, 확인 불가한 항목은 PLACEHOLDER로 표시합니다. |

### 실험 설계 · 컴퓨트
| skill | 하는 일 |
|---|---|
| `ablation-matrix` | 다중 컴포넌트 실험의 공정·효율적 ablation 매트릭스를 구성하고 confound를 표시합니다. |
| `compute-budget-planner` | 고정 예산 아래 실험 포트폴리오의 GPU-hour/FLOPs/wall-clock을 추정하고 Pareto 축소안을 냅니다. |
| `seed-variance` | 여러 seed의 mean/std/bootstrap 95% CI/paired 유의성을 계산해 결과가 robust인지 판정합니다. |
| `counter-example-search` | 해석성 claim을 "강한 증거"로 승격하기 전에 반례를 능동적으로 찾아 반례율을 정량화합니다. |

### 학습 진단
| skill | 하는 일 |
|---|---|
| `ckpt-health-check` | 체크포인트의 loss/gate/표현/데이터-마스킹을 Check 1–4 진단으로 pass/warn/fail 판정합니다(다운스트림 평가 전 신뢰 여부 확인). |
| `device-audit` | 학습 코드에서 target device로 옮겨지지 않은 module/buffer/parameter를 찾아냅니다. |

### 논문 작성 · 그림
| skill | 하는 일 |
|---|---|
| `ml-paper-writing` | NeurIPS/ICML/ICLR/ACL/EMNLP/CVPR 논문을 작성합니다(references/·templates/ 포함). |
| `abstract-writer` | Abstract·Intro의 모든 문장을 {문제·gap·방법 한 줄·핵심 결과·임팩트} 중 하나에 매핑되도록 구조화합니다. |
| `claim-evidence-map` | 논문 전반의 모든 주장을 표 셀·그림 패널·부록에 연결하고, 끊긴 링크·근거 없는 주장을 찾아냅니다. |
| `figure-storyboard` | figure별로 (메시지 한 줄·visual grammar·근거 포인터·캡션 초안)을 강제하고 중복 그림을 잡아냅니다. |
| `svg-flowchart` | ML/VLM 아키텍처 파이프라인의 다크테마 SVG 플로우차트를 생성합니다. |
| `notation-consistency` | 섹션 간 표기 불일치(변수 재사용·차원·인덱스 충돌·미정의 기호)를 스캔하고 기호표를 냅니다. |
| `latex-polish` | LaTeX 소스를 top-tier 제출 기준으로 정리합니다(math-mode·citation·macro·spacing·float). |

### 리뷰 대응
| skill | 하는 일 |
|---|---|
| `reviewer-angle` | 예상 리뷰어 반론 5개 이상을 생성하고 각각에 1–3문장 대응을 만듭니다(baseline 공정성·OOD 누수·seed 분산 등). |
| `rebuttal-drafter` | 리뷰어 코멘트를 factual/methodological/clarity/out-of-scope로 분류하고 근거에 매핑된 리버틀을 작성합니다. |

## Subagents (12)
| agent | 하는 일 |
|---|---|
| `research-ideator` | 문제·제약을 받아 novelty 축을 매핑하고 후보를 스코어링해 top-3 shortlist를 냅니다. |
| `literature-scout` | arXiv·Semantic Scholar·OpenReview를 오케스트레이션해 dedup + citation graph 포함 서베이 리포트를 만듭니다. |
| `paper-scout` | 논문별로 TL;DR·기여·방법·결과·관련성·한계를 구조화 요약합니다. |
| `experiment-designer` | 가설을 baseline·ablation 축·통제변수·성공 기준이 명시된 falsifiable 실험 스펙으로 변환합니다. |
| `compute-planner` | 실험 포트폴리오를 GPU-hour cost card + 의존성 DAG로 만들고 예산 초과 시 축소안을 제안합니다. |
| `training-diagnostician` | loss 곡선·gradient·활성값·gate·engram 활용을 점검해 underfit/overfit/collapse 등을 진단합니다. |
| `vqa-eval-analyst` | ChartQA/ScienceQA/TextVQA 등 벤치마크 결과를 도메인·질문유형별로 분해하고 통계검정·오류분석합니다. |
| `interpretability-researcher` | logit-lens·gate α 히트맵·codebook probing·attention 패턴 분석 등 해석성 아티팩트를 만듭니다. |
| `academic-writer` | Method/Experiments/Related Work 초안을 publication-grade 영어로 작성하고 주장-근거를 매핑합니다. |
| `paper-architect` | figure 스토리보드·related-work taxonomy·claim-evidence map 세 축으로 논문 구조 정합성을 점검합니다. |
| `tex-polisher` | LaTeX 소스의 기계적 일관성과 표기 일관성을 점검·정리합니다. |
| `rebuttal-writer` | 리뷰어 코멘트를 번호화·분류하고 근거에 매핑된 답변을 venue 글자 예산 안에서 작성합니다. |

## Rules (3) — `rules/`

연구 산출물 전반에 항상 적용되는 공통 규칙입니다(AWS 전용 규칙은 자매 플러그인에만 있고 여기엔 없습니다).
- `fact-integrity` — 사실/인용 무결성: 확인 못 한 것을 confirmed로 쓰지 않기, 1차 소스 우선, 검증은 `arxiv-verify`/`citation-workflow`에 위임.
- `code-style` — 코드 스타일: 주변 코드 닮기, seed 고정으로 재현성, 노트북은 초심자 친화.
- `communication` — 어조·언어: 한국어 우선, 용어는 영어, 과장 금지, 존댓말.

## 설치

```
/plugin marketplace add <owner>/claude-ml-plugins
/plugin install ml-research-toolkit@daekeun-ml-plugins
```

설치 없이 한 세션만 로컬 테스트:
```
claude --plugin-dir ./plugins/ml-research-toolkit
```

### ⚠️ 규칙(rules) 로딩
Claude Code 플러그인은 `CLAUDE.md`/`@import`를 자동으로 로드하지 않습니다. 이 플러그인은 ① SessionStart 훅으로 핵심 규칙(사실·인용 무결성, 코드 스타일, 커뮤니케이션)을 세션 시작 시 주입하고, ② 규칙 전문을 `rules/`에 포함합니다. 항상 로드되길 원하시면, 본인 `~/.claude/CLAUDE.md`의 (OMC 등 관리 블록 **바깥**) 위치에 아래처럼 추가하세요.
```
@<플러그인 설치 경로>/rules/fact-integrity.md
@<플러그인 설치 경로>/rules/code-style.md
@<플러그인 설치 경로>/rules/communication.md
```

## 참고
- 일부 스킬·에이전트에는 **memory-augmented VLM 연구(예: VisEngram) 맥락에 특화된 표현**이 있습니다(예: `ckpt-health-check`의 gate α·engram). 일반 VLM/LLM 연구에도 응용할 수 있으나, 프로젝트 고유 용어는 필요에 따라 조정하세요.
- 에이전트에는 `model: opus/sonnet` 라우팅이 지정돼 있습니다. 표준 Anthropic API 환경에서 동작하며, non-standard provider(Bedrock/Vertex 등) 환경에서는 부모 세션 모델로 상속되거나 무시됩니다.
- 파인튜닝·AWS 인프라 자산은 자매 플러그인 `aws-sagemaker-toolkit`을 참고하세요.

## 라이선스
MIT
