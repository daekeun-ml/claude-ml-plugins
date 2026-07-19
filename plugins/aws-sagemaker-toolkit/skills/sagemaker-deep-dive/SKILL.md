---
name: sagemaker-deep-dive
description: Write beginner-friendly yet accurate deep-dive guides on Amazon SageMaker AI (the fully-managed tier) in the hyperpod-docs house style — Training Jobs (per-job spin-up/down, Managed Spot up to 90%, Warm Pools, S3 checkpointing), the four inference options (Real-time / Serverless / Asynchronous / Batch Transform), JumpStart, Studio, and DLC vs HyperPod DLAMI. Enforces TL;DR → Pain-point → Why openers, contrast tables against HyperPod, and ❓misconception notes that prevent tier misattribution (guardrails are classic-only, Serverless has no GPU, DLC is not managed-only). Use when authoring or expanding SageMaker fully-managed study/onboarding docs.
allowed-tools: Read, Write, Edit, WebFetch, Bash, Grep, AskUserQuestion, Skill
argument-hint: "<topic or existing .md path> [학습|추론|배포]"
triggers: ["sagemaker", "세이지메이커", "sagemaker ai", "training job", "sagemaker endpoint", "jumpstart", "studio", "완전관리형", "관리형 학습", "관리형 추론", "serverless inference", "async inference", "batch transform", "managed spot", "warm pool"]
level: 2
---

# SageMaker Deep-Dive — 완전관리형 tier 심화 (hyperpod-docs 하우스 스타일)

Amazon **SageMaker AI**(완전관리형 tier) 학습/추론/배포를 **초심자도 이해하되 사실은 틀리지 않게** 쓰는 스킬.
`aws-tech-guide`의 하우스 스타일을 SageMaker 도메인에 특화해 재현한다. tier 3분(EC2/HyperPod/SageMaker) 중 **문서가 가장 얇은 곳**을 HyperPod 가이드 수준으로 끌어올리는 게 목적.

> ⚠️ 서비스명: AWS가 classic SageMaker를 **"Amazon SageMaker AI"** 로 리브랜딩. HyperPod / Unified Studio와 혼동 방지 위해 "SageMaker AI(완전관리형)"로 표기.

## When to Activate
- SageMaker Training Jobs / Endpoints / JumpStart / Studio 가이드를 새로 쓰거나 기존 문서를 보강할 때.
- "SageMaker로 학습/서빙 어떻게?" 또는 HyperPod를 아는 독자가 "관리형은 뭐가 다른가"를 물을 때.
- tier 오귀속(관리형 기능을 HyperPod에 잘못 귀속 등)을 정정해야 할 때.

## The Insight
SageMaker AI의 본질은 **"클러스터를 당신이 운영하지 않는다 — job/endpoint 단위로 뜨고 진다"** 이다.
HyperPod가 *영속 클러스터 + 관리형 복원력*이라면, SageMaker는 *추상화된 job/endpoint*. 이 대비를 먼저 세우면 대부분의 기능이 자연스럽게 이해된다.

## Document Skeleton (섹션 순서 고정 — 🔴 상단 3요소 필수)
1. **머리말 `>` 블록**: 대상 독자(HyperPod/EC2는 알고 SageMaker는 처음일 수 있음) · ⚠️주의 · "라이브 검증 YYYY-MM".
2. **§0 TL;DR** — **맨 위 한 줄 요약** → 번호형 결론 5~7개.
3. **§0.5 기존 Pain Point** — 독자가 지금 겪는 문제 부각(예: "self-managed로 상시 클러스터 유지·패치 부담" / "학습 잡 시작마다 환경 세팅 반복" / "간헐 추론에 상시 GPU 인스턴스 idle 과금").
4. **§1 "왜 관리형인가"** — HyperPod/EC2 **대조표** + 비유(콜택시 vs 렌터카) + 기술차이(영속 클러스터 없음·job/endpoint 추상화·AWS가 인프라 운영).
5. **본문 §2~** — 아래 "Coverage Surfaces"를 "쉽게 말하면(ASCII)" → 단계별 → 표 로.
6. **❓오해 노트**(blockquote 시그니처) — 아래 시드 필수 포함.
7. **출처표** — `| 주제 | URL |` + "라이브 검증 YYYY-MM" + 네비. 🔴 **AWS 문서 링크 + 관련 공식 GitHub repo 링크를 전부** 부착(`aws-compute-platform-selector` 스킬의 `aws-reference-links.md` 레지스트리 SageMaker 섹션을 근거로; 없으면 docs.aws + 공식 repo에서 직접). 본문이 실제 근거로 삼은 문서는 빠짐없이.

## Coverage Surfaces (라이브 검증 2026-07 근거)
### 학습 — Training Jobs
- **per-job on-demand 클러스터**: job 시작 시 프로비저닝, 기본 완료 후 spin-down. ("ephemeral"은 서술어일 뿐 AWS 공식 용어 아님. 영속 클러스터 대안은 HyperPod).
- **Managed Spot Training**: `EnableManagedSpotTraining=True` + `MaxWaitTimeInSeconds`(> `MaxRuntimeInSeconds`). **최대 90% 절감**(⚠️ 80%은 예시 계산일 뿐 — 헤드라인은 90%). 체크포인트와 병행 권장.
- **Managed Warm Pools**: `KeepAlivePeriodInSeconds`(ResourceConfig 내) > 0 → 인프라 유지·재사용으로 시작 지연↓. **billable**, **Spot과 병용 불가**. ⚠️ 최대 keep-alive 문서 충돌(DevGuide 3600s vs API Ref 21600s); 매칭 잡 체인 최대 28일 — 단일 숫자 단정 금지.
- **Checkpoint to S3**: `CheckpointConfig` = S3Uri(필수) + LocalPath(기본 `/opt/ml/checkpoints/`). S3↔로컬 동기·재개.

