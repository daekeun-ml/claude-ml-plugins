# Tier 사실 라이브 검증 스냅샷 (2026-07)

> 이 파일은 `aws-compute-platform-selector` / `sagemaker-deep-dive` / `aws-ml-lab-code` 작성 시
> 근거로 쓰인 라이브 검증 결과다. **빠르게 바뀌는 값은 배포 전 재검증**(→ `aws-fact-verify`).
> 검증 방식: docs.aws.amazon.com + raw.githubusercontent.com 교차 + 적대적 refute.

## SageMaker (Amazon SageMaker AI — classic, fully-managed)
- **추론 4옵션**: Real-time(영속 엔드포인트) · Serverless(scale-to-zero, cold start) ·
  Asynchronous(대용량 payload≤1GB, 처리≤1h, idle시 0으로) · **Batch Transform은 "엔드포인트"가 아니라 배치 JOB**(S3 in/out). ⚠️ 4개를 모두 "endpoint"로 뭉뚱그리지 말 것.
  - 출처: how-it-works-deployment.html, deploy-model.html, batch-transform.html, async-inference.html
- **Serverless GPU 미지원(현재 기준)**: CPU/메모리 전용. Memory 1024/2048/3072/4096/5120/6144 MB.
  `ProductionVariantServerlessConfig` = {MaxConcurrency 1–200, MemorySizeInMB 1024–6144, ProvisionedConcurrency}. GPU 필요 → Real-time.
  - 출처: serverless-endpoints.html, API_ProductionVariantServerlessConfig.html
- **Deployment guardrails**(blue/green: all-at-once·canary·linear + rolling + CloudWatch 자동 롤백):
  **Async + Real-time 엔드포인트 전용**, Create/UpdateEndpoint API 경유. **HyperPod에는 적용 안 됨**
  (HyperPod-EKS는 inference operator + CRD `inference.sagemaker.aws.amazon.com` / kubectl·hyp). 근거는 "메커니즘"(명시적 배제문장 아님). `SageMakerEndpointRegistration` CRD로 등록은 가능하나 그게 guardrails 라이프사이클은 아님.
  - 출처: deployment-guardrails*.html, aws/sagemaker-hyperpod-cli(raw)
- **Training Jobs**: per-job on-demand 클러스터, 기본 job 완료 후 spin-down("ephemeral"은 AWS 공식 용어 아님, 서술어로만).
  - **Managed Spot Training**: `EnableManagedSpotTraining=True` + `MaxWaitTimeInSeconds`(> MaxRuntime). **최대 90% 절감**(80%은 예시 계산일 뿐, 헤드라인 아님).
  - **Managed Warm Pools**: `KeepAlivePeriodInSeconds`(ResourceConfig 내). billable, **Spot과 병용 불가**. ⚠️ 문서 충돌: DevGuide 3600s vs API Ref 21600s; 매칭 잡 체인은 최대 28일. → 단일 숫자 단정 금지.
  - **Checkpoint to S3**: `CheckpointConfig` S3Uri(필수)+LocalPath(기본 `/opt/ml/checkpoints/`).
  - 출처: model-managed-spot-training.html, train-warm-pools.html, model-checkpoints.html, how-it-works-training.html, API_ResourceConfig/CheckpointConfig

## HyperPod (semi / managed-resiliency) — Slurm & EKS
- **관리형 복원력 (양쪽 오케스트레이터 공통)**: HMA(Health Monitoring Agent, GPU/Trainium/EFA 결함 상시 감지) +
  deep health checks(DCGM lvl4·NCCL all_reduce·EFA loopback) + 자동 노드 recovery(재부팅/교체). auto node replacement 양쪽 확인.
  - ⚠️ **HMA-on-Slurm은 2025-09-11부터**(최신 AMI + UpdateClusterSoftware 필요) — 그 전엔 EKS 전용.
  - node recovery는 클러스터 설정(Automatic[기본] vs None; None이면 label/taint만). deep health check는 opt-in(`OnStartDeepHealthChecks`).
  - 출처: sagemaker-hyperpod-resiliency*.html, -eks-resiliency*.html
- **DLAMI vs DLC**: **HyperPod DLAMI = 노드 부팅용 머신이미지(host)** (Slurm=Ubuntu 20.04 DL Base GPU AMI 기반, EKS=AL2/AL2023 기반; 드라이버·스케줄러툴·SSM·복원력SW 번들). **DLC = 프레임워크 컨테이너 이미지(workload)**.
  - ⚠️ **DLC는 관리형 잡 전용이 아님** — EC2/ECS/EKS(HyperPod-EKS 포함)에서도 실행. "DLC=managed only" ❌, "DLC never on HyperPod" ❌.
  - 출처: sagemaker-hyperpod-ref.html, -release-ami.html, aws.github.io/deep-learning-containers

## EC2 (self-managed)
- **옵션**: (1) raw EC2 GPU + **DLAMI**(CUDA/cuDNN/프레임워크 사전설치) (2) **AWS ParallelCluster**(오픈소스 HPC 관리툴, Slurm/AWS Batch, head node=고객 EC2=고객 관리 control plane). (+ AWS PCS, self-managed EKS/ECS도 존재).
  - ⚠️ **정정**: ParallelCluster는 "auto node replacement가 없다"가 아님 — `clustermgtd`가 EC2 status-check 실패한 STATIC 노드 자동 교체 + opt-in GPU health check(v3.6+). **HyperPod와의 진짜 차이 = (a) control plane 소유(self vs managed) + (b) 복원력 깊이(accelerator-level deep health check·auto-resume은 HyperPod가 out-of-box)**.
  - 출처: parallelcluster/what-is·processes-v3·functional-v3, dlami/what-is-dlami.html, aws-parallelcluster CHANGELOG(raw)

## 스킬 작성 시 필수 정정 규칙 (오귀속 방지)
1. Batch Transform ≠ endpoint (job).  2. Serverless엔 GPU 없음(현재 기준).  3. guardrails는 SageMaker classic 전용, HyperPod 아님.  4. Spot 최대 90%.  5. DLC ≠ managed-only.  6. ParallelCluster도 노드 교체 있음 — 차이는 관리주체·health-check 깊이.  7. HMA-on-Slurm은 2025-09.
