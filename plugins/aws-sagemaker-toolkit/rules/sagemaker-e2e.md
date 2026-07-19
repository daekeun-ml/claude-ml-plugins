# SageMaker E2E Fine-tune Rules

SageMaker E2E 파인튜닝 에셋(인터뷰·학습·배포·합성데이터·agentic)을 만들 때 항상 적용.
(코드 스타일 [[code-style]], 테스트/CloudWatch [[aws-handson-testing]], 작성 [[aws-authoring]], 사실 [[fact-integrity]].)

**라우팅** — 오케스트레이션(인터뷰→에셋) → `sagemaker-e2e-finetune`(level3) 스킬. 학습·배포 코드 → `sagemaker-finetune-lab` / `sagemaker-finetune-engineer` 에이전트. 합성데이터 → `synthetic-data-gen`. agentic → `bedrock-agentic-integration` / `agentic-integration-engineer`. 사실검증 → `aws-fact-checker`, 결정 → `aws-solutions-architect`. 자기 코드 자기승인 금지.

**서비스 경계 (오귀속 금지)** — SageMaker endpoint는 `boto3 sagemaker-runtime` `invoke_endpoint`, Amazon Bedrock은 `bedrock-runtime` **Converse**. **별개 클라이언트** — endpoint를 Bedrock API로 호출한다고 쓰지 말 것. SageMaker 모델을 Bedrock으로 서빙하려면 Custom Model Import/Marketplace(리전·아키텍처 제한 재확인).

**Bedrock Claude 호출** — 모델ID는 **inference-profile prefix**(`us.`/`eu.`/`apac.`/`jp.`/`global.`) 필요, bare ID는 HTTP400. 모델 로스터·ID **정적 하드코딩 금지** → 파라미터/env, 실행 시 재확인.

**학습 경로 (혼용 금지)** — 표준·지원 모델·빠른 production → **JumpStart**(`JumpStartEstimator`, LoRA 하이퍼, gated면 `accept_eula=True`). 커스텀 로직·최신 모델·TRL/PEFT → **HuggingFace DLC**(`sagemaker.huggingface.HuggingFace` + `source_dir` 스크립트). 두 관용구를 한 에셋에 섞지 말 것. TRL 스크립트 로직은 재사용하되 오케스트레이션은 SageMaker `.fit()`(HF `hf_jobs` 아님).

**모델·데이터 라이선스** — 후보는 **오픈 라이선스**만. gated(Llama 등)는 EULA 수락 명시·라이선스 전파. 데이터셋 라이선스도 합성/파생물에 상속.

**합성 데이터** — seed에 **grounded** 강제 + 품질 critique(groundedness/relevance) + PII/중복 필터. **생성 건수는 사용자에게 확인**. Bedrock Converse 기반; distilabel은 LiteLLM 경유(네이티브 아님).

**agentic SDK** — Strands(기본)·LangGraph(옵션)·AgentCore(배포)는 빠르게 변함 → **작성 전 문서 검증**(aws-fact-checker), 미검증 API `# TODO verify`. AgentCore 일부 컴포넌트 preview — 리전·GA 재확인.

**모든 에셋 공통** — endpoint 종류 중 **serverless는 GPU 없음**(SLM/LLM은 real-time). 모든 에셋에 **cleanup 셀**(endpoint/model/agent teardown, 과금 경고) + **CloudWatch 다이렉트 링크** + **비용 가드**. 시크릿·로컬 절대경로 하드코딩 금지(플러그인 이식성). 노트북은 초심자 친화(한국어 markdown), 스크립트는 정확·직관.

**사실 근거** — `sagemaker-e2e-finetune` 스킬 폴더의 `verified-facts-2026-07.md`(라이브 검증 7개 + 출처). ⚠️ 항목은 배포/실행 전 재검증.
