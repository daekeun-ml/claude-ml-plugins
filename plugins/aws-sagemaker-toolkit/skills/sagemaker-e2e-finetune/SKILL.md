---
name: sagemaker-e2e-finetune
description: Orchestrate an end-to-end, production-oriented SageMaker fine-tuning asset pipeline via a gated interview (deep-interview style). Walks the user from task definition → Hugging Face open-license model/dataset candidate selection → data sizing & synthetic-data decision → (if needed) grounded synthetic data generation → SageMaker AI training (auto-branch: JumpStartEstimator for standard, HuggingFace DLC estimator for custom/latest) → endpoint hosting → optional agentic loop (SLM endpoint + Bedrock Claude via Strands, LangGraph option, AgentCore deploy). Crystallizes a spec then generates runnable notebooks/scripts by delegating to sub-skills. Use when someone wants to build an E2E SageMaker fine-tuning asset, not just a single training script.
allowed-tools: Read, Write, Edit, Bash, WebFetch, WebSearch, AskUserQuestion, Skill
argument-hint: "<유스케이스/문제 설명> [--quick|--standard]"
triggers: ["e2e 파인튜닝", "sagemaker 파인튜닝", "파인튜닝 에셋", "finetune pipeline", "end to end 파인튜닝", "슬램 파인튜닝", "slm 파인튜닝", "커스텀 모델 학습", "파인튜닝 파이프라인", "e2e finetune"]
level: 3
---

# SageMaker E2E Fine-tune — 인터뷰→에셋 제너레이터 (오케스트레이터)

문제 정의부터 학습·배포·(선택)agentic까지 **production-ready로 빠르게 가는 실용 에셋**(노트북/스크립트)을
인터뷰로 스펙을 확정한 뒤 단계별로 생성하는 상위 스킬. 각 단계는 하위 스킬/에이전트에 위임한다.

## When to Activate
- "SageMaker로 파인튜닝 에셋/파이프라인 만들어줘", "SLM 파인튜닝 e2e" 요청.
- 단순 training 스크립트 하나가 아니라 **문제→모델→데이터→학습→배포→(agentic)** 전 과정 자산이 필요할 때.

## The Insight
좋은 파인튜닝 에셋은 코드가 아니라 **결정**에서 시작한다. 어떤 task·어떤 오픈 모델·데이터가 충분한지·합성이 필요한지·
표준(JumpStart)이냐 커스텀(HF DLC)이냐·배포/agentic 범위 — 이걸 인터뷰로 먼저 확정하면 재작업이 사라진다.
그래서 이 스킬은 **deep-interview 게이트로 스펙을 결정화한 뒤** 검증된 사실(같은 폴더 `verified-facts-2026-07.md`) 위에서 에셋을 생성한다.

## Interview Gates (deep-interview 패턴 — 한 번에 한 질문, `AskUserQuestion`)
게이트마다 답을 받아 스펙 파일 `.omc/specs/sme2e-{slug}.md`에 누적한다. 각 게이트는 하위 스킬로 위임.

1. **Task 정의** — 대표 프리셋 제시: 텍스트 분류 · 정보추출(NER/키값) · 요약 · RAG/문서-QA · 함수호출/tool-use · 도메인 챗봇 · 스타일/톤 변환. (사용자 유스케이스를 프리셋에 매핑, 성공기준 1줄.)
2. **모델·데이터셋 후보** — `hf-cli`로 **오픈 라이선스** 모델 후보 제시(task·크기·license 필터: `hf models list --search --filter --num-parameters`), 데이터셋 후보(`hf datasets list`). 라이선스(apache-2.0/llama 등)와 gated 여부 명시. 사용자가 선택. 🔴 **모달리티도 확인**(verified-facts §8): base가 멀티모달(vision/audio)인지 config로 확인 — 예 gemma-3 4b+·gemma-4 전부 멀티모달, gemma-3 1b/270m만 텍스트 전용. 멀티모달 base를 텍스트 태스크에 쓰면 서빙 시 image-processor 에러 → 텍스트 arch 재-export 또는 `--language-model-only` 필요(G6 배포에서 처리).
3. **데이터 크기 전략** — 일부 샘플(스모크) / subtask 한정 / full / **synthetic 필요 여부**. seed 데이터 위치·형식.
4. **(조건부) 합성 데이터** — synthetic 필요 시 `synthetic-data-gen` 위임: seed 특성 분석 후 **생성 건수를 사용자에게 질문**, grounded 생성 계획.
5. **학습 진입점 (자동 분기 제안)** — 분기 기준은 **task가 아니라 "G2에서 고른 모델이 현행 JumpStart fine-tunable 로스터에 있는가"** (사용자 확인):
   - **선택 모델이 JumpStart fine-tunable 로스터에 있음 + 빠른 production → JumpStart**(`JumpStartEstimator`, LoRA 하이퍼·`accept_eula`). ⚠️ 로스터는 시점 스냅샷(verified-facts) → 현행 모델 테이블 재확인. JumpStart엔 분류 전용 헤드가 없으므로 **분류도 instruction-based 텍스트생성(라벨을 텍스트로)**으로.
   - **로스터에 없거나(예: 다수 Qwen SLM)·커스텀 로직·최신 모델·TRL/PEFT 필요 → HuggingFace DLC**(`sagemaker.huggingface.HuggingFace` + `source_dir` 스크립트).
   - → `sagemaker-finetune-lab`에 위임해 학습 코드 생성.
