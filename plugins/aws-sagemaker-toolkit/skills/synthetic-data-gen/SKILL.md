---
name: synthetic-data-gen
description: Generate grounded synthetic fine-tuning data from seed samples. Analyzes seed characteristics (via the huggingface-datasets Dataset Viewer), then generates instruction data grounded in the seeds using Amazon Bedrock Converse (bedrock-runtime) with a critique/refine loop (groundedness + relevance), asks the user how many examples to generate, filters PII/duplicates, and saves to a Hugging Face dataset. Notes distilabel (SelfInstruct/EvolInstruct/Magpie) as an open alternative — via LiteLLM for Bedrock, not native. Use when a fine-tuning task lacks enough labeled data and synthetic augmentation is needed.
allowed-tools: Read, Write, Edit, Bash, WebFetch, WebSearch, Skill
argument-hint: "<seed dataset/path> <task> [count]"
triggers: ["합성 데이터", "synthetic data", "데이터 증강", "데이터 생성", "seed 데이터", "데이터 합성", "synthetic 데이터셋"]
level: 2
---

# Synthetic Data Gen — seed 기반 grounded 합성 데이터

파인튜닝용 데이터가 부족할 때 seed 샘플에 **grounded된** 합성 데이터를 생성하는 코드/노트북을 만든다.
보통 `sagemaker-e2e-finetune` 게이트4에서 호출된다.

## When to Activate
- 파인튜닝 데이터가 적어 증강이 필요할 때, "합성 데이터 만들어줘".
- seed 예시는 있고 이를 확장/변형해 instruction 데이터를 늘리고 싶을 때.

## The Insight
좋은 합성 데이터의 핵심은 양이 아니라 **grounded**(seed 근거) + **품질 critique**다.
근거 없는 생성은 hallucination·분포 이탈을 낳으므로, seed 특성을 먼저 분석하고 생성물을 critique로 거른다.

## The Approach
1. **seed 특성 분석** — `huggingface-datasets`(Dataset Viewer API)로 스키마·행 통계·라벨 분포·길이·언어 파악. 로컬 seed면 직접 로드.
2. **생성 건수 질문**(`AskUserQuestion`) — 몇 건? 라벨/서브태스크별 배분? (사용자가 정하게.)
3. **grounded 생성** — Amazon Bedrock **Converse**(`bedrock-runtime` `converse`)로 seed chunk를 근거로 instruction/response 생성. 모델은 inference-profile prefix(예 `us.anthropic.claude-...`) — **모델ID는 파라미터/env, 하드코딩 금지**.
4. **critique/refine** — 생성물을 groundedness(seed 근거 여부)·relevance·정답성으로 재평가(LLM critique) → 미달은 폐기/재생성.
5. **필터** — PII·중복(near-dup)·라벨 누수 제거. seed **라이선스 상속** 확인.
6. **저장** — HF dataset(`hf`) 또는 로컬 JSONL(학습 포맷: SFT messages / prompt-completion). `dataset_inspector`로 학습 포맷 검증.

## 대안: distilabel (오픈)
- `distilabel`의 `SelfInstruct`/`EvolInstruct`(+ EvolComplexity/Quality)/`Magpie` task로 파이프라인 구성 가능.
- ⚠️ **Bedrock 네이티브 클래스 없음 → LiteLLM 경유**. "distilabel이 Bedrock 네이티브 지원" ❌. API 시그니처 불안정 → pin 버전, 미검증 `# TODO verify`.

## 코드 규약 (aws-ml-lab-code 상속)
상단 TL;DR→Pain→Why → 설치(pin) → 설정(region/모델ID **플레이스홀더**) → seed 로드/분석 → 생성 건수 → 생성 루프(Converse) → critique 필터 → 저장 → (Bedrock 호출) **비용 요약 + 정리**. 시크릿 하드코딩 금지.

## Gotchas
- **grounded 강제** — seed 근거 없는 자유생성 금지. critique로 groundedness 검증.
- **생성 건수는 사용자 확인** — 임의 대량 생성 금지(비용·품질).
- **PII·중복·라벨 누수 필터**, seed **라이선스 상속**.
- **모델ID 하드코딩 금지**(inference-profile prefix, 파라미터화). Bedrock 호출 **비용 가드**.
- distilabel Bedrock은 LiteLLM 경유 — 네이티브 아님. 불안정 API 검증 위임(`aws-fact-checker`).

## Example
```
seed=고객문의 200건(분류), task=분류, 목표 2000건
→ huggingface-datasets로 라벨 분포·길이 분석 → "2000건, 라벨 비례?" 확인
  → Bedrock Converse로 라벨별 grounded 생성 → groundedness critique 필터 → 중복 제거
  → JSONL 저장 + dataset_inspector 검증 → 비용 요약
```

## Related
- `sagemaker-e2e-finetune` — 이 스킬을 게이트4에서 호출.
- `huggingface-datasets` — seed 통계 분석.
- `sagemaker-finetune-lab` — 생성된 데이터로 학습.
- `aws-fact-checker` / `aws-fact-verify` — Bedrock Converse·distilabel API 검증.
- 사실 근거: `sagemaker-e2e-finetune/verified-facts-2026-07.md`.