### 추론 — 4가지 옵션 (⚠️ Batch Transform은 endpoint 아님)
| 옵션 | 무엇 | 언제 | GPU |
|---|---|---|---|
| **Real-time** | 영속 엔드포인트, 1건씩 저지연 | 인터랙티브·상시 | ✅ |
| **Serverless** | scale-to-zero, cold start 허용 | 간헐·버스티 | ❌ (현재 기준, memory 1024–6144MB) |
| **Asynchronous** | 큐잉, payload≤1GB, 처리≤1h, idle시 0으로 | 대용량·장처리 | ✅ |
| **Batch Transform** | **JOB**(엔드포인트 아님), S3 in/out, 전체 데이터셋 예측 | 오프라인 배치 | ✅ |

> ⚠️ 위 표의 수치(Async payload≤1GB·처리≤1h, Serverless memory 1024–6144MB, Batch MaxPayload≤100MB 등)는 **현재 기준**이며 빠르게 바뀜 — 배포 전 API/서비스 한계 재확인.

- **Deployment guardrails**(blue/green: all-at-once·canary·linear + rolling + CloudWatch 자동 롤백): **Async·Real-time 엔드포인트 전용**, Create/UpdateEndpoint API 경유. **HyperPod에는 적용 안 됨**(HyperPod-EKS는 inference operator + CRD/kubectl·hyp).

### JumpStart / Studio / 컨테이너
- **JumpStart**: 사전학습 FM 원클릭 배포/파인튜닝(`JumpStartModel`).
- **Studio**: 통합 IDE(노트북·실험·파이프라인).
- **DLC(Deep Learning Containers)**: 프레임워크 사전설치 **컨테이너 이미지(workload)**. SageMaker 학습/추론이 이걸 실행. ⚠️ **DLC ≠ managed 전용** — EC2/ECS/EKS(HyperPod-EKS 포함)서도 실행. **HyperPod DLAMI(노드 host 이미지)와 층위가 다름**.

## ❓오해 노트 시드 (반드시 정정 포함)
> ❓ "SageMaker Endpoint == HyperPod Inference Operator?" — 아닙니다. SageMaker는 Create/UpdateEndpoint 관리형 엔드포인트, HyperPod는 EKS 위 CRD/kubectl·hyp. guardrails(blue/green·canary)는 **SageMaker classic 전용**.
> ❓ "Training Job이 클러스터를 계속 점유?" — 아닙니다. 기본은 job마다 뜨고 진다(spin-down). 유지하려면 Warm Pool(billable, Spot 불가). 영속 클러스터는 HyperPod.
> ❓ "Serverless Inference에 GPU?" — 아닙니다(현재 기준). memory 1024–6144MB만, GPU는 Real-time.
> ❓ "Managed Spot은 80% 절감?" — 헤드라인은 **최대 90%**. 80%은 문서의 예시 계산.
> ❓ "DLC는 SageMaker 전용?" — 아닙니다. EC2/ECS/EKS·HyperPod-EKS서도 실행되는 범용 컨테이너.

## The Approach
1. **범위·독자 확인** — 학습/추론/배포 중 무엇, 독자가 HyperPod/EC2를 아는지(대조 축 결정).
2. **사실 라이브 검증** — SDK 클래스·파라미터·한계값·GA는 추측 금지 → `aws-fact-verify`/`aws-fact-checker`. 로컬 `verified-facts-*.md` 있으면 근거로.
3. **초안** — 스켈레톤대로, 상단 3요소(TL;DR → Pain → Why 순) 필수, HyperPod 대조표 1개+ASCII 1개.
4. **❓오해노트 삽입** — 위 시드 최소 3개.
5. **넘버링·출처 검증** — 섹션 참조·출처표 라이브검증 스탬프.

## Gotchas
- **tier 오귀속 금지**(위 오해노트가 곧 체크리스트): guardrails classic 전용 · Serverless GPU 없음 · Batch Transform은 job · DLC ≠ managed 전용 · DLAMI(host) vs DLC(workload).
- **빠르게 바뀌는 값** — Serverless 한계(memory/concurrency/리전)·warm pool 최대시간(문서 충돌)·spot 수치는 ⚠️ + "현재 기준"/"배포 전 재확인". Serverless GPU 미지원은 point-in-time 표현("현재 기준")으로.
- **AWS 마케팅 수치는 "AWS 주장"으로** — 90% 등 고객 공유 시 출처.
- **플러그인 이식성** — 로컬 절대경로 하드코딩 금지, 자매 문서는 조건부 참조.

## Example
```
사용자: SageMaker 추론 옵션 가이드 써줘, 우리 팀은 HyperPod만 알아
→ 머리말(대상=HyperPod 아는 독자) → §0 TL;DR 한줄 → §0.5 pain(상시 GPU idle 과금)
  → §1 HyperPod 대조표 → §2 4옵션 표(Batch Transform은 job 강조) → guardrails classic 전용 정정
  → ❓오해노트 4개 → 출처표(deploy-model.html 등, 라이브 검증 2026-07)
```

## Related
- `aws-tech-guide` — 이 스킬이 특화한 상위 하우스 스타일(일반 AWS 토픽).
- `aws-compute-platform-selector` — tier가 아직 SageMaker로 안 좁혀졌을 때 상위 결정.
- `aws-ml-lab-code` — SageMaker SDK 실습 코드/노트북.
- `aws-fact-verify` / `aws-fact-checker` — SDK/한계값 사실 검증.
- `aws-slide-deck` — 완성 가이드를 슬라이드로.
