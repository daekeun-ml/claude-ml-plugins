---
name: aws-compute-platform-selector
description: Decide which AWS ML compute platform tier fits a workload — EC2/self-managed (raw GPU + DLAMI, ParallelCluster) vs HyperPod semi-managed (Slurm / EKS) vs SageMaker fully-managed (Training Jobs, Endpoints). Builds a tier-spectrum operational comparison (운영부담·복원력·지속성·비용모델·스케줄러 제어·팀 스킬셋), separates confirmed facts from fast-changing ones, and emits conditional "choose X when…" recommendations. Leads to the HyperPod Slurm-vs-EKS sub-decision when the tier narrows to HyperPod. Use when a team asks "어디서 학습/서빙해야 하나" or "EC2 vs HyperPod vs SageMaker 뭘 골라야 하나" before picking an orchestrator.
allowed-tools: Read, Write, Edit, WebFetch, Bash, Grep, AskUserQuestion
argument-hint: "<workload/constraints> [학습|추론] [선호 tier(있으면)]"
triggers: ["컴퓨트 플랫폼", "ec2 vs hyperpod", "hyperpod vs sagemaker", "어디서 학습", "어디서 서빙", "플랫폼 선택", "self managed vs managed", "관리형 선택", "compute platform", "학습 플랫폼", "추론 플랫폼", "which platform", "어떤 플랫폼", "tier 선택"]
level: 2
---

# AWS Compute Platform Selector — EC2 / HyperPod / SageMaker tier 결정

ML 워크로드를 **어느 관리 tier에서 돌릴지** 결정하는 스킬.
`aws-architecture-decision`의 조건부-권장 골격을 재사용하되, 축을 **관리 tier 스펙트럼**으로 고정한다.
HyperPod로 좁혀지면 그다음 Slurm↔EKS 결정으로 넘긴다(→ Related).

## When to Activate
- "이 워크로드 EC2 / HyperPod / SageMaker 중 어디서?" — 학습이든 추론이든.
- 고객/팀이 한 tier로 기울어 있고, 그 판단이 워크로드 제약과 맞는지 검증이 필요할 때.
- "관리형이 무조건 편한 거 아냐?" 같은 tier 오해를 정정해야 할 때.

## The Insight
플랫폼 결정의 핵심은 기능 목록이 아니라 **"운영을 누가 지느냐(control plane 소유) + 복원력을 어디까지 관리받느냐 + 클러스터가 영속이냐 job마다 뜨고 지느냐"** 다.
tier는 별개 제품이 아니라 **self → semi → fully 로 이어지는 스펙트럼**이고, 대부분의 결정은 "얼마나 관리를 넘길지"의 문제다.

> ⚠️ 흔한 통념 정정(라이브 검증 2026-07): "ParallelCluster엔 노드 자동교체가 없다"는 **틀림**(`clustermgtd`가 EC2 status-check 실패 STATIC 노드 교체). HyperPod의 진짜 차별점은 *교체 유무*가 아니라 **관리 주체 + accelerator-level deep health check(DCGM/NCCL/EFA)·auto-resume이 out-of-box** 라는 점. 이 뉘앙스를 뭉개지 말 것.

## Document Skeleton (산출물 순서 고정)
1. **머리말 `>` 블록**: 대상 독자 · ⚠️핵심 주의 · "라이브 검증 YYYY-MM".
2. **§0 TL;DR** — **맨 위 한 줄 요약**(예: "영속 복원력 클러스터+기존 sbatch면 HyperPod Slurm, 간헐 배치추론이면 SageMaker") → 그다음 번호형 결론 5~6개(false-fork 여부·고객 lean 검증·tier 오해 정정 포함).
3. **§0.5 기존 Pain Point** — 독자가 *지금* 겪는 문제를 먼저 부각(예: "self-managed로 700B 돌리다 노드 죽을 때마다 수동 복구·goodput 손실" / "SageMaker로 상시 GPU 엔드포인트 띄워놓고 idle 과금"). 왜 tier를 다시 고민하는지의 동기.
4. **§1 "왜 tier로 나뉘나"** — self/semi/fully **스펙트럼 ASCII** + 쉬운 비유(직접운전 vs 렌터카+보험 vs 콜택시) + 기술적 3차이(control plane 소유·복원력 관리범위·영속성).
5. **§2 tier 스펙트럼 도식**:
   ```
   self-managed ───────────── semi-managed ───────────── fully-managed
   EC2 raw+DLAMI              HyperPod (Slurm | EKS)       SageMaker
   ParallelCluster            = 영속 복원력 클러스터        Training Jobs / Endpoints
   (control plane=고객)        (HMA·deep health·auto-resume) (job마다 spin-up/down)
   운영부담 高 ───────────────────────────────────────────▶ 운영부담 低
   제어·이식성 高 ──────────────────────────────────────────▶ 추상화·속도 高
   ```
