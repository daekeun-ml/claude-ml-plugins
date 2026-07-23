# SageMaker E2E 파인튜닝 — 사실 라이브 검증 스냅샷 (2026-07)

> `sagemaker-e2e-finetune` / `sagemaker-finetune-lab` / `synthetic-data-gen` /
> `bedrock-agentic-integration` 에셋 작성 시 근거. 검증: docs.aws + 공식 GitHub raw + HF API/raw config.json 교차 + 적대적 refute.
> §1–7 = SageMaker/Bedrock/agentic 기반(7/7 confirmed). §8–9 = Gemma 모델 패밀리·서빙 컨테이너(2026-07-21 실측).
> §10–11 = SDK v3 배포 모드(ModelBuilder `mode`)·managed 평가(evaluator 3종), sagemaker 3.16.0 introspect(2026-07-23).
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

## 8. Gemma 모델 패밀리 — 세대·모달리티·라이선스 (모델 선택 시 필수)
> 라이브 검증 2026-07-21 (HF API + raw config.json 무인증 취득 + 적대적 refute). ⚠️ 로스터·gating은 분기마다 변동 → 배포 전 모델카드 재확인.
- **"4b"는 크기지 세대가 아니다.** `google/gemma-3-4b-it` = Gemma **3** 세대의 4B. `gemma-4-*` = 별개의 최신 세대. 혼동 금지("gemma-4"를 gemma-3 오타로 취급 ❌).
- **Gemma 3 모달리티**: 270m·1b = **텍스트 전용**(`Gemma3ForCausalLM`, `model_type gemma3_text`). **4b·12b·27b = 멀티모달**(text+vision, `Gemma3ForConditionalGeneration`). 전부 커스텀 `gemma` 라이선스 + **GATED**(HF 토큰+약관).
- **Gemma 4 모달리티**: **전 사이즈 멀티모달, 텍스트 전용 변종 없음.** apache-2.0 + **UNGATED**(토큰 불필요).
  - 사이즈/아키텍처: **E2B·E4B**(effective 2.3B·4.5B, PLE 임베딩; `Gemma4ForConditionalGeneration`/`gemma4`; vision+**audio**) · **12B**(dense 11.95B; `Gemma4UnifiedForConditionalGeneration`/`gemma4_unified`; vision+audio) · **26B-A4B**(MoE total 25.2B/active 3.8B, 128 experts; `Gemma4ForConditionalGeneration`/`gemma4`; vision만, **audio 없음**) · **31B**(dense; `gemma4`; vision만).
  - "**E**"=effective(PLE, MoE 아님), "**A4B**"=active 4B(MoE). transformers 요구: E계열/26B/31B **≥5.5.0**, 12B(unified) **≥5.10.0**.
- 🔴 **멀티모달 base를 텍스트로 파인튜닝→서빙 시 함정**: `AutoModelForCausalLM.from_pretrained`는 vision tower를 **버리지 않고** 멀티모달 모델(`*ForConditionalGeneration`)을 로드한다(transformers 매핑). model+tokenizer만 저장하고 `preprocessor_config.json`을 빠뜨리면, 서빙 시 vLLM이 멀티모달 경로로 로드→`OSError: Can't load image processor`로 죽는다.
  - **견고한 해법(권장)**: 머지 후 **language submodule만 텍스트 arch로 재-export**(config `architectures=["Gemma{3,4}ForCausalLM"]`, `model_type gemma{3,4}_text`) → vLLM이 순수 텍스트 경로로 라우팅(vision/audio tower·image processor 불필요). weight prefix `model.language_model.*`→`model.*` 재키잉이 핵심.
  - **즉시 언블록(footgun)**: vLLM `--language-model-only`(= 모든 mm 모달리티 limit 0). LMI env `OPTION_LIMIT_MM_PER_PROMPT`(E2B/E4B/12B는 audio도 있으니 `{"image":0,"audio":0}`, 26B/31B는 `{"image":0}`). 기본값이 0이 아니므로 명시 필수. vision tower는 여전히 VRAM에 로드되고, env 누락 재배포 시 재발.
