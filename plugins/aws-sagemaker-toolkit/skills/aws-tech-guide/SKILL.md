---
name: aws-tech-guide
description: Write beginner-friendly yet accurate AWS technical guides in the "hyperpod docs" house style — TL;DR → plain-language explainer → detail → ❓misconception notes → live-verified source table. Korean-first. Enforces contrast tables (e.g. EKS-vs-Slurm), "왜?(why)" sections before "how", and never mis-attributing one mode's features to another. Use when writing or expanding an AWS service/architecture study guide, onboarding doc, or internal reference in md/ knowledge bases.
allowed-tools: Read, Write, Edit, WebFetch, Bash, Grep, AskUserQuestion
argument-hint: "<topic or existing .md path> [scope/audience]"
triggers: ["기술 가이드", "aws 가이드", "가이드 작성", "쉽게 설명", "쉽게 풀어", "tech guide", "onboarding doc", "study guide", "문서 보강", "왜 이렇게"]
level: 2
---

# AWS Tech Guide Writer — 초심자 친절 + 정확성 원칙

AWS 서비스/아키텍처 학습·운영 가이드를 **초심자도 이해하되 사실은 틀리지 않게** 쓰는 스킬.
`md/hyperpod-slurm/`·`md/hyperpod-eks/` 같은 저장소의 하우스 스타일을 그대로 재현한다.

## When to Activate
- 새 AWS 토픽 가이드를 처음부터 쓰거나, 기존 `.md` 문서를 "부실한 부분 보강" 요청받을 때
- 사용자가 "쉽게 풀어서 설명", "왜 이렇게 해야 하는지", "EKS랑 뭐가 다른지" 를 물을 때
- 대상 독자가 "ML은 깊게 알지만 이 인프라(HPC/K8s/네트워킹)는 처음"인 경우

## The Insight (하우스 스타일의 핵심)
좋은 AWS 가이드는 **"기능 나열"이 아니라 "왜 이 구조인지 → 어떻게 → 흔한 오해 정정"** 순서다.
초심자 친절과 정확성은 상충하지 않는다: **비유로 직관을 주고, 사실은 라이브 검증으로 못박는다.**

## Document Skeleton (섹션 순서 고정)
1. **머리말 블록** (`>` 인용): 대상 독자 · ⚠️핵심 주의(예: "EKS 전용 기능은 여기 없음") · "모든 사실 라이브 검증 (YYYY-MM)"
2. **§0 TL;DR** — 🔴 **맨 위 한 줄 요약(TL;DR) 먼저**, 그다음 번호 매긴 5~7개 결론. 각 줄은 한 문장 + 근거 키워드. 순서·전제조건 같은 함정은 여기서 미리 경고.
3. **§0.5 기존 Pain Point** — 🔴 §1 "왜?" 앞에, 독자가 *지금* 겪는 문제/한계를 먼저 부각(왜 이 주제를 다시 고민하는지의 동기).
4. **§1 "왜?"** — 기능 설명 전에 *왜 이 방식인가*. 자매 모드/자매 **tier**(EC2 self / HyperPod semi / SageMaker fully)가 있으면 **대조표**(예: EKS vs Slurm, 또는 tier 대조) + **쉬운 비유** + **기술적 3가지 차이**.
4. **본문 §2~** — "쉽게 말하면(그림 한 장 ASCII)" → 단계별 상세 → 표.
5. **❓ 오해 노트** (`>` blockquote): 헷갈리기 쉬운 지점마다 "❓ 흔한 오해: X가 Y라는 뜻? — 아닙니다." 형식. **이게 이 스타일의 시그니처.**
6. **출처표** — `| 주제 | URL |`, 맨 끝에 "라이브 검증 YYYY-MM" + 이전/다음 문서 네비 링크.

