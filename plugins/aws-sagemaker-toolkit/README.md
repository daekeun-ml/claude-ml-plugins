# AWS SageMaker Toolkit

*English · [한국어](README_ko.md)*

A Claude Code plugin for the day-to-day work of an AWS AI/ML Solutions Architect. It bundles everything from compute-platform selection to guide authoring, hands-on code generation, an end-to-end fine-tuning pipeline, and fact verification. It holds to three principles:

- **Clear 3-tier separation**: EC2 (self-managed) / HyperPod (semi-managed, Slurm·EKS) / SageMaker (fully-managed) are kept distinct, and one tier's features are never misattributed to another.
- **Facts before writing**: AWS specs change often, so only facts confirmed against official docs / GitHub — not memory — go into the output.
- **Authoring separated from verification**: the lanes that produce code/docs and the lane that verifies facts are split, so no lane self-approves its own output.

Prose is Korean; service names, APIs, and identifiers stay in English.

---

## Skills (11)

### Platform decision · architecture
| skill | what it does | when to use |
|---|---|---|
| `aws-compute-platform-selector` | Compares EC2 / HyperPod (Slurm·EKS) / SageMaker for a given workload across ops burden, resilience, persistence, cost model, and team skill set, then gives conditional "choose X when…" recommendations. When it narrows to HyperPod, it leads into the Slurm-vs-EKS sub-decision. | "Where should I train/serve?", "EC2 vs HyperPod vs SageMaker?" |
| `aws-architecture-decision` | Turns 2+ architecture options (e.g. self-managed Ingress vs SageMaker Endpoint) into an operational comparison table, separates confirmed facts from uncertain ones, and recommends conditionally — including *why the docs make X look like the default*. | An architecture fork that needs operational trade-offs, not a feature list |

### Guide authoring
| skill | what it does | when to use |
|---|---|---|
| `aws-tech-guide` | Writes beginner-friendly yet accurate AWS technical guides in the "hyperpod docs" house style (TL;DR → plain explanation → detail → ❓misconception notes → verified source table). Enforces contrast tables and "why?" sections. | Study docs, onboarding docs for a service/architecture |
| `sagemaker-deep-dive` | Writes SageMaker (fully-managed) deep-dive guides — Training Jobs (Managed Spot up to 90%, Warm Pools, S3 checkpointing), the four inference options (Real-time/Serverless/Asynchronous/Batch Transform), JumpStart, Studio, DLC vs HyperPod DLAMI — with ❓misconception notes that prevent HyperPod misattribution. | Authoring/expanding SageMaker fully-managed docs |
| `aws-slide-deck` | Converts a finished markdown guide into an AWS-themed PPTX (reInvent dark style, per-option color convention, comparison-table & architecture slides). ⚠️ Depends on the external `myslide` skill (see below). | Turning a doc into a slide deck / PPTX |

### Hands-on code
| skill | what it does | when to use |
|---|---|---|
| `aws-ml-lab-code` | Generates runnable Python scripts and JupyterLab notebooks in the right tier idiom (EC2: torchrun/accelerate, HyperPod Slurm: sbatch+srun, HyperPod EKS: CRD+kubectl, SageMaker: SDK). Grounds code in official example repos, uses placeholders instead of secrets, and mandates a billing-safe cleanup cell. | Sample/hands-on code or a notebook for a specific tier |

### E2E fine-tuning (interview → training → deploy → agentic)
| skill | what it does | when to use |
|---|---|---|
| `sagemaker-e2e-finetune` | **The orchestrator.** A gated interview (deep-interview style) walks you through task definition → HF open-license model/dataset candidates → data sizing & synthetic-data decision → (if needed) synthetic data generation → training (auto-branch: JumpStart for standard, HF DLC for custom/latest) → endpoint deployment → optional agentic loop; it then crystallizes a spec and generates the actual assets via sub-skills. | Building a full E2E fine-tuning asset, not just one training script |
| `sagemaker-finetune-lab` | Generates training→endpoint code via two documented paths — JumpStart (`JumpStartEstimator`, LoRA hyperparameters, `accept_eula` for gated models) or HuggingFace DLC (`sagemaker.huggingface.HuggingFace` + a TRL/PEFT `source_dir` script). Inherits the cleanup / CloudWatch-link / placeholder conventions. | Producing training→deploy code for a specific path |
| `synthetic-data-gen` | Analyzes seed-sample characteristics, then generates instruction data grounded in the seeds via Amazon Bedrock Converse with a groundedness/relevance critique loop. **Asks the user how many examples to generate**, filters PII/duplicates, and saves to a HF dataset. Notes distilabel (via LiteLLM for Bedrock) as an alternative. | When a fine-tuning task lacks enough labeled data and needs augmentation |
| `bedrock-agentic-integration` | Generates agentic-loop code that wraps a SageMaker-hosted SLM as a tool and uses Amazon Bedrock Claude as the reasoning LLM. Strands Agents first, LangGraph optional, AgentCore Runtime for production deploy. | Putting an agent loop on top of an endpoint, or integrating SageMaker↔Bedrock |

