# AWS SageMaker Toolkit

*[English](README.md) · 한국어*

AWS AI/ML Solutions Architect의 실무를 돕는 Claude Code 플러그인입니다. 컴퓨트 플랫폼 선택부터 가이드 작성, 실습 코드 생성, E2E 파인튜닝 파이프라인, 사실 검증까지 하나로 묶었습니다. 세 가지 원칙을 지킵니다.

- **3-tier 구분**: EC2(self-managed) / HyperPod(semi-managed, Slurm·EKS) / SageMaker(fully-managed)를 명확히 나누고, 한 tier의 기능을 다른 tier에 잘못 귀속하지 않습니다(tier 오귀속 방지).
- **사실은 검증 후에**: AWS 사양은 자주 바뀌므로, 기억이 아니라 공식 문서·GitHub로 확인한 사실만 산출물에 넣습니다.
- **작성과 검증을 분리**: 코드/문서를 만드는 lane과 사실을 검증하는 lane을 나눠, 자기 산출물을 스스로 승인하지 않습니다.

설명은 한국어, 서비스명·API·식별자는 영어 그대로 씁니다.

---

## Skills (11)

### 플랫폼 결정 · 아키텍처
| skill | 하는 일 | 언제 쓰나 |
|---|---|---|
| `aws-compute-platform-selector` | EC2 / HyperPod(Slurm·EKS) / SageMaker 중 워크로드에 맞는 tier를 운영부담·복원력·지속성·비용모델·팀 스킬셋 축으로 비교하고, "~할 때는 ~를 고르세요" 식 조건부 권장을 냅니다. HyperPod로 좁혀지면 Slurm vs EKS 세부 결정으로 이어집니다. | "학습/서빙을 어디서 하지?", "EC2 vs HyperPod vs SageMaker 뭘 고르지?" |
| `aws-architecture-decision` | 두 개 이상의 아키텍처 선택지(예: self-managed Ingress vs SageMaker Endpoint)를 운영 관점 비교표로 정리하고, 확정 사실과 불확실한 부분을 나눠 조건부로 권장합니다. "문서가 왜 X를 기본처럼 보이게 하는지"까지 설명합니다. | 기능 목록이 아니라 운영상 트레이드오프가 필요한 갈림길 |

### 가이드 작성
| skill | 하는 일 | 언제 쓰나 |
|---|---|---|
| `aws-tech-guide` | "hyperpod docs" 하우스 스타일(TL;DR → 쉬운 설명 → 상세 → ❓오해 노트 → 검증된 출처표)로 초심자도 이해하되 정확한 AWS 기술 가이드를 씁니다. 대조표와 "왜?" 섹션을 강제합니다. | 서비스/아키텍처 학습 문서, 온보딩 문서 작성 |
| `sagemaker-deep-dive` | SageMaker(완전관리형) 심화 가이드를 씁니다 — Training Jobs(Managed Spot 최대 90%, Warm Pool, S3 체크포인트), 추론 4종(Real-time/Serverless/Asynchronous/Batch Transform), JumpStart, Studio, DLC vs HyperPod DLAMI. HyperPod와의 오귀속을 막는 ❓오해 노트를 넣습니다. | SageMaker 완전관리형 문서 작성·보강 |
| `aws-slide-deck` | 완성된 마크다운 가이드를 AWS 테마 PPTX로 변환합니다(reInvent 다크 스타일, 옵션별 색 규약, 비교표·아키텍처 슬라이드). ⚠️ 외부 `myslide` 스킬에 의존합니다(아래 참고). | 문서를 발표자료/PPTX로 |

### 실습 코드
| skill | 하는 일 | 언제 쓰나 |
|---|---|---|
| `aws-ml-lab-code` | tier별 관용구에 맞는 실행 가능한 Python 스크립트·JupyterLab 노트북을 생성합니다(EC2: torchrun/accelerate, HyperPod Slurm: sbatch+srun, HyperPod EKS: CRD+kubectl, SageMaker: SDK). 공식 예제 repo에 근거하고, 시크릿 대신 플레이스홀더를 쓰며, 과금 방지 cleanup 셀을 필수로 넣습니다. | 특정 tier의 샘플/실습 코드·노트북이 필요할 때 |

