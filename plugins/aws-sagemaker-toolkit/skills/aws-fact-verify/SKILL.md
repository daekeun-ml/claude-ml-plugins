---
name: aws-fact-verify
description: Live-verify AWS facts before writing them into a guide, slide, or customer answer — CLI flags, script/param names, ports, IAM policy/action names, GA vs preview status, region availability, service limits. Cross-checks docs.aws.amazon.com against GitHub raw sources, works around JS-rendered doc pages, corrects stale/wrong claims, labels confirmed vs uncertain, and stamps a "라이브 검증 YYYY-MM" source table. Use before asserting any AWS fact from memory, or when auditing an existing doc for hallucinated/outdated details.
allowed-tools: WebFetch, Bash, Read, Grep, Workflow
argument-hint: "<claim or topic to verify> [source URLs]"
triggers: ["라이브 검증", "사실 확인", "verify", "출처 확인", "최신 맞아", "fact check", "이거 맞아", "GA 여부", "리전 가용"]
level: 2
---

# AWS Fact Verify — 라이브 교차검증

AWS 사실을 가이드/슬라이드/고객 답변에 쓰기 **전에** 공식 소스로 검증하는 스킬.
"training-data recall만으로는 부족하다"는 원칙. 특히 빠르게 바뀌는 값에 필수.

## When to Activate
- CLI 플래그·스크립트/파라미터명·포트·IAM 정책/액션명·GA/preview·리전·서비스 한계(payload/timeout 등)를 문서에 쓰기 직전
- 기존 문서에 hallucinate/outdated 사실이 없는지 감사할 때
- 사용자가 "이거 최신 맞아?", "출처 확인해줘" 라고 할 때

## The Insight
AWS는 분기마다 바뀐다. **기억으로 단정하지 말고, 1차 소스(공식 문서/공식 GitHub)로 못박는다.**
그리고 docs.aws 페이지는 JS 렌더링이라 종종 안 읽히므로 **우회 경로**가 필요하다.

## The Approach
1. **주장 분해** — 검증할 사실을 원자 단위로(예: "InvokeEndpoint 최대 페이로드 6MiB", "Slurm HMA는 2025-09-11부터").
2. **1차 소스 선택** — `docs.aws.amazon.com`(dg/APIReference) + 공식 GitHub(`awslabs/*`, `aws/*`, `aws-samples/*`)의 **raw** 파일. 마케팅 블로그는 보조.
3. **교차검증** — 최소 2소스. 문서와 실제 repo(CRD/스크립트/config)가 일치하는지.
4. **적대적 태도** — 통념을 refute 시도. 틀리면 corrected_statement + 근거.
5. **분류·표기** — confirmed(출처 url) / partially-correct / refuted / uncertain. uncertain은 open question으로.
6. **출처표 스탬프** — `| 주제 | URL |` + "라이브 검증 YYYY-MM".

## JS-rendered docs 우회 (중요)
docs.aws.amazon.com WebFetch가 제목만 반환(=JS 렌더)하면:
1. **GitHub raw로 우회** — `https://raw.githubusercontent.com/<org>/<repo>/main/<path>` (README·CRD·스크립트·config는 여기서 원문 확인).
2. **API Reference 페이지**는 비교적 잘 읽힘 — 한계값(payload/timeout)·IAM 액션은 여기서.
3. **What's New / 블로그**로 날짜·GA 보강(단, 날짜는 mixed-reliability → 가능하면 1차).
4. 규모가 크면 **Workflow로 fan-out** — 주장별 병렬 검증 → 각각 refute 시도 → synth.
5. 그래도 확인 안 되면 **"uncertain, 배포 전 현행 문서 재확인" 으로 명시** (절대 confirmed로 쓰지 말 것).

## Gotchas
- **owner/repo 변경 추적** — 예: `aws-samples/awsome-distributed-training` → `awslabs/awsome-distributed-ai`로 이동. 링크 치환 시 owner+repo 둘 다, 딥링크 경로 구조 유지 확인.
- **모드/tier 오귀속** — EKS 전용 기능을 Slurm에 귀속하는 통념, 그리고 **tier 오귀속** 집중 검증(라이브 검증 2026-07 기준 알려진 함정): SageMaker guardrails(blue/green)는 classic 전용(HyperPod 아님) · Serverless GPU 없음(현재 기준) · DLC(workload)와 DLAMI(노드 host) 혼동 + DLC는 managed 전용 아님 · ParallelCluster도 노드 자동교체 있음(차이는 관리주체·health-check 깊이) · HMA-on-Slurm은 2025-09부터.
- **"항상 X" 류 과일반화** — 예외 조건 확인(예: "auto-resume이면 항상 교체" → 실은 *하드웨어 결함일 때만*, 소프트 결함은 재부팅).
- **stale 열거** — 프로토콜/기능 목록은 최신 발표 누락 여부 확인.
- **숫자 단위** — 6MiB(6291456B) vs 6MB, 처리량 MB/s/TiB 등 단위 정확히.

## Example
```
주장: "HyperPod 관리형 엔드포인트는 blue/green·canary 가드레일 상속"
→ docs deployment-guardrails.html(JS막힘→API/문서 텍스트 확보): "Async/Real-time endpoint에만 적용, Create/UpdateEndpoint API 경유"
→ HyperPod는 kubectl CRD로 배포(Create/UpdateEndpoint 안씀) → refuted
→ corrected: "가드레일은 classic 전용, HyperPod는 K8s 롤링 업데이트만"
```

## Related
- `aws-fact-checker` — 이 스킬과 같은 방법론의 **read-only 에이전트 lane**(작성↔검증 분리 시 검증 담당)
- `aws-tech-guide` / `aws-architecture-decision` / `aws-compute-platform-selector` / `sagemaker-deep-dive` / `aws-ml-lab-code` — 이 스킬을 검증 단계에서 호출
- `arxiv-verify` / `citation-workflow` — 논문 인용 검증(다른 도메인, 같은 발상)
