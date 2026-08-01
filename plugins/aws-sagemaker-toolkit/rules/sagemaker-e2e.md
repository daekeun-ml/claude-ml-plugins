# SageMaker E2E Fine-tune Rules

SageMaker E2E 파인튜닝 에셋(인터뷰·학습·배포·합성데이터·agentic)을 만들 때 항상 적용.
(코드 스타일 [[code-style]], 테스트/CloudWatch [[aws-handson-testing]], 작성 [[aws-authoring]], 사실 [[fact-integrity]].)

**라우팅** — 오케스트레이션(인터뷰→에셋) → `sagemaker-e2e-finetune`(level3) 스킬. 학습·배포 코드 → `sagemaker-finetune-lab` / `sagemaker-finetune-engineer` 에이전트. 합성데이터 → `synthetic-data-gen`. agentic → `bedrock-agentic-integration` / `agentic-integration-engineer`. 사실검증 → `aws-fact-checker`, 결정 → `aws-solutions-architect`. 자기 코드 자기승인 금지.

**서비스 경계 (오귀속 금지)** — SageMaker endpoint는 `boto3 sagemaker-runtime` `invoke_endpoint`, Amazon Bedrock은 `bedrock-runtime` **Converse**. **별개 클라이언트** — endpoint를 Bedrock API로 호출한다고 쓰지 말 것. SageMaker 모델을 Bedrock으로 서빙하려면 Custom Model Import/Marketplace(리전·아키텍처 제한 재확인).

**Bedrock Claude 호출** — 모델ID는 **inference-profile prefix**(`us.`/`eu.`/`apac.`/`jp.`/`global.`) 필요, bare ID는 HTTP400. 모델 로스터·ID **정적 하드코딩 금지** → 파라미터/env, 실행 시 재확인.

**학습 경로 (혼용 금지)** — 표준·지원 모델·빠른 production → **JumpStart**(`JumpStartEstimator`, LoRA 하이퍼, gated면 `accept_eula=True`). 커스텀 로직·최신 모델·TRL/PEFT → **HuggingFace DLC**(`sagemaker.huggingface.HuggingFace` + `source_dir` 스크립트). 두 관용구를 한 에셋에 섞지 말 것. TRL 스크립트 로직은 재사용하되 오케스트레이션은 SageMaker `.fit()`(HF `hf_jobs` 아님).

**SDK·엔진의 침묵 기본값 (명시적으로 덮어쓸 것)** — 생략하면 SDK가 조용히 값을 넣고, 그 값이 실습 규모에 안 맞아 실패한다. 실측으로 확인된 것들:
- `StoppingCondition` 생략 → SageMaker Python SDK가 **3600초**를 넣는다(`DEFAULT_MAX_RUNTIME_IN_SECONDS`). Pending+Download+Training+머지/업로드를 모두 덮는 창이라, 학습을 마친 잡이 **머지 도중** 죽는다. `FailureReason`은 비고 status는 `Stopped`/`MaxRuntimeExceeded`, SIGTERM 120초 유예 때문에 **불완전한 아티팩트가 남아** 성공처럼 보인다.
- vLLM `max_num_seqs` 기본 **256** → vocab이 큰 모델(예: 262,144)에서 샘플러 버퍼가 `256 × vocab × 4B`가 되어 24GB 카드에서 CUDA OOM. 실습은 32 수준으로 내린다. **인스턴스를 키우기 전에 이 값을 먼저 본다.**
- `gpu_memory_utilization`은 **문자열로** 넘긴다 — `str(0.90)`은 `"0.9"`가 되어 컨테이너에 다른 값이 간다.
- OpenAI 호환(`messages`) 스키마의 길이 제한은 **`max_tokens`**. `max_new_tokens`는 `{inputs,parameters}` 스키마의 키이고, vLLM은 모르는 키를 **조용히 무시**해 제한이 아예 적용되지 않는다.
- 생성 결과가 잘렸는지는 **`finish_reason == 'length'`** 로만 알 수 있다(예외 없음, HTTP 200).
- 서빙 env 키는 엔진마다 다르다 → 손으로 `SM_VLLM_*`을 쓰지 말고 **단일 헬퍼**에서 조립한다(엔진 전환 시 누락이 조용한 버그가 된다).
- `load_dataset(..., streaming=True)`는 **디스크 캐시를 하지 않아** 매 호출 재다운로드한다. 반복 실행되는 셀/스테이지에서는 `split="train[:n]"` 슬라이스를 쓴다.

**진입점 이원화 (노트북 + 스크립트)** — 같은 파이프라인을 둘로 제공할 때:
- **상태 전달**: `%store`는 IPython 전용이고 **전역**이다 — 작업이 여러 개면 서로 오염된다(A 노트북이 B의 endpoint를 부르는 사고). 스크립트 경로는 **작업별 JSON 파일**로 넘기고, 산출물이 이미 있으면 스킵(`--force`로 재실행).
- **설정/시크릿 분리**: 설정은 커밋되는 config 파일(YAML — 값의 *이유*를 주석으로 남길 수 있다), 시크릿(토큰·role ARN·region)은 env. 로더는 config에서 시크릿 키를 발견하면 **경고하고 무시**한다. 우선순위(env > config > 기본값)를 파일 안에 적는다.
- **두 경로가 갈라지지 않게 검증**: 하이퍼파라미터·`StoppingCondition`·서빙 env·인스턴스 타입이 같은 값으로 해석되는지 확인한다. 갈라지면 하나는 틀린 것이다. 공통 레이어를 재사용하고 진입점은 얇게 유지.
- 대화형 탐색이 본질인 단계(agentic 루프 등)는 스크립트로 옮기지 않는다 — 스크립트 가치가 낮다.

**모델·데이터 라이선스** — 후보는 **오픈 라이선스**만. gated(Llama 등)는 EULA 수락 명시·라이선스 전파. 데이터셋 라이선스도 합성/파생물에 상속.

**합성 데이터** — seed에 **grounded** 강제 + 품질 critique(groundedness/relevance) + PII/중복 필터. **생성 건수는 사용자에게 확인**. Bedrock Converse 기반; distilabel은 LiteLLM 경유(네이티브 아님).

**agentic SDK** — Strands(기본)·LangGraph(옵션)·AgentCore(배포)는 빠르게 변함 → **작성 전 문서 검증**(aws-fact-checker), 미검증 API `# TODO verify`. AgentCore 일부 컴포넌트 preview — 리전·GA 재확인.

**모든 에셋 공통** — endpoint 종류 중 **serverless는 GPU 없음**(SLM/LLM은 real-time). 모든 에셋에 **cleanup 셀**(endpoint/model/agent teardown, 과금 경고) + **CloudWatch 다이렉트 링크** + **비용 가드**. 시크릿·로컬 절대경로 하드코딩 금지(플러그인 이식성). 노트북은 초심자 친화(한국어 markdown), 스크립트는 정확·직관.

**사실 근거** — `sagemaker-e2e-finetune` 스킬 폴더의 `verified-facts-2026-07.md`(라이브 검증 7개 + 출처). ⚠️ 항목은 배포/실행 전 재검증.