### E2E 파인튜닝 (인터뷰 → 학습 → 배포 → agentic)
| skill | 하는 일 | 언제 쓰나 |
|---|---|---|
| `sagemaker-e2e-finetune` | **오케스트레이터.** 게이트형 인터뷰(deep-interview 방식)로 task 정의 → HF 오픈 라이선스 모델/데이터셋 후보 → 데이터 크기·합성 필요 여부 → (필요 시) 합성 데이터 생성 → 학습(표준이면 JumpStart, 커스텀/최신이면 HF DLC로 자동 분기) → endpoint 배포 → (선택) agentic loop까지 안내하고, 스펙을 확정한 뒤 하위 스킬로 실제 에셋을 생성합니다. | 단일 학습 스크립트가 아니라 E2E 파인튜닝 자산 전체가 필요할 때 |
| `sagemaker-finetune-lab` | 학습→endpoint 코드를 두 경로로 생성합니다 — JumpStart(`JumpStartEstimator`, LoRA 하이퍼·gated 모델 `accept_eula`) 또는 HuggingFace DLC(`sagemaker.huggingface.HuggingFace` + TRL/PEFT `source_dir` 스크립트). cleanup·CloudWatch 링크·플레이스홀더 규약을 상속합니다. | 특정 경로의 학습→배포 코드가 필요할 때 |
| `synthetic-data-gen` | seed 샘플 특성을 분석한 뒤, Amazon Bedrock Converse로 seed에 grounded된 instruction 데이터를 생성하고 groundedness/relevance critique로 걸러냅니다. **생성 건수를 사용자에게 물어보고**, PII·중복을 제거해 HF 데이터셋으로 저장합니다. distilabel(LiteLLM 경유 Bedrock) 대안도 안내합니다. | 파인튜닝 라벨 데이터가 부족해 증강이 필요할 때 |
| `bedrock-agentic-integration` | SageMaker endpoint에 올린 SLM을 도구(tool)로 감싸고, Amazon Bedrock Claude를 reasoning LLM으로 삼는 agentic loop 코드를 생성합니다. Strands Agents 우선, LangGraph 옵션, AgentCore Runtime 프로덕션 배포. | endpoint 위에 에이전트 루프를 올리거나 SageMaker↔Bedrock을 연동할 때 |

### 사실 검증
| skill | 하는 일 | 언제 쓰나 |
|---|---|---|
| `aws-fact-verify` | CLI 플래그·파라미터명·포트·IAM 액션·GA/preview·리전 가용성·서비스 한계 같은 AWS 사실을 문서에 넣기 **전에** docs.aws와 GitHub raw로 교차검증합니다. 오래되거나 틀린 주장을 바로잡고, confirmed/uncertain을 구분하며 "라이브 검증 YYYY-MM" 출처표를 남깁니다. | 기억에 의존한 AWS 사실을 쓰기 전, 또는 기존 문서 감사 |

## Subagents (5) — 3-lane 분리

세 lane을 분리해, 어느 lane도 자기 산출물의 사실을 스스로 승인하지 않습니다.

- **작성 lane** — `aws-solutions-architect`: 가이드·의사결정 문서·고객 답변을 하우스 스타일로 작성하고, 사실 검증은 `aws-fact-checker`에 넘깁니다.
- **코드 lane** — `aws-ml-engineer`(tier별 실습 코드), `sagemaker-finetune-engineer`(E2E 파인튜닝 에셋), `agentic-integration-engineer`(Strands/LangGraph/AgentCore 연동). 셋 다 공식 예제에 근거하고 cleanup·플레이스홀더를 지키며, 빠르게 바뀌는 API는 검증에 위임합니다.
- **검증 lane** — `aws-fact-checker`(read-only): AWS 주장을 적대적으로 재검증하고 confirmed/partially-correct/refuted/uncertain으로 판정 + 정정문 + 출처 URL을 냅니다.

## Rules (6) — `rules/`

산출물 전반에 항상 적용되는 규칙 파일입니다.
- `aws-authoring` — AWS 산출물 작성 규칙(라우팅·tier 오귀속 금지·출처 부착·가이드 3요소)
- `aws-handson-testing` — 실습 코드 테스트 사다리(GPU/CPU/SageMaker/Docker/endpoint/agentic) + CloudWatch 링크
- `sagemaker-e2e` — E2E 파인튜닝 불변 규칙(endpoint↔Bedrock 분리·JumpStart vs HF DLC·라이선스·합성데이터·cleanup)
- `code-style` — 코드 스타일(주변 코드 닮기·작은 diff·노트북은 초심자 친화)
- `communication` — 어조·언어(한국어 우선·용어는 영어·과장 금지·존댓말)
- `fact-integrity` — 사실/인용 무결성(추측을 confirmed로 쓰지 않기·1차 소스·검증 위임)

