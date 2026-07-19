# AWS Authoring Rules

AWS ML 인프라 산출물(가이드·의사결정 문서·슬라이드·실습 코드·고객 답변) 작성 시 항상 적용.

**라우팅** — prose/가이드/결정문서 → `aws-solutions-architect`, 실습 코드/노트북 → `aws-ml-engineer`, 사실 검증 → `aws-fact-checker`(read-only). 3 lane 분리: 작성자가 자기 산출물의 사실을 자기승인하지 말 것. 스킬: 플랫폼 선택 → `aws-compute-platform-selector`, SageMaker 심화 → `sagemaker-deep-dive`, 실습 코드 → `aws-ml-lab-code`, 가이드 → `aws-tech-guide`, 사실 검증 → `aws-fact-verify`.

**tier 정확성** — EC2(self) / HyperPod(semi, Slurm·EKS) / SageMaker(fully) 를 구분하고 **tier/모드 오귀속 금지**. 알려진 함정(2026-07 검증): SageMaker deployment guardrails(blue/green·canary)는 SageMaker classic 전용(HyperPod 아님) · Serverless엔 GPU 없음(현재 기준) · Batch Transform은 endpoint가 아니라 job · DLC(workload 컨테이너)와 DLAMI(노드 host 이미지) 구분(DLC는 managed 전용 아님) · ParallelCluster도 노드 자동교체 있음(차이는 관리주체·health-check 깊이) · HMA-on-Slurm은 2025-09부터.

**사실** — 추측을 confirmed로 쓰지 말 것. 빠르게 바뀌는 값(리전·GA·한계·요금)은 "현재 기준"+"배포 전 재확인" 표기. AWS 마케팅 수치는 "AWS 주장"으로 출처 명시. (상세: [[fact-integrity]])

**가이드 구조** — 모든 가이드는 상단에 ① TL;DR(한 줄) → ② 기존 Pain Point → ③ Why 3요소. 자매 tier는 대조표로. ❓오해 노트로 헷갈리는 지점 정정.

**출처** — 산출물에 **관련 AWS 문서 링크 + 공식 GitHub repo 링크를 전부** 부착("라이브 검증 YYYY-MM" 스탬프). 레지스트리: `aws-compute-platform-selector` 스킬의 `aws-reference-links.md`.

**실습 코드** — tier 관용구 혼용 금지 · 시크릿/로컬 절대경로 하드코딩 금지(플레이스홀더/env) · cleanup 셀 필수(GPU/endpoint 과금 방지) · SDK/CLI/CRD 사실은 검증 위임. 테스트 방법은 [[aws-handson-testing]], 코드 스타일은 [[code-style]].

**언어·이식성** — 설명은 한국어, 서비스/API/식별자는 영어(상세: [[communication]]). 이 스킬/에이전트는 plugin으로 배포되므로 로컬 절대경로 하드코딩 금지, 상호참조는 이름 기반.
