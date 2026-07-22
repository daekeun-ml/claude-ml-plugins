#!/usr/bin/env bash
# Emit this plugin's rules as SessionStart additionalContext.
# (SessionStart does not support prompt-type hooks; command-type + JSON stdout is the supported path.)
cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "[aws-sagemaker-toolkit rules — always apply to AWS ML infra work]\n\nRouting: prose/guides/decisions → aws-solutions-architect; lab code/notebooks → aws-ml-engineer; E2E finetune assets → sagemaker-finetune-engineer; agentic code → agentic-integration-engineer; fact verification → aws-fact-checker (read-only). Author↔verify lanes stay separate — never self-approve your own facts.\n\nTier accuracy (no misattribution): EC2(self) / HyperPod(semi, Slurm·EKS) / SageMaker(fully). Known traps: SageMaker deployment guardrails (blue/green·canary) are SageMaker-classic only (NOT HyperPod); Serverless Inference has NO GPU (as of now); Batch Transform is a job, not an endpoint; DLC (workload container) ≠ DLAMI (node host image), and DLC is not managed-only; ParallelCluster DOES auto-replace nodes (the HyperPod differentiator is control-plane ownership + deep health checks + auto-resume); SageMaker endpoint (boto3 sagemaker-runtime invoke_endpoint) ≠ Bedrock (bedrock-runtime Converse) — separate clients; Bedrock Claude needs an inference-profile-prefixed model id (us./eu./apac./global.), never hardcode a static model roster.\n\nFacts: never write a guessed fact as confirmed; mark fast-changing values (region/GA/limits/pricing/model IDs/agent SDK APIs) as 'as of now, re-verify'; unverified code API → '# TODO verify'. All guides open with TL;DR (one line) → existing Pain Point → Why. Attach both docs.aws.amazon.com and official GitHub links in sources. Lab code: tier-idiom no-mixing, placeholders not secrets, mandatory cleanup cell (avoid GPU/endpoint billing), CloudWatch direct links. Language: Korean prose, English for service/API/identifier names; notebooks beginner-friendly, scripts precise.\n\nFull rule text ships in this plugin's rules/ directory (aws-authoring, aws-handson-testing, code-style, communication, fact-integrity, sagemaker-e2e). See the plugin README for enabling them as always-on @import rules in your own CLAUDE.md."
  }
}
JSON
exit 0
