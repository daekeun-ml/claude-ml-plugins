---
name: bedrock-agentic-integration
description: Generate agentic-loop code that wires a fine-tuned SLM hosted on a SageMaker endpoint together with Amazon Bedrock Claude as the reasoning LLM. Strands Agents first (Bedrock is its default provider), LangGraph as an option, and AgentCore Runtime as the production deploy target. The SageMaker endpoint is wrapped as a tool (boto3 sagemaker-runtime invoke_endpoint), Bedrock Claude is called via bedrock-runtime Converse with an inference-profile model id. Use when a fine-tuning asset needs an agent loop on top of its endpoint, or when integrating a SageMaker endpoint with Bedrock/Strands/LangGraph/AgentCore.
allowed-tools: Read, Write, Edit, Bash, WebFetch, WebSearch, Skill
argument-hint: "<strands|langgraph> [--agentcore] <endpoint name/role>"
triggers: ["agentic", "strands", "langgraph", "agentcore", "에이전트 연동", "bedrock 연동", "agent loop", "에이전트 루프", "슬램 에이전트"]
level: 2
---

# Bedrock Agentic Integration — SLM endpoint + Bedrock Claude agentic loop

파인튜닝한 SLM(SageMaker endpoint)과 Bedrock Claude를 엮어 **agentic loop** 코드를 생성.
**Strands 우선 + LangGraph 옵션 + AgentCore 배포**. 보통 `sagemaker-e2e-finetune` 게이트7에서 호출.

## When to Activate
- endpoint에 올린 SLM을 tool/전문가로 쓰고 reasoning은 Bedrock Claude로 하는 에이전트가 필요할 때.
- "Strands/LangGraph로 연동", "AgentCore 배포" 요청.

## The Insight
핵심 아키텍처: **SageMaker endpoint = 특화 도구/전문 모델**(fine-tuned SLM), **Bedrock Claude = 범용 reasoning/오케스트레이션**.
둘은 **별개 서비스·별개 클라이언트**(→ verified-facts). 에이전트 프레임워크가 이 둘을 tool-use 루프로 묶는다.

## 아키텍처 패턴 (근거: sagemaker-e2e-finetune/verified-facts-2026-07.md)
```
[Strands/LangGraph Agent]
   reasoning LLM = Bedrock Claude (bedrock-runtime Converse, inference-profile id)
   tool         = call_slm() → boto3 sagemaker-runtime invoke_endpoint (fine-tuned SLM)
        └─(prod)─▶ AgentCore Runtime 배포 (세션 격리·서버리스)
```
- **endpoint 호출**(tool): `boto3.client("sagemaker-runtime").invoke_endpoint(EndpointName=..., Body=...)`.
- **Bedrock Claude**(reasoning): `boto3.client("bedrock-runtime").converse(modelId="<inference-profile-id>", messages=..., system=..., inferenceConfig=...)`. 모델ID는 prefix(`us.`/`eu.`/`apac.`/`global.`) 붙은 profile — **파라미터/env, 하드코딩 금지**.

## 세 경로
### Strands (기본)
```python
# pip install strands-agents strands-agents-tools  (py3.10+)
from strands import Agent, tool

@tool
def call_slm(text: str) -> str:
    """Fine-tuned SLM(SageMaker endpoint) 호출."""
    import boto3, json
    r = boto3.client("sagemaker-runtime").invoke_endpoint(
        EndpointName="<ENDPOINT_NAME>", ContentType="application/json",
        Body=json.dumps({"inputs": text}))
    return r["Body"].read().decode()

agent = Agent(model="<bedrock-inference-profile-id>", tools=[call_slm])  # Bedrock이 Strands 기본 프로바이더
agent("고객 문의를 분류하고 요약해줘: ...")
```
### LangGraph (옵션)
- `langgraph` StateGraph로 노드(reason=Bedrock Converse, act=call_slm) 구성. Bedrock은 `langchain-aws`/`ChatBedrockConverse` 또는 boto3 직접.

### AgentCore (프로덕션 배포)
- Strands/LangGraph 에이전트를 **AgentCore Runtime**에 배포(세션 microVM 격리). Gateway로 tool을 MCP화, Memory/Identity/Observability 결합. ⚠️ 일부 컴포넌트 preview — 배포 전 리전·GA 재확인.

## 관측·정리 (billable)
- **CloudWatch 링크**: agent 루프는 endpoint(SageMaker Endpoints 로그/메트릭) + Bedrock(model-invocation logging) 이중 호출 → 둘 다 CloudWatch 다이렉트 링크 출력(`[[aws-handson-testing]]` 규칙 `cw_links` 관용구 + Bedrock invocation logging).
- **정리**: SageMaker endpoint는 상시 리소스 → **teardown 필수**(`predictor.delete_endpoint()`). Bedrock Converse 호출 자체는 상시 리소스를 안 남김(과금은 호출량 기준) → teardown 불필요하나 **호출량·비용을 CloudWatch로 관찰**. AgentCore 배포 시 Runtime 리소스 정리.

## Gotchas
- **endpoint ≠ Bedrock**: `sagemaker-runtime`(endpoint)와 `bedrock-runtime`(Claude)는 **별개 클라이언트**. "endpoint를 Bedrock API로 호출" ❌.
- **inference profile 필수**: bare 모델ID는 HTTP400. prefix 붙은 profile id를 파라미터로. 모델 로스터 하드코딩 금지.
- **SDK 빠른 변화**: Strands v1.x·AgentCore·LangGraph API는 자주 바뀜 → **작성 전 문서 검증**(`aws-fact-checker`), 미검증 `# TODO verify`.
- **과금·cleanup**: 에이전트 루프는 endpoint+Bedrock 이중 과금. 스모크는 최소 호출 + endpoint teardown 안내. AgentCore 리소스 정리.
- **시크릿·경로 하드코딩 금지**(role/endpoint/region 플레이스홀더·env). 이식성.

## Example
```
스펙: 분류 SLM endpoint + 간단 agentic
→ Strands Agent(model=Bedrock Claude profile, tool=call_slm(invoke_endpoint))
  → 로컬 스모크(최소 호출) → (선택) AgentCore Runtime 배포 스캐폴드 + 리전/GA 재확인 노트
  → 과금 경고 + endpoint cleanup 안내
```

## Related
- `sagemaker-e2e-finetune` — 게이트7에서 이 스킬 호출.
- `sagemaker-finetune-lab` — 여기서 만든 endpoint를 tool로 사용.
- `sagemaker-deep-dive` — endpoint/Bedrock 서비스 경계.
- `aws-fact-checker` / `aws-fact-verify` — Strands/LangGraph/AgentCore·Bedrock 사실 검증.
- 사실 근거: `sagemaker-e2e-finetune/verified-facts-2026-07.md`.