## The Approach
1. **대상·범위 확인** — 독자 수준, 자매 문서(EKS/Slurm 등) 존재 여부. 있으면 상호 링크·대조 축을 정한다.
2. **사실 라이브 검증** — 날짜·CLI 플래그·스크립트명·포트·IAM 정책명·GA 여부는 반드시 `docs.aws.amazon.com` + GitHub raw로 확인. (→ `aws-fact-verify` 스킬 위임 권장)
3. **초안 작성** — 위 스켈레톤대로. 비유는 구체적으로(택배/호텔/창고 등), ASCII 다이어그램 1개 이상.
4. **❓오해 노트 삽입** — 사용자가 실제로 헷갈린 지점(또는 헷갈릴 지점)을 blockquote로. 코드/YAML 예시 포함.
5. **넘버링·상호참조 검증** — 섹션 추가/이동 시 `grep -nE "^#{2,4} "`로 중복·누락 확인, `§X.Y` 참조와 자매 문서 앵커가 실재하는지 확인.

## Gotchas (반드시 지킬 것)
- **모드/tier 오귀속 금지** — "A 모드/tier 전용 기능"을 B 문맥에 쓰지 말 것. **모드 예**: Managed Tiered Checkpointing·Task Governance·`hyp` CLI 는 HyperPod **EKS 전용**(Slurm 아님). **tier 예**(라이브 검증 2026-07): SageMaker deployment guardrails(blue/green·canary)는 **SageMaker classic 전용**(HyperPod 아님) · Serverless엔 **GPU 없음**(현재 기준) · **DLC(workload 컨테이너)와 DLAMI(노드 host 이미지) 구분**, DLC는 managed 전용 아님(EC2/EKS서도 실행) · ParallelCluster도 노드 자동교체 있음(차이는 관리주체·health-check 깊이). 검증 단계에서 집중 확인.
- **상단 3요소 필수** — 모든 가이드는 TL;DR(한 줄) · Why · 기존 Pain Point 를 상단에 배치.
- **AWS 마케팅 수치는 "AWS 주장"으로 명시** — 고객 공유 시 출처 밝히기.
- **빠르게 변하는 값(⚠️ 표시)** — AMI 버전·GA URL·리전 가용성은 "배포 전 현행 문서 재확인" 문구.
- **섹션 재번호** — 앞에 섹션을 끼워 넣으면 뒤 번호·TL;DR 상호참조(§3→§4 등)·서브섹션(3.x→4.x)까지 전부 갱신.
- **추측 금지** — 확인 못 한 사실은 "confirmed"로 쓰지 말고 open question으로 표시.

## Example
```
사용자: hyperpod-slurm observability 구성을 쉽게 설명해줄래? 기존 문서가 부실함
→ 1) 기존 07-observability-cli.md + 자매 EKS 문서 읽기
   2) docs.aws + awslabs/awsome-distributed-ai README 라이브 검증
   3) §1 "왜 Slurm은 1-click이 안 되나"(비유+대조표) 신설, §3 4단계로 확장
   4) ❓"Docker로 설치가 로컬 뜻?" · ❓"CFN 출력을 읽어 배선이 뭔뜻?" 오해노트
   5) 넘버링 재정렬 + 출처표 갱신
```

## Related
- `aws-fact-verify` / `aws-fact-checker` — 사실 라이브 검증(이 스킬이 §검증 단계에서 호출; 에이전트 lane은 aws-fact-checker)
- `aws-architecture-decision` — 옵션 비교·의사결정 문서(가이드가 아니라 "골라줘"일 때)
- `aws-compute-platform-selector` — 가이드가 아니라 "EC2/HyperPod/SageMaker 어느 tier?" 플랫폼 선택일 때
- `sagemaker-deep-dive` — 주제가 SageMaker 완전관리형 심화일 때
- `aws-ml-lab-code` — 가이드에 붙일 실습 코드/노트북이 필요할 때
- `aws-slide-deck` — 완성된 가이드를 슬라이드로
