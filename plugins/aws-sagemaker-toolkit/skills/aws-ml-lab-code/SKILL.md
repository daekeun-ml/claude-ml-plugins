---
name: aws-ml-lab-code
description: 'Generate runnable hands-on lab code (Python scripts + JupyterLab notebooks) for AWS ML compute tiers — EC2/self-managed (torchrun/accelerate on DLAMI, ParallelCluster sbatch), HyperPod Slurm (sbatch + srun --auto-resume), HyperPod EKS (HyperPodPyTorchJob CRD + kubectl/hyp), and SageMaker (Python SDK: Estimator.fit, Predictor, serverless/async config, JumpStartModel). Grounds every snippet in official example repos (aws-samples, awslabs, aws/amazon-sagemaker-examples, aws/sagemaker-hyperpod-recipes), uses placeholders not secrets, mandates a cleanup cell to avoid GPU/endpoint billing, and opens each notebook with TL;DR / Why / Pain-point. Use when someone wants sample/실습 코드 or a hands-on notebook for a specific tier.'
allowed-tools: Read, Write, Edit, Bash, WebSearch, WebFetch, Skill
argument-hint: "<tier> <task: 학습|추론|파인튜닝> [framework/model]"
triggers: ["실습 코드", "샘플 코드", "노트북", "jupyter", "예제 코드", "코드 예시", "sample code", "notebook", "실행 코드", "핸즈온", "hands-on", "튜토리얼 코드", "코드 만들어", "실습"]
level: 2
---

# AWS ML Lab Code — tier별 실행 가능 실습 코드/노트북 생성

EC2 / HyperPod(Slurm·EKS) / SageMaker 각 tier의 **관용구에 맞는 실행 가능한** Python 스크립트·JupyterLab 노트북을 생성하는 스킬.
Claude 지식 + 공개 웹 + **AWS 공식 예제 repo** 근거. 가이드(prose)와 별개인 "손으로 돌리는 코드" 산출물.

## When to Activate
- "이거 실습 코드/샘플/노트북으로 만들어줘", "핸즈온 튜토리얼 코드" 요청.
- 가이드 문서에 붙일 실행 예제가 필요할 때.
- 특정 tier(예: HyperPod Slurm sbatch, SageMaker SDK)의 최소 재현 코드가 필요할 때.

## The Insight
같은 "분산학습 코드"라도 **tier마다 관용구가 근본적으로 다르다** — 이걸 섞으면 안 돈다.
좋은 실습 코드는 (1) 해당 tier의 진짜 관용구를 쓰고, (2) 플레이스홀더로 이식 가능하며, (3) **cleanup으로 과금을 막고**, (4) 왜 이렇게 하는지 상단에서 설명한다.

## 근거 소스 (공식 예제 repo — 여기서 관용구 확인)
- `aws/amazon-sagemaker-examples` — SageMaker SDK 노트북 정본.
- `aws/sagemaker-hyperpod-recipes` — HyperPod 학습 레시피(Slurm/EKS).
- `aws/sagemaker-hyperpod-cli` — `hyp` CLI·CRD 예제.
- `awslabs/awsome-distributed-ai`(구 aws-samples/awsome-distributed-training) — EC2/HyperPod 분산학습 실전.
- `aws-samples/*` — 토픽별 샘플. ⚠️ owner/repo 이전 이력 확인(위 사례).

## tier별 코드 관용구 (🔴 혼용 금지)
| tier | 학습 관용구 | 추론 관용구 | 실행 진입점 |
|---|---|---|---|
| **EC2 self** | `torchrun`/`accelerate launch` 멀티노드, DLAMI 위 raw, (선택)ParallelCluster `sbatch` | vLLM/TGI 직접 기동 | SSH/SSM |
| **HyperPod Slurm** | `sbatch` + `srun --auto-resume=1` + Enroot/Pyxis(.sqsh), `/fsx` 체크포인트 | (별도 서빙 구성) | SSM → login 노드 |
| **HyperPod EKS** | `HyperPodPyTorchJob` CRD YAML + `kubectl apply`/`hyp` | Inference Operator CRD (`InferenceEndpointConfig`) | kubectl/hyp |
| **SageMaker** | `sagemaker` SDK: `PyTorch`/`Estimator` → `estimator.fit()` (+ Managed Spot/Warm Pool/CheckpointConfig) | `Predictor`, `serverless`/`async` config, `JumpStartModel` | boto3/SDK/Studio |

