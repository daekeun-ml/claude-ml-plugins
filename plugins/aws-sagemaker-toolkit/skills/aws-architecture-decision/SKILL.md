---
name: aws-architecture-decision
description: Produce a decision-ready AWS architecture comparison for 2+ options (e.g. self-managed Ingress vs SageMaker Endpoint, EKS vs Slurm, FSx classes). Builds an operational comparison table (dimension | Option A | Option B), separates confirmed facts from uncertain ones, frames conditional recommendations ("choose A when… / B when…"), and explains "why the docs make X look like the default". Use when a customer/team faces an architecture fork and needs operational trade-offs, not a feature list.
allowed-tools: Read, Write, Edit, WebFetch, Bash, AskUserQuestion
argument-hint: "<option A> vs <option B> [context/constraints]"
triggers: ["아키텍처 비교", "어떤걸 골라", "vs", "트레이드오프", "trade-off", "의사결정", "decision", "운영상 차이", "무슨 차이", "권장안", "어떤 방식"]
level: 2
---

# AWS Architecture Decision Doc — 운영 트레이드오프 & 조건부 권장

두 개(이상)의 AWS 아키텍처 갈림길에서 **운영 관점 비교 + 조건부 권장**을 내는 스킬.
`HyperPod-Inference-Ingress-vs-SageMaker-Endpoint.md` 하우스 스타일을 재현한다.

## When to Activate
- "A랑 B 중 뭘 골라야 하나 / 운영상 어떤 차이가 있나" 류 질문
- 고객이 한쪽으로 기울어 있고, 그 판단이 문서상 기본 시나리오와 달라 보여 조언이 필요할 때
- 옵션이 사실은 "완전히 다른 스택"이 아니라 같은 것의 변형일 때(= false fork 규명 필요)
- ⚠️ **컴퓨트 플랫폼 tier 갈림길(EC2 self / HyperPod semi / SageMaker fully)** 이면 → 이 스킬의 특화판인 **`aws-compute-platform-selector`** 로 위임(tier 스펙트럼·복원력 축이 고정돼 있음).

## The Insight
아키텍처 결정 문서의 가치는 **기능 목록이 아니라 "운영에서 뭐가 다른가 + 언제 무엇을 골라야 하나"** 다.
그리고 자주, 두 옵션은 **완전히 별개가 아니라 같은 것의 토글/변형**이다 — 이 "false fork"를 먼저 규명하면 결정이 저위험이 된다.

## Document Skeleton
1. **§0 TL;DR** — 6대 결론. 특히 (a) false fork 여부, (b) 고객 lean이 맞는지, (c) 흔한 오해 정정.
2. **§1 "두 옵션의 실체"** — 완전 별개인가? 같은 것의 토글인가? ASCII 구조도로 공유 데이터플레인 표시.
3. **운영 비교표** — `| Dimension | Option A | Option B |`. 축: 인증 · 네트워킹/사설접근 · 관측성 · 오토스케일 · 배포/롤아웃 · 프로토콜/스트리밍 · 페이로드/타임아웃 한계 · 비용모델 · 운영부담 · 락인/이식성. **컴퓨트 플랫폼 갈림길이면 tier 축 추가**: 운영부담 · 복원력(누가 노드 교체·health-check 깊이) · 지속성(영속 클러스터 vs ephemeral job).
4. **차별화 큰 축 vs 비차별화 축** — "여기서 결정하라" / "과대평가 말라(양쪽 공통)" 명시.
5. **"왜 문서는 X를 기본처럼 보이게 하나"** — 오해의 근원 설명(예: HyperPod는 본질이 EKS라 ALB가 prereq로 먼저 등장).
6. **권장 로직** — `choose A when… / choose B when…` (조건부, 절대 단정 금지). 이 고객 lean 검증 + 재고 조건.
7. **Open Questions** — 고객/AWS에 확인할 것(리전 가용성·per-request 과금·특정 CRD 필드 등).
8. **출처표** — url + 한 줄 근거.

## The Approach
1. **옵션·제약 확인** — 무엇 vs 무엇, 고객이 기운 쪽, 워크로드 제약(페이로드·프로토콜·규제).
2. **리서치 + 적대적 검증** — 각 옵션을 멀티소스로 조사하고 핵심 사실을 교차검증. (→ `aws-fact-verify`) 규모가 크면 Workflow로 fan-out(옵션별 리서치 → verify → synth).
3. **false fork 판정** — 두 옵션이 같은 오퍼레이터/토글인지 확인(문서·CRD 근거). 맞으면 "저위험·되돌리기 쉬움" 강조.
4. **비교표 작성** — dimension별. 확정 사실은 출처, 불확실은 명시적 플래그.
5. **조건부 권장** — 조건을 **먼저** 쓰고 권장을 뒤에("규제 강하면 → B"). 고객 lean이 합리적이면 확인해주고, 재고 조건(예: raw gRPC 필요)도 병기.

## Gotchas
- **단정 금지, 조건부 권장** — "B 우선 권장" ❌ → "IAM 감사·PrivateLink가 필요하면 → B 권장" ⭕.
- **적대적 검증으로 통념 정정** — 예: "HyperPod 관리형 엔드포인트에 blue/green·canary 가드레일 상속" 은 **틀림**(그건 classic SageMaker 엔드포인트 전용). 통념을 그대로 옮기지 말 것.
- **stale 사실 주의** — 프로토콜 지원 등은 최신 발표(예: bidirectional streaming) 반영. "confirmed/uncertain" 구분.
- **비차별화 축 경고** — 오토스케일·라우팅·관측이 양쪽 공통이면 "여기로 결정하지 말라"고 명시.

## Example
```
사용자: HyperPod를 Ingress로 노출 vs SageMaker Endpoint로 노출, 운영 차이?
→ false fork 규명(같은 오퍼레이터의 sageMakerEndpoint.name 토글)
  → 11축 비교표 → "왜 문서는 Ingress를 기본처럼 보이게 하나"(EKS라서 ALB가 prereq)
  → choose A when(gRPC/대용량/커스텀 라우팅) / B when(IAM·PrivateLink·저운영)
  → 정정: 가드레일은 classic 전용 → open questions(리전·과금)
```

## Related
- `aws-fact-verify` / `aws-fact-checker` — 비교표의 사실 교차검증
- `aws-compute-platform-selector` — 컴퓨트 tier(EC2/HyperPod/SageMaker) 결정 특화판
- `aws-tech-guide` — "골라줘"가 아니라 "가르쳐줘"일 때
- `aws-slide-deck` — 비교표·권장안을 슬라이드로