6. **배포** — endpoint 종류(real-time/async/serverless — ⚠️ serverless 무GPU) + `invoke_endpoint` 스모크. (Bedrock으로 서빙 원하면 Custom Model Import 옵션 노트.) → `sagemaker-finetune-lab`.
7. **Agentic 여부** — 없음 / endpoint + Bedrock Converse 호출만 / + **Strands** agent / + **LangGraph** / + **AgentCore** 배포. → `bedrock-agentic-integration` 위임.

## The Approach
1. **유스케이스 파싱 + explore**(브라운필드면 기존 자산 확인). 스펙 초기화.
2. **게이트 1→7 진행** — 한 질문씩, 답마다 스펙 파일 갱신. 이미 명확한 항목은 건너뛰되 요약 확인.
3. **스펙 결정화** — `.omc/specs/sme2e-{slug}.md`: task·모델·데이터/합성·학습경로·배포·agentic·성공기준·비용가드.
4. **에셋 생성 브릿지** — 스펙을 근거로 하위 스킬/에이전트 호출:
   - 합성 → `synthetic-data-gen` · 학습·배포 → `sagemaker-finetune-lab`(또는 `sagemaker-finetune-engineer` 에이전트) · agentic → `bedrock-agentic-integration`(또는 `agentic-integration-engineer`).
5. **사실·결정 위임** — SDK/모델ID/서비스 경계 사실은 `aws-fact-checker`(에이전트) 또는 `aws-fact-verify`(스킬), 아키텍처 판단은 `aws-solutions-architect`(에이전트). 근거는 `verified-facts-2026-07.md`.

## Gotchas (반드시)
- **한 번에 한 질문** — 게이트를 한꺼번에 묶지 말 것(deep-interview 원칙). 답마다 스펙 갱신.
- **오귀속 금지**(→ `verified-facts-2026-07.md`, `[[sagemaker-e2e]]` 규칙): endpoint(`sagemaker-runtime`) ≠ Bedrock(`bedrock-runtime`) · Bedrock Claude는 inference-profile prefix, 모델ID 하드코딩 금지 · JumpStart ≠ HF DLC 혼용 · serverless 무GPU.
- **라이선스·EULA 전파** — 오픈 라이선스만 후보로, gated(예: Llama)면 `accept_eula=True` 명시.
- **합성 데이터** — grounded(seed 근거) + **생성 건수 사용자 확인** + 품질 critique.
- **모든 에셋에 cleanup + CloudWatch 링크 + 비용 가드**(→ `aws-ml-lab-code` 스킬, `[[aws-handson-testing]]` 규칙).
- **빠르게 변하는 것**(모델 로스터·Strands/AgentCore API·리전)은 작성 전 검증, 미검증 `# TODO verify`.
- **이식성** — 로컬 절대경로/시크릿 하드코딩 금지(플러그인 배포 대상). 스킬 참조는 이름 기반.

## Example
```
사용자: 한국어 고객문의 분류 SLM 파인튜닝 e2e 만들어줘, 데이터 적음
→ G1 task=텍스트 분류 → G2 hf-cli로 오픈 SLM 후보(Qwen2.5-0.5B/1.5B apache-2.0 등) 제시
  → G3 데이터 적음→synthetic 필요 → G4 synthetic-data-gen: seed 분석+"몇 건?" 질문(예 2000건) grounded 생성
  → G5 선택 모델(Qwen)이 JumpStart 로스터에 없음 → **HF DLC**(TRL SFT+LoRA, 분류=instruction-based) 추천(사용자 확인)
    → G6 real-time endpoint + invoke 스모크 → G7 endpoint+Bedrock Converse 간단 Strands agent
  → 스펙 결정화 → sagemaker-finetune-lab/synthetic-data-gen/bedrock-agentic-integration로 에셋 생성
  (모델이 Llama/Mistral 등 JumpStart 로스터에 있으면 G5는 JumpStart 경로로 분기)
```

## Reference / Related
- `verified-facts-2026-07.md`(같은 폴더) — 7개 라이브 검증 사실 + 출처.
- 하위 위임: `synthetic-data-gen` · `sagemaker-finetune-lab` · `bedrock-agentic-integration`.
- 재사용: `hf-cli`(모델/데이터셋 탐색) · `huggingface-datasets`(seed 통계) · `huggingface-llm-trainer`(TRL 스크립트 로직) · `aws-ml-lab-code`(노트북 규약) · `deep-interview`(게이트 골격).
- 위임 lane: `sagemaker-finetune-engineer` / `agentic-integration-engineer`(코드) · `aws-fact-checker`(검증) · `aws-solutions-architect`(결정).