6. **§3 운영 비교표** — `| Dimension | EC2(self) | HyperPod(semi) | SageMaker(fully) |`. 축:
   운영부담 · **복원력(누가 노드 교체·health check 깊이)** · 지속성(영속 클러스터 vs ephemeral job) ·
   스케줄러 제어 · 비용모델(예약 클러스터 vs per-job/per-request·spot·idle) · 규모/스케일 · 시작 속도 ·
   락인·이식성 · 팀 스킬셋(torchrun/sbatch/kubectl/SDK).
7. **§4 choose-when 로직**(조건부, 단정 금지) — 아래 "Decision Logic".
8. **❓오해 노트**(blockquote 시그니처) — 아래 시드.
9. **§5 Open Questions** — 리전 가용성·per-request 과금·특정 인스턴스 가용성 등 확인 항목.
10. **출처표** — `| 주제 | URL |` + "라이브 검증 YYYY-MM" + (있으면) 자매 문서 네비. 🔴 **AWS 문서 링크 + 관련 공식 GitHub repo 링크를 전부** 부착(같은 스킬 폴더의 `aws-reference-links.md` 레지스트리를 근거로 tier별 URL을 뽑아옴).

## Decision Logic (조건부 권장 — 조건을 먼저, 권장을 뒤에)
- **EC2 self-managed 골라라 — 다음이면**: 커널/드라이버/네트워크 스택 완전 제어 필요 · 최저가 스팟으로 직접 최적화 · 기존 HPC/ParallelCluster 자산 · AWS 관리 복원력이 굳이 필요 없음(짧은 잡·내결함성 코드).
- **HyperPod semi-managed 골라라 — 다음이면**: 수 일~수 주 대규모 FM 학습에 **관리형 복원력(HMA·deep health check·자동 노드 교체·auto-resume)**이 필요 · goodput이 노드 결함에 휘둘림. → 그다음 **Slurm(기존 sbatch·단일테넌트) vs EKS(멀티팀 K8s·통합 추론·MIG·Task Governance)** 는 Related 문서로.
- **SageMaker fully-managed 골라라 — 다음이면**: 인프라 운영 최소화 · 간헐/버스티 워크로드(Training Job은 job마다 spin-up/down, Managed Spot 최대 90% 절감) · 서버리스/비동기 추론(단, **Serverless엔 GPU 없음 — 현재 기준**, GPU는 Real-time) · JumpStart로 빠른 배포. → 심화는 `sagemaker-deep-dive`.

## ❓오해 노트 시드
> ❓ "관리형(SageMaker)이 항상 제일 쉽고 싸다?" — 아닙니다. 상시 GPU 엔드포인트는 idle에도 과금. 간헐 워크로드에 유리, 상시 고부하엔 전용 클러스터가 쌀 수 있음.
> ❓ "HyperPod = SageMaker의 일부니까 fully-managed?" — 아닙니다. HyperPod는 **영속 클러스터를 당신이 운영**하되 복원력만 관리받는 semi-managed. SageMaker Training Job/Endpoint의 job-단위 추상화와 다름.
> ❓ "ParallelCluster엔 자동 노드 복구가 없다?" — 아닙니다(정정 위 참조). 차이는 깊이·관리주체.
> ❓ "SageMaker Serverless로 LLM 서빙?" — GPU 미지원(현재 기준). LLM은 Real-time(GPU) 또는 HyperPod/EC2.