### Fact verification
| skill | what it does | when to use |
|---|---|---|
| `aws-fact-verify` | Cross-verifies AWS facts (CLI flags, param names, ports, IAM actions, GA/preview, region availability, service limits) against docs.aws and GitHub raw **before** they go into a doc. Corrects stale/wrong claims, distinguishes confirmed vs uncertain, and stamps a "live-verified YYYY-MM" source table. | Before asserting any AWS fact from memory, or when auditing an existing doc |

## Subagents (5) — 3-lane separation

The three lanes are split so no lane self-approves the facts in its own output.

- **Authoring lane** — `aws-solutions-architect`: writes guides, decision docs, and customer answers in house style, delegating fact-checking to `aws-fact-checker`.
- **Code lane** — `aws-ml-engineer` (per-tier lab code), `sagemaker-finetune-engineer` (E2E fine-tuning assets), `agentic-integration-engineer` (Strands/LangGraph/AgentCore integration). All ground in official examples, keep cleanup/placeholders, and delegate fast-changing APIs to verification.
- **Verification lane** — `aws-fact-checker` (read-only): adversarially re-checks AWS claims and returns confirmed / partially-correct / refuted / uncertain verdicts with corrected statements and source URLs.

## Rules (6) — `rules/`

Rule files applied across all output.
- `aws-authoring` — AWS authoring rules (routing, tier-misattribution guard, source attachment, guide's three openers)
- `aws-handson-testing` — the hands-on testing ladder (GPU/CPU/SageMaker/Docker/endpoint/agentic) + CloudWatch links
- `sagemaker-e2e` — E2E fine-tuning invariants (endpoint↔Bedrock separation, JumpStart vs HF DLC, licensing, synthetic data, cleanup)
- `code-style` — code style (match surrounding code, small diffs, beginner-friendly notebooks)
- `communication` — tone & language (Korean-first, English for terms, no overclaiming)
- `fact-integrity` — fact/citation integrity (never write a guess as confirmed, primary sources, delegate verification)

## Install

```
/plugin marketplace add <owner>/claude-ml-plugins
/plugin install aws-sagemaker-toolkit@daekeun-ml-plugins
```

Local testing (one session, no install):
```
claude --plugin-dir ./plugins/aws-sagemaker-toolkit
```

## ⚠️ Loading rules — important

Claude Code plugins do **not** auto-load `CLAUDE.md` or `@import`. So this plugin provides its rules two ways:

1. **SessionStart hook (automatic)** — injects the core invariant rules (routing, tier-misattribution guards, facts, cleanup) at session start. Works on install alone.
2. **Full rule files (optional, always-on)** — the complete rule text lives in `rules/*.md`. For always-on loading, add the following to your own `~/.claude/CLAUDE.md` (outside any managed block such as OMC):

   ```
   @<plugin install path>/rules/aws-authoring.md
   @<plugin install path>/rules/aws-handson-testing.md
   @<plugin install path>/rules/code-style.md
   @<plugin install path>/rules/communication.md
   @<plugin install path>/rules/fact-integrity.md
   @<plugin install path>/rules/sagemaker-e2e.md
   ```
   (Or copy the rule files into `~/.claude/rules/` and import them with relative `@rules/...`.)

## What is a "fact-verification snapshot"?

The skills in this plugin build code and guides from AWS facts **confirmed in official docs, not recalled from memory**. A "fact-verification snapshot" is that evidence, verified at a point in time and frozen into a file.

- **Where**: `skills/aws-compute-platform-selector/verified-facts-2026-07.md`, `skills/sagemaker-e2e-finetune/verified-facts-2026-07.md`, and the link registry `skills/aws-compute-platform-selector/aws-reference-links.md`.
- **What's in it**: verified facts such as "a SageMaker endpoint and Bedrock are separate services (`sagemaker-runtime` vs `bedrock-runtime`)", "Serverless inference has no GPU", "the JumpStart fine-tuning API signature", "Bedrock Claude requires an inference-profile prefix" — each with its **source URL**.
- **How it was verified**: cross-checked against `docs.aws.amazon.com` + official GitHub raw, then adversarially refuted; only what survived was kept (7/7 confirmed as of 2026-07).
- **What ⚠️ means**: fast-changing values (region, GA status, model IDs). **Re-verify with `aws-fact-verify` before deploying/executing**, and never hardcode them statically.

## External dependencies

- `aws-slide-deck` calls a separate `myslide` skill (the PPTX engine). It is not bundled here, so install `myslide` separately to use the slide feature.
- `bedrock-agentic-integration` / `synthetic-data-gen` deal with external SDKs (Strands/LangGraph/AgentCore, distilabel). They **generate** code; actually running it requires those SDKs plus AWS credentials, and incurs model-call / endpoint costs.

## License
MIT
