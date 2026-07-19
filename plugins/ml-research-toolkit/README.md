# ML Research Toolkit

*English · [한국어](README_ko.md)*

A Claude Code plugin for VLM/LLM paper research. It bundles skills and subagents for every stage of the research pipeline: ideation → literature review → experiment design → training diagnostics → evaluation → interpretability → paper writing → review response. Prose is Korean; technical terms, libraries, and APIs stay in English.

---

## Skills (21) — by research stage

### Ideation · literature
| skill | what it does |
|---|---|
| `idea-brainstorming` | Maps a problem onto orthogonal novelty axes, generates candidate ideas, and stress-tests them against competing work. |
| `deep-interview` | A Socratic deep interview that crystallizes a vague idea into a concrete experiment spec (mathematical ambiguity gating). |
| `paper-lookup` | Surveys prior art for a specific claim/method across Semantic Scholar, arXiv, and OpenReview. |
| `related-work-miner` | Designs Related Work as a *taxonomy of positions* (not a list), with a differentiation sentence per cluster. |
| `arxiv-verify` | Confirms arXiv/ACL/venue metadata (authors, year, venue, arXiv ID) against the source before you cite. |
| `citation-workflow` | Verifies and fetches BibTeX via Semantic Scholar/arXiv/DOI, marking unresolvable entries as PLACEHOLDER. |

### Experiment design · compute
| skill | what it does |
|---|---|
| `ablation-matrix` | Builds a fair, compute-efficient ablation matrix for a multi-component experiment and flags confounds. |
| `compute-budget-planner` | Estimates GPU-hours/FLOPs/wall-clock for an experiment portfolio under a fixed budget and proposes a Pareto subset. |
| `seed-variance` | Computes mean/std/bootstrap 95% CI/paired significance across seeds and judges whether a result is robust. |
| `counter-example-search` | Actively searches for counter-examples before an interpretability claim is promoted to "strong evidence", quantifying the rate. |

### Training diagnostics
| skill | what it does |
|---|---|
| `ckpt-health-check` | Runs the Check 1–4 diagnostic on a checkpoint (loss/gate/representation/data-masking) with pass/warn/fail verdicts before you spend eval time. |
| `device-audit` | Finds `nn.Module`/buffer/parameter instances not moved to the target device in training code. |

### Paper writing · figures
| skill | what it does |
|---|---|
| `ml-paper-writing` | Writes NeurIPS/ICML/ICLR/ACL/EMNLP/CVPR papers (includes references/·templates/). |
| `abstract-writer` | Structures the Abstract·Intro so every sentence maps to one of {problem, gap, one-line method, main result, impact}. |
| `claim-evidence-map` | Links every claim across the paper to a table cell / figure panel / appendix, flagging broken links and orphan claims. |
| `figure-storyboard` | Enforces (one-line message · visual grammar · evidence pointer · caption draft) per figure and detects redundancy. |
| `svg-flowchart` | Generates dark-theme SVG flowcharts for ML/VLM architecture pipelines. |
| `notation-consistency` | Scans cross-section notation inconsistencies (variable reuse, dimension, index collisions, undefined symbols) and emits a symbol table. |
| `latex-polish` | Polishes LaTeX sources to top-tier submission standard (math-mode, citation, macro, spacing, floats). |

### Review response
| skill | what it does |
|---|---|
| `reviewer-angle` | Generates ≥5 likely reviewer objections with 1–3-sentence responses (baseline fairness, OOD leakage, seed variance, etc.). |
| `rebuttal-drafter` | Classifies reviewer comments (factual/methodological/clarity/out-of-scope) and drafts an evidence-mapped rebuttal. |

## Subagents (12)
| agent | what it does |
|---|---|
| `research-ideator` | Takes a problem + constraints, maps novelty axes, scores candidates, and returns a top-3 shortlist. |
| `literature-scout` | Orchestrates arXiv·Semantic Scholar·OpenReview into a dedup'd survey report with a citation graph. |
| `paper-scout` | Produces a structured per-paper summary (TL;DR, contribution, method, results, relevance, limitations). |
| `experiment-designer` | Turns a hypothesis into a falsifiable spec with baselines, ablation axes, controls, and success criteria. |
| `compute-planner` | Converts an experiment portfolio into GPU-hour cost cards + a dependency DAG, proposing cuts when over budget. |
| `training-diagnostician` | Inspects loss curves, gradients, activations, gate, and engram usage to detect underfit/overfit/collapse. |
| `vqa-eval-analyst` | Breaks down benchmark results (ChartQA/ScienceQA/TextVQA, …) by domain/question-type and runs statistical tests + error analysis. |
| `interpretability-researcher` | Produces interpretability artifacts — logit-lens, gate α heatmaps, codebook probing, attention patterns. |
| `academic-writer` | Drafts Method/Experiments/Related Work in publication-grade English with claim-evidence mapping. |
| `paper-architect` | Checks structural integrity across three passes: figure storyboard, related-work taxonomy, claim-evidence map. |
| `tex-polisher` | Checks and fixes mechanical + notation consistency in LaTeX sources. |
| `rebuttal-writer` | Numbers and classifies reviewer comments and drafts evidence-mapped replies within the venue character budget. |

## Rules (3) — `rules/`

Common rules applied across all research output (AWS-specific rules live only in the sibling plugin, not here).
- `fact-integrity` — fact/citation integrity: never write an unconfirmed item as confirmed, prefer primary sources, delegate verification to `arxiv-verify`/`citation-workflow`.
- `code-style` — code style: match surrounding code, fix seeds for reproducibility, beginner-friendly notebooks.
- `communication` — tone & language: Korean-first, English for terms, no overclaiming.

## Install

```
/plugin marketplace add daekeun-ml/claude-ml-plugins
/plugin install ml-research-toolkit@daekeun-ml-plugins
```

Local testing (one session, no install):
```
claude --plugin-dir ./plugins/ml-research-toolkit
```

### ⚠️ Loading rules
Claude Code plugins do not auto-load `CLAUDE.md`/`@import`. This plugin (1) injects the core rules (fact/citation integrity, code style, communication) via a SessionStart hook, and (2) ships the full text under `rules/`. For always-on loading, add the following to your own `~/.claude/CLAUDE.md` (outside any managed block such as OMC):
```
@<plugin install path>/rules/fact-integrity.md
@<plugin install path>/rules/code-style.md
@<plugin install path>/rules/communication.md
```

## Notes
- Some skills/agents carry phrasing specific to **memory-augmented VLM research (e.g. VisEngram)** — such as gate α·engram in `ckpt-health-check`. They apply to general VLM/LLM research too, but project-specific terms may need adjusting.
- Agents specify `model: opus/sonnet` routing — this works on standard Anthropic API environments; on non-standard providers (Bedrock/Vertex, etc.) it is inherited from or ignored in favor of the parent session model.
- For fine-tuning / AWS infrastructure assets, see the sibling plugin `aws-sagemaker-toolkit`.

## License
MIT