## 노트북 셀 규약 (순서 고정)
1. **상단 markdown 셀**: 🔴 **TL;DR(한 줄) · Why(왜 이 tier·이 방식) · 기존 Pain Point** 3요소.
2. 설치: `%pip install ...` (버전 주석으로 pin 권장, API drift 방지).
3. **설정**: region/role/bucket 은 **플레이스홀더 or env var**(`<YOUR_ROLE_ARN>`, `os.environ[...]`) — 시크릿 하드코딩 금지.
4. 데이터 준비.
5. 학습 또는 배포(tier 관용구).
5.5. **🔴 CloudWatch 다이렉트 링크 셀 (SageMaker 학습/추론)**: `estimator.fit()`·`deploy()`·`invoke_endpoint` 직후, CloudWatch Logs/Metrics + SageMaker 콘솔로 바로 가는 **클릭 가능한 링크**(`IPython.display.HTML`)를 출력해 상황을 즉시 보게 한다. region은 세션에서 동적. (헬퍼 관용구·URL 규약은 [[aws-handson-testing]] 규칙 참조; 콘솔 URL 형식은 "현재 기준", Logs 경로 `/`→`$252F` 이중 인코딩.)
6. 결과 확인(predict/평가).
7. **🔴 정리(cleanup) 셀 — 필수**: endpoint/cluster/warm-pool 삭제로 GPU·엔드포인트 과금 방지 (`predictor.delete_endpoint()`, `kubectl delete`, 클러스터 정리 등). 주석으로 "실행 안 하면 과금 지속" 경고.

## The Approach
1. **intake**: tier · task(학습/추론/파인튜닝) · 프레임워크·모델·데이터 규모.
2. **관용구 확인**: 위 표 + 공식 예제 repo에서 실제 최신 API 형태 대조(WebFetch raw). 불확실하면 표기.
3. **코드 작성**: tier 관용구대로, 플레이스홀더·cleanup·상단 3요소 포함. 노트북이면 `.ipynb`(JSON) 또는 `jupytext`식 `.py` 셀 마커.
4. **사실 검증 위임**: SDK 클래스/파라미터명·CLI 플래그·CRD 필드는 `aws-fact-checker`(서브에이전트) 또는 `aws-fact-verify`(스킬)로. 미검증은 주석 `# TODO verify`.
5. **실행 주의 명시**: 실제 실행엔 AWS 자격증명·GPU·과금 발생 — 스킬은 "생성" 중심, 실행은 사용자 환경.
6. **🔴 링크 부착**: 노트북 상단/README에 **근거 AWS 문서 링크 + 근거 공식 GitHub 예제 repo 링크를 전부** 명시(`aws-compute-platform-selector` 스킬의 `aws-reference-links.md` 레지스트리 활용). 각 핵심 API/셀에 관련 문서 URL 주석.

## Gotchas
- **시크릿 하드코딩 금지** — access key·account id·role arn 은 플레이스홀더/env.
- **cleanup 필수** — GPU 인스턴스·엔드포인트·warm pool은 안 지우면 계속 과금. 마지막 셀 강제.
- **tier 관용구 혼용 금지** — SageMaker 노트북에 sbatch, Slurm 잡에 SDK `.fit()` 섞지 말 것.
- **버전 drift** — SDK/CRD API는 자주 바뀜. pin + "작성 시점" 주석. 미검증 API는 표기.
- **자기 코드 자기승인 금지** — 생성 코드의 사실성은 검증 lane(`aws-fact-checker`)으로.
- **플러그인 이식성** — 로컬 절대경로/버킷명 하드코딩 금지. 예제 repo는 이름으로 참조.
- **Serverless엔 GPU 없음**(현재 기준) — LLM 서빙 예제는 Real-time/GPU로.

## Example
```
사용자: SageMaker로 Llama 파인튜닝 실습 노트북 만들어줘
→ intake(tier=SageMaker, task=파인튜닝) → amazon-sagemaker-examples에서 Estimator 패턴 확인
  → 셀: TL;DR/Why/Pain → %pip → role 플레이스홀더 → 데이터 → PyTorch estimator(+Managed Spot)
    → estimator.fit() → Predictor 테스트 → 🔴 predictor.delete_endpoint() cleanup
  → SDK 클래스명은 aws-fact-checker로 검증
```

## Related
- `aws-ml-engineer`(서브에이전트) — 이 스킬을 사용해 실습 코드를 작성하는 실행 lane.
- `aws-compute-platform-selector` — 어느 tier에 코드를 짤지 아직 안 정했을 때.
- `sagemaker-deep-dive` — SageMaker 코드의 개념 배경.
- `aws-fact-checker` / `aws-fact-verify` — SDK/CLI/CRD 사실 검증.