## 설치

```
/plugin marketplace add <owner>/claude-ml-plugins
/plugin install aws-sagemaker-toolkit@daekeun-ml-plugins
```

설치 없이 한 세션만 로컬 테스트:
```
claude --plugin-dir ./plugins/aws-sagemaker-toolkit
```

## ⚠️ 규칙(rules) 로딩 — 중요

Claude Code 플러그인은 `CLAUDE.md`나 `@import`를 **자동으로 로드하지 않습니다.** 그래서 이 플러그인은 규칙을 두 방식으로 제공합니다.

1. **SessionStart 훅 (자동)** — 핵심 불변 규칙(라우팅·tier 오귀속 금지·사실·cleanup)을 세션이 시작될 때 자동으로 주입합니다. 설치만 하면 동작합니다.
2. **전체 규칙 파일 (선택, 항상 로드)** — 규칙 전문이 `rules/*.md`에 들어 있습니다. 항상 로드되길 원하시면, 본인 `~/.claude/CLAUDE.md`의 (OMC 등 관리 블록 **바깥**) 위치에 아래처럼 추가하세요.

   ```
   @<플러그인 설치 경로>/rules/aws-authoring.md
   @<플러그인 설치 경로>/rules/aws-handson-testing.md
   @<플러그인 설치 경로>/rules/code-style.md
   @<플러그인 설치 경로>/rules/communication.md
   @<플러그인 설치 경로>/rules/fact-integrity.md
   @<플러그인 설치 경로>/rules/sagemaker-e2e.md
   ```
   (또는 규칙 파일을 `~/.claude/rules/`로 복사한 뒤 상대경로 `@rules/...`로 import해도 됩니다.)

## 사실 검증 스냅샷이란?

이 플러그인의 스킬들은 AWS 사양을 **기억이 아니라 공식 문서에서 확인한 사실**에 근거해 코드·가이드를 만듭니다. 그 근거를 특정 시점에 검증해 파일로 박제해 둔 것이 "사실 검증 스냅샷"입니다.

- **어디에**: `skills/aws-compute-platform-selector/verified-facts-2026-07.md`, `skills/sagemaker-e2e-finetune/verified-facts-2026-07.md`, 그리고 링크 모음 `skills/aws-compute-platform-selector/aws-reference-links.md`.
- **무엇이 들어있나**: 예를 들어 "SageMaker endpoint와 Bedrock은 별개 서비스(`sagemaker-runtime` vs `bedrock-runtime`)", "Serverless 추론엔 GPU가 없음", "JumpStart 파인튜닝 API 시그니처", "Bedrock Claude는 inference-profile prefix 필요" 같은 검증된 사실 7개와, 각 사실의 **출처 URL**이 담겨 있습니다.
- **어떻게 검증했나**: `docs.aws.amazon.com` + 공식 GitHub raw를 교차 확인하고, "이게 정말 맞나"를 적대적으로 반증해 통과한 것만 남겼습니다(2026-07 기준 7/7 confirmed).
- **⚠️ 표시의 의미**: 리전·GA 여부·모델 ID처럼 빠르게 바뀌는 값입니다. **배포·실행 전에 `aws-fact-verify`로 반드시 재확인**하세요. 정적으로 하드코딩하지 마세요.

## 외부 의존성

- `aws-slide-deck`은 PPTX 생성 엔진인 별도 `myslide` 스킬을 호출합니다. 이 플러그인엔 포함돼 있지 않으므로, 슬라이드 기능을 쓰려면 `myslide`를 따로 설치해야 합니다.
- `bedrock-agentic-integration` / `synthetic-data-gen`은 Strands/LangGraph/AgentCore, distilabel 같은 외부 SDK를 다룹니다. 코드를 **생성**하는 스킬이며, 실제 실행에는 해당 SDK와 AWS 자격증명이 필요하고 모델 호출·endpoint 과금이 발생합니다.

## 라이선스
MIT
