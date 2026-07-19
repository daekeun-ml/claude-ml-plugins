# SageMaker E2E 파인튜닝 — 사실 라이브 검증 스냅샷 (2026-07)

> `sagemaker-e2e-finetune` / `sagemaker-finetune-lab` / `synthetic-data-gen` /
> `bedrock-agentic-integration` 에셋 작성 시 근거. 검증: docs.aws + 공식 GitHub raw 교차 + 적대적 refute (7/7 confirmed).
> ⚠️ = 빠르게 바뀜 → 에셋 배포/실행 전 재검증(`aws-fact-checker`/`aws-fact-verify`). 정적 하드코딩 금지.

## 1. SageMaker JumpStart 파인튜닝 (표준 경로)
- `from sagemaker.jumpstart.estimator import JumpStartEstimator` → `JumpStartEstimator(model_id=...)` →
  `.fit({"train": s3, "validation": s3})` → `.deploy()`/predictor.
- 2방식: **domain adaptation**(CSV/JSON/TXT 도메인 텍스트) · **instruction-based**(prompt/response JSONL + 선택 `template.json`).
- **LoRA 하이퍼**: `lora_r`, `lora_alpha`, `lora_dropout` (+ `int8_quantization`, `enable_fsdp`, `instruction_tuned`).
- **gated 모델 EULA**: `estimator.fit(accept_eula=True, ...)` + `deploy(accept_eula=True)` (sagemaker≥2.198). 파인튜닝된 모델은 배포 시 재수락 불필요(가중치 변경됨).
- ⚠️ 신형 SDK가 `ModelTrainer.from_jumpstart_config` / `ModelBuilder.from_jumpstart_config`로 이행 중 — JumpStartEstimator는 여전히 유효(EULA 문서도 사용)하나 권장 진입점이 바뀔 수 있음. fine-tunable 모델 목록/ID(예: `meta-textgeneration-llama-2-13b`)는 시점 스냅샷 → 현행 모델 테이블 재확인.
- 출처: jumpstart-foundation-models-fine-tuning.html, -use-python-sdk-estimator-class.html, -fine-tuning-domain-adaptation.html, -instruction-based.html, jumpstart-fine-tune.html

## 2. HuggingFace DLC on SageMaker (커스텀/최신 경로)
- `from sagemaker.huggingface import HuggingFace` → `HuggingFace(entry_point, source_dir, hyperparameters, transformers_version, pytorch_version, py_version, instance_type, instance_count, role, ...)` (extends `Framework`) → `.fit({채널: s3})`.
- 에스티메이터가 `transformers_version`/framework/`py_version` 조합으로 **HF DLC 이미지**를 resolve(또는 `image_uri` 커스텀).
- **핵심 재사용 지점**: `entry_point`/`source_dir`가 임의 사용자 스크립트라 **TRL(`SFTTrainer`)·PEFT/LoRA·QLoRA가 DLC 안에서 그대로 실행** → `huggingface-llm-trainer` 스킬의 학습 스크립트 로직 재사용, 오케스트레이션만 SageMaker로.
- ⚠️ AWS 문서가 신형 "HuggingFace SageMaker AI ModelTrainer"로 유도(구 `HuggingFace` estimator는 미deprecated, SDK에 여전히 존재).
- 출처: sagemaker-python-sdk v2.232.0 huggingface/estimator.py(raw), dg/hugging-face.html, huggingface.co/docs/sagemaker/train, HF notebooks 24/28(raw), philschmid llama3 예제

## 3. SageMaker endpoint ↔ Bedrock = 별개 서비스 (혼동 금지)
- SageMaker endpoint 호출 = `boto3` **`sagemaker-runtime`** client `invoke_endpoint`(스트리밍 `invoke_endpoint_with_response_stream`), CLI `aws sagemaker-runtime invoke-endpoint`.
- Bedrock = 별개 fully-managed 서비스, `boto3` **`bedrock-runtime`** client. **Converse API(`converse`/`converse_stream`) 권장**(모델 통합 인터페이스), `invoke_model`도 존재.
- **다리(bridge)**: SageMaker/HF 모델을 Bedrock으로 서빙하려면 **Bedrock Custom Model Import** 또는 **Bedrock Marketplace**. ⚠️ Custom Model Import는 지원 아키텍처·리전(현재 eu-central-1, us-east-1, us-east-2, us-west-2)·transformers 버전(현재 4.51.3) 제한 → 재확인.
- 🔴 에셋에서 "SageMaker endpoint를 Bedrock API로 호출"한다고 쓰지 말 것 — 별개 클라이언트.
- 출처: realtime-endpoints-test-endpoints.html, bedrock/conversation-inference.html, what-is-bedrock.html, model-customization-import-model.html, bedrock/faqs