- 순수 텍스트 태스크(추출/분류/요약/QA)면 텍스트 전용 base가 정석이나, 텍스트 전용 Gemma는 gemma-3 **1b/270m**뿐(gated). ungated가 필요하면 gemma-4(전부 멀티모달)를 위 재-export로 텍스트 서빙.

## 9. 서빙 컨테이너 — vLLM DLC vs DJL LMI (버전이 모델 지원을 좌우)
> AWS available_images(aws.github.io/deep-learning-containers) + vLLM/transformers 소스 교차, 2026-07-21.
- AWS는 **독립 vLLM DLC**를 제공: `763104351884.dkr.ecr.<region>.amazonaws.com/vllm:0.25.1-gpu-py312-cu130-ubuntu22.04-sagemaker`(및 `-ec2`). 최신 vLLM(현행 0.25.1). OpenAI 호환 서버.
- **DJL LMI**(`djl-inference`)는 내부에 vLLM을 번들 — 태그마다 vLLM 버전이 다르다. 최신 LMI(예 27.0.0)=vLLM 0.23.1. 구 **LMI 0.36.0**(=`0.36.0-lmi26.0.0-cu130`)은 더 낮은 vLLM(0.19 미만)이라 gemma-4 미지원.
- 🔴 **모델 지원 = 번들 vLLM 버전 문제.** gemma-4 서빙엔 **vLLM ≥ 0.19** 필요(gemma-4 arch가 vLLM registry에 그때 추가됨). 따라서 gemma-4는 vLLM DLC 0.25.1 또는 vLLM≥0.19 번들 LMI에서만. ⚠️ 컨테이너 태그별 번들 vLLM/transformers 버전은 available_images에서 배포 직전 재확인.
- **저장 레이아웃**: 서빙 컨테이너는 `HF_MODEL_ID=/opt/ml/model`(tar.gz 루트)에서 `config.json`으로 엔진을 감지. 🔴 **머지 모델을 루트에** 저장(어댑터는 하위 `adapter/`). 루트에 `adapter_config.json`만 있으면 "Failed to detect engine of the model"로 죽는다.
- ⚠️ SageMaker Python SDK `image_uris.retrieve(framework="djl-lmi", ...)`가 아는 최신 태그는 SDK 버전에 매임 → 최신 컨테이너는 `LMI_IMAGE_URI`/완전 URI로 직접 지정하고 available_images로 태그 재확인.

## 10. 배포 모드 3계층 — ModelBuilder `mode` (SDK v3, 로컬→클라우드)
> introspect 검증(sagemaker 3.16.0), 2026-07-23. `sagemaker.serve.mode.function_pointers.Mode`.
- `ModelBuilder(..., mode=Mode.X)` (또는 `build(mode=)`)로 **같은 코드가 3개 대상**에 배포된다. `deploy()`가 아니라 **생성자/build**에 mode를 준다(실측). 기본값 `SAGEMAKER_ENDPOINT`.
  - `Mode.IN_PROCESS` — 현재 파이썬 프로세스에서 서빙(초경량 로직 검증). 🔴 **생성형 LLM 미지원**(아래 함정).
  - `Mode.LOCAL_CONTAINER` — 로컬 Docker 컨테이너(endpoint와 동일 컨테이너 재현). 로컬 Docker+GPU 필요.
  - `Mode.SAGEMAKER_ENDPOINT` — 실제 클라우드 endpoint(과금).
- 🔴 **IN_PROCESS 함정(실측 refute)**: `InProcessServer`는 `model=<HF id 문자열>`을 `transformers.pipeline` 또는 `SentenceTransformer`(임베딩)로만 로드 시도(sagemaker/serve/model_server/in_process_model_server/app.py). 즉 **분류·임베딩 등 경량 모델 전용**. 생성형 멀티모달 LLM(gemma-4)은 pipeline이 `AnyToAnyPipeline`으로 잡혀 `librosa` 요구→실패, SentenceTransformer 폴백도 실패(`UnboundLocalError`). LLM을 IN_PROCESS로 띄우려면 `InferenceSpec`(load/invoke) 직접 구현 필요(사실상 엔진 재구현). → **SLM/LLM 로컬 검증은 IN_PROCESS 말고 `LOCAL_CONTAINER` 또는 `vllm serve` 직접**.
  - 또한 IN_PROCESS도 `ModelBuilder.__post_init__`이 `role_arn`을 해석하므로(IAM user면 `RoleValidationError`) 로컬 실행이라도 `role_arn=`을 넘겨야 한다.
