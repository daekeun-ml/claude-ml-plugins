# AWS Reference Links 레지스트리 — tier별 정본 문서 + 공식 GitHub

> 이 파일은 `aws-compute-platform-selector` · `sagemaker-deep-dive` · `aws-ml-lab-code` ·
> `aws-solutions-architect` · `aws-ml-engineer` 가 **출처표에 AWS 문서 + GitHub 링크를 전부 부착**할 때 쓰는 큐레이션 레지스트리.
> ✅ = 2026-07 fact-verify 워크플로에서 라이브 확인됨. ⚠️ = 정본 root(배포 전 현행 재확인).
> 출처표 규칙: **모든 산출물은 (1) docs.aws 문서 링크 + (2) 관련 공식 GitHub repo 링크를 둘 다** 포함.

## 공식 GitHub repos (tier 공통)
| repo | 용도 | URL |
|---|---|---|
| aws/amazon-sagemaker-examples | SageMaker SDK 노트북 정본 | https://github.com/aws/amazon-sagemaker-examples ⚠️ |
| aws/sagemaker-hyperpod-recipes | HyperPod 학습 레시피(Slurm/EKS) | https://github.com/aws/sagemaker-hyperpod-recipes ⚠️ |
| aws/sagemaker-hyperpod-cli | `hyp` CLI·CRD(inference operator) 예제 | https://github.com/aws/sagemaker-hyperpod-cli ✅ |
| awslabs/awsome-distributed-ai | EC2/HyperPod 분산학습 실전(구 aws-samples/awsome-distributed-training) | https://github.com/awslabs/awsome-distributed-ai ⚠️ |
| aws/deep-learning-containers | DLC 이미지 소스 | https://github.com/aws/deep-learning-containers ⚠️ (문서: https://aws.github.io/deep-learning-containers/ ✅) |
| aws/aws-parallelcluster | ParallelCluster(HPC, Slurm/AWS Batch) | https://github.com/aws/aws-parallelcluster ✅(CHANGELOG raw 확인) |

## EC2 (self-managed)
| 주제 | URL |
|---|---|
| DLAMI란 | https://docs.aws.amazon.com/dlami/latest/devguide/what-is-dlami.html ✅ |
| ParallelCluster란 | https://docs.aws.amazon.com/parallelcluster/latest/ug/what-is-aws-parallelcluster.html ✅ |
| ParallelCluster 프로세스(clustermgtd) | https://docs.aws.amazon.com/parallelcluster/latest/ug/processes-v3.html ✅ |
| ParallelCluster 기능 | https://docs.aws.amazon.com/parallelcluster/latest/ug/functional-v3.html ✅ |
| ParallelCluster CHANGELOG(raw) | https://raw.githubusercontent.com/aws/aws-parallelcluster/develop/CHANGELOG.md ✅ |
| EC2 GPU 인스턴스 | https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/accelerated-computing-instances.html ⚠️ |

## HyperPod (semi-managed) — Slurm & EKS
| 주제 | URL |
|---|---|
| HyperPod 개요(오케스트레이터 옵션) | https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod.html ✅ |
| 복원력 개요(Slurm) | https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod-resiliency.html ✅ |
| 복원력(EKS) | https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod-eks-resiliency.html ✅ |
| Slurm auto-resume | https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod-resiliency-slurm-auto-resume.html ✅ |
| EKS node recovery | https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod-eks-resiliency-node-recovery.html ✅ |
| Slurm deep health check | https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod-resiliency-slurm-deep-health-checks.html ✅ |
| HMA(EKS) | https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod-eks-resiliency-health-monitoring-agent.html ✅ |
| HyperPod DLAMI 레퍼런스 | https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod-ref.html ✅ |
| HyperPod AMI 릴리스 | https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod-release-ami.html ✅ |
| 전제조건(Slurm vs EKS) | https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod-prerequisites.html ✅ |
| MIG(EKS 전용) | https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod-eks-gpu-partitioning.html ⚠️ |
| Inference Operator(EKS) | https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod-model-deployment.html ⚠️ |
| Managed Tiered Checkpointing(EKS) | https://docs.aws.amazon.com/sagemaker/latest/dg/managed-tier-checkpointing.html ⚠️ |
| Task Governance(EKS) | https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod-eks-operate-console-ui-governance.html ⚠️ |
| Inference CRD(raw) | https://raw.githubusercontent.com/aws/sagemaker-hyperpod-cli/main/helm_chart/HyperPodHelmChart/charts/inference-operator/config/crd/inference.sagemaker.aws.amazon.com_inferenceendpointconfigs.yaml ✅ |

## SageMaker (fully-managed) — Amazon SageMaker AI
| 주제 | URL |
|---|---|
| 배포 개요(추론 4옵션) | https://docs.aws.amazon.com/sagemaker/latest/dg/how-it-works-deployment.html ✅ |
| 모델 배포 허브 | https://docs.aws.amazon.com/sagemaker/latest/dg/deploy-model.html ✅ |
| Batch Transform | https://docs.aws.amazon.com/sagemaker/latest/dg/batch-transform.html ✅ |
| Asynchronous Inference | https://docs.aws.amazon.com/sagemaker/latest/dg/async-inference.html ✅ |
| Serverless Inference | https://docs.aws.amazon.com/sagemaker/latest/dg/serverless-endpoints.html ✅ |
| ServerlessConfig API | https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_ProductionVariantServerlessConfig.html ✅ |
| Deployment guardrails | https://docs.aws.amazon.com/sagemaker/latest/dg/deployment-guardrails.html ✅ |
| guardrails blue/green | https://docs.aws.amazon.com/sagemaker/latest/dg/deployment-guardrails-blue-green.html ✅ |
| guardrails rolling | https://docs.aws.amazon.com/sagemaker/latest/dg/deployment-guardrails-rolling.html ✅ |
| Managed Spot Training | https://docs.aws.amazon.com/sagemaker/latest/dg/model-managed-spot-training.html ✅ |
| Managed Warm Pools | https://docs.aws.amazon.com/sagemaker/latest/dg/train-warm-pools.html ✅ |
| Checkpointing | https://docs.aws.amazon.com/sagemaker/latest/dg/model-checkpoints.html ✅ |
| Training 개요(영속 대안=HyperPod) | https://docs.aws.amazon.com/sagemaker/latest/dg/how-it-works-training.html ✅ |
| ResourceConfig API | https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_ResourceConfig.html ✅ |
| CheckpointConfig API | https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_CheckpointConfig.html ✅ |
| JumpStart | https://docs.aws.amazon.com/sagemaker/latest/dg/studio-jumpstart.html ⚠️ |
| Studio | https://docs.aws.amazon.com/sagemaker/latest/dg/studio.html ⚠️ |

## 부착 규칙 (출처표에 이렇게)
- 각 산출물 끝 `| 주제 | URL |` 표에 **본문이 실제 근거로 삼은 문서 링크 + 관련 공식 GitHub repo 링크를 모두** 넣는다.
- 코드 산출물(노트북/스크립트)은 상단 주석 또는 README에 **근거 예제 repo 링크**를 명시.
- "라이브 검증 YYYY-MM" 스탬프 + ⚠️ 항목은 "배포 전 재확인" 문구.
- owner/repo 이전 이력 주의(예: aws-samples/awsome-distributed-training → awslabs/awsome-distributed-ai).