## The Approach
1. **워크로드·제약·lean 확인**(AskUserQuestion): 학습/추론, 모델 규모, 잡 길이, 팀 스킬셋(sbatch/kubectl/SDK), 복원력 요구, 규제/사설접근, 기운 tier.
2. **사실 교차검증** — tier 경계 사실(guardrails 범위·serverless GPU·spot 절감·복원력 범위)은 추측 금지 → `aws-fact-verify` / `aws-fact-checker` 위임. 로컬에 `verified-facts-*.md`가 있으면 근거로 참조.
3. **false-fork 판정** — 두 옵션이 사실 같은 스펙트럼의 인접 지점이면 "저위험·되돌리기 쉬움" 강조(예: Recipes·데이터·이미지 재사용 가능).
4. **비교표 + 조건부 권장** — 조건 먼저, 권장 뒤. 고객 lean이 합리적이면 확인해주고 재고 조건 병기.
5. **핸드오프** — HyperPod로 좁혀지면 Slurm↔EKS 세부결정으로, SageMaker면 `sagemaker-deep-dive`로, 실습이 필요하면 `aws-ml-lab-code`로.

## Gotchas (반드시 지킬 것)
- **단정 금지, 조건부 권장** — "SageMaker 쓰세요" ❌ → "간헐 워크로드+운영최소화면 → SageMaker" ⭕.
- **tier 오귀속 금지** — guardrails(blue/green)는 SageMaker classic 전용(HyperPod 아님) · Serverless엔 GPU 없음 · DLC는 managed 전용 아님(EC2/EKS/HyperPod-EKS서도 실행) · DLAMI(노드 host)와 DLC(workload 컨테이너) 구분.
- **복원력 뉘앙스** — "self엔 아무 것도 없다" 식 과일반화 금지. raw EC2=없음 / ParallelCluster=EC2 status-check 교체+opt-in GPU check / HyperPod=accelerator-level deep health check·auto-resume out-of-box.
- **빠르게 바뀌는 값** — 리전 가용성·인스턴스·warm pool 최대시간(문서 충돌)·HMA-on-Slurm 날짜(2025-09) 는 ⚠️ + "배포 전 재확인".
- **플러그인 이식성** — 로컬 절대경로 하드코딩 금지. 자매 HyperPod 문서는 "로컬에 있으면 참조"로 조건부. selector 자체로 결정이 완결되게 self-contained.

## Example
```
사용자: 70B 파인튜닝, 팀은 sbatch 경험, 노드 자주 죽어서 goodput 손실, 멀티팀 아님. 어디서?
→ §0.5 pain: 수동 복구·goodput 손실이 동기
  → §3 비교표: 복원력 축에서 HyperPod가 결정적(HMA·auto-resume out-of-box)
  → §4: "관리형 복원력 필요+기존 sbatch+단일테넌트 → HyperPod Slurm" (조건부)
  → 핸드오프: Slurm vs EKS 세부결정 → (로컬에 있으면) hyperpod 자매 문서, 없으면 인라인 요약
반례) 간헐 배치 추론+운영 최소화 → SageMaker (Batch Transform은 job, Serverless는 GPU 없음 주의)
```

## Reference
- `aws-reference-links.md`(같은 폴더) — tier별 AWS 문서 + 공식 GitHub 정본 URL 레지스트리. 출처표는 여기서 부착.
- `verified-facts-2026-07.md`(같은 폴더) — tier 경계 사실 라이브 검증 스냅샷.

## Related
- `aws-architecture-decision` — 이 스킬이 재사용하는 조건부-권장 골격(2택 일반형).
- `sagemaker-deep-dive` — tier가 SageMaker로 좁혀졌을 때 심화.
- `aws-ml-lab-code` — 플랫폼 정한 뒤 tier별 실습 코드가 필요할 때.
- `aws-fact-verify` / `aws-fact-checker` — tier 경계 사실 교차검증.
- (로컬에 있으면) HyperPod Slurm↔EKS 자매 가이드 — HyperPod로 좁혀진 뒤 오케스트레이터 세부결정.