- 권장 흐름: 경량 모델은 IN_PROCESS, **LLM/SLM은 LOCAL_CONTAINER**로 먼저 검증 → mode만 SAGEMAKER_ENDPOINT로 바꿔 배포. `vllm serve` 직접 실행(서빙 엔진 자체 검증)과는 목적이 다르다(mode는 배포 API 동일성 검증).
- ⚠️ import 경로는 `from sagemaker.serve.mode.function_pointers import Mode` (실측). `sagemaker.serve`에 직접 `Mode` 없음. `SchemaBuilder`는 `sagemaker.serve.builder.schema_builder`.

## 11. SageMaker managed 평가 — evaluator 3종 (SDK v3 `sagemaker.train.evaluate`)
> introspect 검증(sagemaker 3.16.0), 2026-07-23. 로컬 메트릭 계산과 **별개**의 관리형 평가 잡(별도 컴퓨트·비용).
- 3종 클래스(모두 `BaseEvaluator` 상속, `.evaluate()` → execution 객체, `.wait()`/`.status`):
  - `sagemaker.train.evaluate.benchmark_evaluator.**BenchMarkEvaluator**` (⚠️ 대문자 M) — 표준 벤치. `benchmark=` enum: mmlu/mmlu_pro/bbh/gpqa/math/ifeval/mmmu/strong_reject/llm_judge. 일반 능력.
  - `...llm_as_judge_evaluator.LLMAsJudgeEvaluator` — `evaluator_model`(judge LLM) + `dataset` + `builtin_metrics`(예 Correctness/Helpfulness/Faithfulness)/`custom_metrics`. 주관적 태스크.
  - `...custom_scorer_evaluator.CustomScorerEvaluator` — `evaluator`(= `sagemaker.ai_registry.evaluator.Evaluator.create(name, function_source='scorer.py')` / BuiltInMetric / ARN) + `dataset`. 프로그램적 채점(정답 명확).
- 공통 필드: `model`(str JumpStart ID | `BaseTrainer`/`ModelTrainer` | ModelPackage ARN | S3 checkpoint), `s3_output_path`(req), `role`, `sagemaker_session`, `region`, `compute`, `evaluate_base_model`(baseline 대비), `mlflow_*`(추적).
- 트랙 매핑 권장: BenchMark=공통(일반능력) · CustomScorer=추출/분류(arg_f1·라벨) · LLMAsJudge=요약/QA(주관).
- ⚠️ 이 API는 비교적 신규 → 필드/벤치명/빌트인메트릭은 실행 전 설치 SDK docstring으로 재확인(`help(BenchMarkEvaluator)`).

## 에셋 작성 시 필수 규칙 (오귀속/사고 방지)
1. endpoint(`sagemaker-runtime`) ≠ Bedrock(`bedrock-runtime`). 2. Bedrock Claude는 inference-profile prefix, 모델ID 하드코딩 금지. 3. JumpStart vs HF DLC 경로 혼용 금지. 4. gated 모델 EULA·라이선스 전파. 5. 합성데이터 grounded + 생성 건수 사용자 확인. 6. agentic SDK(Strands/LangGraph/AgentCore) 빠른 변화 → 작성 전 검증, 미검증 `# TODO verify`. 7. 모든 에셋에 cleanup(endpoint/agent teardown) + CloudWatch 링크 + 비용 가드.
8. **모델 모달리티 먼저 확인**(§8): base가 멀티모달인지(vision/audio) 확인 없이 텍스트 파이프라인을 짜면 서빙에서 image-processor 에러로 죽는다. 텍스트 서빙은 재-export 또는 `--language-model-only`. 9. **서빙 컨테이너 버전이 모델 지원을 좌우**(§9): 최신 모델(gemma-4 등)은 vLLM 버전 요건을 available_images로 확인 후 컨테이너 선택. 10. 머지 모델은 tar.gz **루트**에 저장.
