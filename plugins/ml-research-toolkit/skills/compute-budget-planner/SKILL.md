---
name: compute-budget-planner
description: Plan GPU-hours / FLOPs / wall-clock for a VLM/LLM experiment portfolio under a fixed compute budget. Converts proposed experiments into cost estimates, flags over-budget portfolios, proposes a Pareto-efficient subset, and builds a schedule with dependencies (mid-train → SFT → eval). Use when deadline is fixed and experiment list is longer than the cluster allows.
argument-hint: "<experiment list>, <GPU inventory (count × type)>, <deadline>, <existing ckpt / results>"
level: 3
---

<Purpose>
Papers ship when the right experiments finish on time, not when every experiment finishes. A typical list of "we should do X" balloons 3× past the deadline budget. This skill converts ideas into dated schedule with explicit GPU-hour costs, then prunes to a Pareto-efficient subset that maximizes claim coverage under the budget.
</Purpose>

<Use_When>
- At project kickoff when experiment list is generated from ablation-matrix / idea-brainstorming
- When deadline is fixed and list > GPU hours available
- Replanning after an experiment fails or is cut
- Rebuttal period with only 48–72h budget
</Use_When>

<Do_Not_Use_When>
- Unconstrained exploration (no deadline)
- Single-experiment debugging (tiny budget)
</Do_Not_Use_When>

<Why_This_Exists>
Three failure modes lose papers to deadlines:
1. **Under-estimating wall-clock** — "mid-training takes ~6h" (actually 14h with resume + data loading).
2. **No dependency graph** — SFT started before mid-train is stable, wastes GPU.
3. **Over-inclusive list** — running every idea dilutes quality; paper ships without main ablation.
A schedule with costs + dependencies + pruning solves all three.
</Why_This_Exists>

<Execution_Policy>
- Every experiment gets (model size, tokens, seeds, eval) → GPU-hour estimate
- Include 30% buffer for overhead (data loading, checkpointing, restarts)
- Build DAG: what depends on what (mid-train before SFT, eval after SFT)
- Claim coverage: which paper claim does each experiment support? Prune experiments that don't map to a claim.
- Output a Gantt-like schedule with "must-have / should-have / nice-to-have" tiers
</Execution_Policy>

<Steps>
1. Intake: experiment list, GPU inventory (e.g., 4 × A100-80G), deadline (date + margin), existing checkpoints / results.

2. For each experiment, estimate:
   - Model size and active params
   - Tokens per step × steps (for training) or samples (for eval)
   - Seeds required (1 for pilot, ≥3 for main claim)
   - Wall-clock on target GPU (use FLOPs ≈ 6 × P × T for LLM training, × 1.3 overhead)
   - GPU-hours = wall-clock × (#GPUs allocated)

3. Build dependency DAG:
   - Mid-training → SFT → Eval
   - Ablation experiments can run in parallel if independent
   - Eval can run in parallel across checkpoints

4. Map each experiment to paper claim:
   - "Main result" / "ablation of component X" / "interpretability Y" / "robustness Z"
   - Experiments with no claim mapping → flag for pruning

5. Budget check:
   - Total required GPU-hours vs available (deadline × GPUs × utilization)
   - If over: triage into must-have / should-have / nice-to-have tiers
   - Must-have = main result + core ablation + 1 interpretability figure backing
   - Should-have = reviewer-predictable ablations (seed variance, hyperparameter sensitivity)
   - Nice-to-have = extras

6. Pareto prune: within over-budget, drop nice-to-have, then should-have not covering reviewer-attack axes.

7. Emit a schedule with date-stamped milestones and remaining buffer.
</Steps>

<Tool_Usage>
- Read: prior run logs (to extract actual wall-clock times), ablation-matrix output
- Bash: nvidia-smi / squeue (if cluster), `du -sh` for ckpt sizes
- Write: emit `compute_plan.md` with schedule + per-experiment cost card
</Tool_Usage>

<Output_Format>
```
## Compute Budget Plan — [project, deadline]

### Inventory
- GPUs: 4 × A100-80G
- Deadline: 2026-05-15 (18 days from today)
- Daily utilization: 20h × 4 = 80 GPU-hours/day
- Total budget: 1440 GPU-hours

### Existing Assets
- ckpt: axial+coord step10000 ✓
- ckpt: qcap_v3 SFT step2000 ✓
- Can reuse for warm-starts

### Experiment Cost Cards

#### EXP-1 (must-have): TAC stage-1 mid-training
- Model: Qwen3-VL-2B + engram
- Tokens: 10k steps × 2048 × 1 batch = 20M tokens training
- Wall-clock est.: 16h on 1 A100 (including 30% overhead)
- GPU-hours: 16
- Claim: "TAC trained from mid-training" (main result)

#### EXP-2 (must-have): TAC SFT
- Resume from EXP-1
- Wall-clock: 4h
- GPU-hours: 4
- Claim: main result on VQAv2

#### EXP-3 (should-have): TAC + QC-AP combined SFT
- Resume from EXP-1
- GPU-hours: 4
- Claim: orthogonality ablation

#### EXP-4 (nice-to-have): seed variance n=3
- GPU-hours: 3 × 4 = 12
- Claim: seed robustness

### Dependency DAG
EXP-1 ──► EXP-2 ──► Eval-1
         └───► EXP-3 ──► Eval-2
EXP-4 (independent, parallel)

### Schedule (Gantt)
| Day | GPU-hours used | Running |
|---|---|---|
| D+0..D+1 | 16 | EXP-1 |
| D+2 | 4 | EXP-2 |
| D+2 | 4 | EXP-3 parallel |
| D+3 | 12 | EXP-4 parallel (3 seeds) |
| D+4 | 4 | Evals |
| D+5..D+17 | buffer / rebuttal prep | — |

### Budget Summary
- Required: 40 GPU-hours
- Buffer: 1400 GPU-hours for reruns / rebuttal experiments
- Status: on-budget ✓

### Claim Coverage Matrix
| Paper claim | Experiment | Status |
|---|---|---|
| TAC improves SFT | EXP-2 | planned |
| TAC and QC-AP orthogonal | EXP-3 | planned |
| Results robust across seeds | EXP-4 | planned |
| TAC anchor is interpretable | [existing, no cost] | done |

### Verdict
- on-budget / over-budget (prune N items) / needs-more-GPUs
```
</Output_Format>

<Examples>
<Good>
9 proposed experiments for 5-day deadline on 4 GPUs. Cost-carded → 280 GPU-hours needed vs 400 available. 2 nice-to-have dropped; remaining 7 scheduled with 120h buffer for rebuttal experiments. Every experiment mapped to a claim; 1 had no mapping and was dropped.
</Good>

<Bad>
"You need lots of GPUs, it'll be tight." No numbers, no DAG, no claim mapping.
</Bad>
</Examples>

<Final_Checklist>
- [ ] Every experiment has GPU-hour cost card
- [ ] Overhead buffer ≥ 30% applied
- [ ] Dependency DAG explicit
- [ ] Each experiment mapped to a paper claim
- [ ] Tiered: must-have / should-have / nice-to-have
- [ ] Schedule with dated milestones
- [ ] Buffer remaining for rebuttal
- [ ] Verdict (on-budget / over-budget)
</Final_Checklist>