## 4. Bedrock Claude 호출 메커니즘 (모델ID 하드코딩 금지)
- 모델ID 형식: `anthropic.claude-<name>-<date>-v<n>:0` (base ID).
- **신형 모델은 inference profile 필수**: bare base ID로 on-demand 호출 시 HTTP 400(프로파일 쓰라고 안내). 프로파일ID = base ID에 지역/라우팅 prefix: `us.`/`eu.`/`apac.`/`jp.`(regional CRIS) 또는 `global.`(global routing). 예: `us.anthropic.claude-sonnet-4-5-20250929-v1:0`. ARN도 가능.
- ⚠️ **모델 로스터·정확한 ID는 자주 바뀜** → 정적 리스트 하드코딩 금지, **prefix 메커니즘만 인코딩**하고 ID는 런타임 파라미터/env. 실행 시 model card·model-lifecycle 페이지로 재확인.
- 출처: bedrock/conversation-inference.html + Anthropic on Bedrock 문서(모델별 model card)

## 5. Strands Agents (agentic — 기본 프레임워크)
- 오픈소스(Apache-2.0) AWS agent SDK, Python/TS. 설치 `pip install strands-agents`(+`strands-agents-tools`, py3.10+).
- 코어: `Agent` + tools(`@tool` 데코레이터 / prebuilt `strands_tools` / MCP). **model-agnostic, Bedrock이 DEFAULT 프로바이더**(기본 Claude Sonnet, AWS 자격증명 필요).
- repo=github.com/strands-agents (모노레포 `harness-sdk`가 구 `sdk-python` 대체). docs=strandsagents.com.
- ⚠️ v1.x 빠르게 진화 → org 레벨로 참조, 정확한 API는 검증.
- 출처: strandsagents.com, github.com/strands-agents

## 6. Amazon Bedrock AgentCore (프로덕션 배포)
- Bedrock의 agentic 플랫폼(프레임워크·모델 무관, 인프라 관리 불필요). 모듈: **Runtime**(세션별 microVM 격리 서버리스 호스팅) · **Memory**(단/장기) · **Gateway**(API/Lambda/OpenAPI→MCP tool) · **Identity**(Cognito/Okta/Entra/Auth0) · **Built-in Tools**(Browser + Code Interpreter) · **Observability**(OTel/CloudWatch). 추가: Harness/Evaluations/Optimization/Policy(Cedar)/Payments/Agent Registry.
- Strands·LangGraph 등으로 만든 에이전트 호스팅 가능.
- ⚠️ GA/preview 경계 유동적: AgentCore 전반 GA이나 Agent Registry·Payments·Optimization Insights·managed Harness·Runtime Managed Session Storage 등은 preview(재확인).
- 출처: bedrock-agentcore/what-is-bedrock-agentcore.html, aws.amazon.com/bedrock/agentcore(+faqs/pricing), whats-new 2025/07 preview, agentcore-regions.html, strands docs deploy_to_bedrock_agentcore(raw)

## 7. 합성 데이터 생성 (grounded)
- **Bedrock Converse**(`bedrock-runtime` `converse`, `modelId`/`messages`/`system`/`inferenceConfig`/`toolConfig`)로 seed chunk에 **grounded**된 Q/A 생성 + critique(groundedness/relevance) 정제 — AWS ML 블로그 문서화 패턴.
- 오픈 라이브러리: **distilabel**(HF/Argilla) `SelfInstruct`/`EvolInstruct`/`EvolComplexity`/`EvolQuality`/`Magpie`. ⚠️ **Bedrock 네이티브 클래스 없음 → LiteLLM 경유**. "distilabel이 Bedrock 네이티브 지원" ❌.
- ⚠️ 라이브러리 API 시그니처 불안정 → 하드코딩 금지, pin 버전 재확인.
- seed 통계 분석은 `huggingface-datasets` 스킬(Dataset Viewer API) 활용.

## 에셋 작성 시 필수 규칙 (오귀속/사고 방지)
1. endpoint(`sagemaker-runtime`) ≠ Bedrock(`bedrock-runtime`). 2. Bedrock Claude는 inference-profile prefix, 모델ID 하드코딩 금지. 3. JumpStart vs HF DLC 경로 혼용 금지. 4. gated 모델 EULA·라이선스 전파. 5. 합성데이터 grounded + 생성 건수 사용자 확인. 6. agentic SDK(Strands/LangGraph/AgentCore) 빠른 변화 → 작성 전 검증, 미검증 `# TODO verify`. 7. 모든 에셋에 cleanup(endpoint/agent teardown) + CloudWatch 링크 + 비용 가드.
