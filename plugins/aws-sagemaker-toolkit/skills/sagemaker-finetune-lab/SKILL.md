---
name: sagemaker-finetune-lab
description: Generate runnable SageMaker AI fine-tuning → endpoint code (Python scripts + JupyterLab notebooks) for two documented paths — JumpStart (JumpStartEstimator.fit/deploy with LoRA hyperparameters and accept_eula for gated models) and HuggingFace DLC (sagemaker.huggingface.HuggingFace estimator with a TRL/PEFT source_dir training script). Inherits the aws-ml-lab-code conventions (placeholders not secrets, mandatory cleanup cell, CloudWatch direct links, TL;DR/Why/Pain header) and reuses huggingface-llm-trainer TRL script logic. Use when the training→deploy code for a fine-tuning asset needs to be produced for a specific SageMaker path.
allowed-tools: Read, Write, Edit, Bash, WebFetch, WebSearch, Skill
argument-hint: "<jumpstart|hf-dlc> <model/task> [endpoint type]"
triggers: ["파인튜닝 코드", "training 노트북", "sagemaker training", "jumpstart 파인튜닝", "hf dlc", "estimator", "sagemaker 학습 코드", "endpoint 배포 코드"]
level: 2
---

# SageMaker Finetune Lab — 학습→배포 코드 제너레이터

스펙(경로·모델·데이터)을 받아 **실행 가능한 training→endpoint 노트북/스크립트**를 생성. `aws-ml-lab-code` 규약 상속.
보통 `sagemaker-e2e-finetune` 오케스트레이터가 호출하지만, 단독으로도 특정 경로 코드 생성에 쓸 수 있다.

## When to Activate
- "이 모델 SageMaker로 파인튜닝하는 코드/노트북 만들어줘"(JumpStart 또는 HF DLC).
- E2E 파이프라인의 학습·배포 단계 에셋이 필요할 때.

## The Insight
SageMaker 파인튜닝엔 문서화된 **두 경로**가 있고 관용구가 다르다 — 섞으면 안 된다.
JumpStart = 표준·최소코드·빠른 production. HF DLC = 커스텀 스크립트(TRL/PEFT)·최신 모델·최대 유연성.
학습 스크립트 *로직*은 HF 생태계(huggingface-llm-trainer)에서 재사용하되, **오케스트레이션은 SageMaker**로 바꾼다.

## 두 경로 (혼용 금지 — 근거: sagemaker-e2e-finetune/verified-facts-2026-07.md)
### JumpStart 경로 (표준·빠름)
```python
from sagemaker.jumpstart.estimator import JumpStartEstimator
est = JumpStartEstimator(model_id="<jumpstart-model-id>", environment={"accept_eula": "true"})  # gated면
est.set_hyperparameters(instruction_tuned="True", epoch="3", lora_r="8", lora_alpha="16", lora_dropout="0.05")
est.fit({"train": "s3://.../train", "validation": "s3://.../val"})  # gated면 accept_eula=True
predictor = est.deploy()  # 배포
```
- instruction-based(JSONL prompt/response + 선택 template.json) 또는 domain adaptation(CSV/JSON/TXT).
- gated 모델(예: Llama): `accept_eula=True`(sagemaker≥2.198).

### HF DLC 경로 (커스텀·최신 — TRL/PEFT)
```python
from sagemaker.huggingface import HuggingFace
hf = HuggingFace(
    entry_point="train.py", source_dir="scripts",   # ← TRL/PEFT 스크립트(huggingface-llm-trainer 로직 재사용)
    instance_type="ml.g5.2xlarge", instance_count=1, role="<YOUR_ROLE_ARN>",
    transformers_version="<ver>", pytorch_version="<ver>", py_version="py310",
    hyperparameters={"model_id": "<hf-model>", "num_train_epochs": 3, "lora_r": 8},
)
hf.fit({"train": "s3://.../train", "test": "s3://.../test"})
```
- `scripts/train.py`는 `SFTTrainer`+`LoraConfig`(또는 QLoRA) — `huggingface-llm-trainer` 스킬의 스크립트 패턴을 SageMaker entry_point로 이식(단 `hf_jobs`가 아니라 `.fit()`).
- 학습 데이터 포맷은 `dataset_inspector`(huggingface-llm-trainer) 재사용으로 사전 검증.

## 배포 (endpoint)
- real-time(GPU·상시) / async(대용량·큐잉) / serverless(**⚠️ GPU 없음** — LLM/SLM 서빙 부적합, real-time 사용).
- 배포 직후 `sagemaker-runtime invoke_endpoint` 스모크 셀 + **CloudWatch 다이렉트 링크**(`[[aws-handson-testing]]` 규칙의 `cw_links` 관용구 — 스킬 아님, 전역 로드 규칙).
- (선택) Bedrock으로 서빙하려면 **Bedrock Custom Model Import**(⚠️ 리전·아키텍처·transformers 버전 제한, 재확인) 노트만.

## 노트북 규약 (aws-ml-lab-code 상속)
상단 markdown 셀 **TL;DR → Pain → Why** → 설치(pin) → 설정(role/region/bucket **플레이스홀더**) → 데이터(+inspector 검증) → 학습(.fit) → **CloudWatch 링크 셀** → 배포+invoke 스모크 → **🔴 cleanup 셀**(`predictor.delete_endpoint()`, `sagemaker.delete_model()` — 안 하면 과금 지속).

## Gotchas
- **경로 혼용 금지**: JumpStart 코드에 HF estimator 섞지 말 것, 반대도.
- **시크릿·경로 하드코딩 금지**(플레이스홀더/env). **cleanup 필수**(endpoint 과금).
- **serverless 무GPU** — SLM/LLM은 real-time.
- **모델ID·SDK 버전·transformers_version 재확인** — 미검증은 `# TODO verify`, 사실은 `aws-fact-checker`.
- **gated 라이선스 EULA** 명시. 이식성(로컬 절대경로 금지).

## Example
```
스펙: HF DLC, Qwen2.5-1.5B, SFT+LoRA, 분류, real-time endpoint
→ scripts/train.py(SFTTrainer+LoraConfig) + HuggingFace estimator 노트북
  → dataset_inspector로 포맷 검증 → .fit() → CloudWatch 링크 → deploy → invoke 스모크 → cleanup
```

## Related
- `sagemaker-e2e-finetune` — 이 스킬을 호출하는 오케스트레이터.
- `aws-ml-lab-code` — 노트북 규약(cleanup·CloudWatch·플레이스홀더) 상속원.
- `huggingface-llm-trainer` — TRL/PEFT 학습 스크립트 로직 재사용원(오케스트레이션만 SageMaker로).
- `sagemaker-deep-dive` — Training Jobs/endpoint 개념 배경.
- `aws-fact-checker` / `aws-fact-verify` — SDK/모델ID/버전 검증.
- 사실 근거: `sagemaker-e2e-finetune/verified-facts-2026-07.md`.
