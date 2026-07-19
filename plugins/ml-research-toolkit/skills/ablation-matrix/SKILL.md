---
name: ablation-matrix
description: Construct a fair, compute-efficient ablation matrix for a multi-component VLM/LLM experiment. Enumerates on/off combinations, flags confounds, matches tuning/compute budgets across conditions, and proposes fractional designs when full factorial is too expensive. Use when designing a new experiment with multiple components (e.g., mHC gate + spatial engram + mid-training) before launching training.
argument-hint: "<components>, <baseline-constraints>, <budget>"
level: 3
---

<Purpose>
Ablation tables are the primary reviewer-facing evidence that a method's components each contribute. Poorly designed ablation matrices either omit critical conditions (reviewers demand them in rebuttal) or include too many (compute wasted). This skill produces a compact, fair, reviewer-proof matrix in one pass.
</Purpose>

<Use_When>
- experiment-designer is specifying a new experiment with ≥2 toggleable components
- User is about to launch training and wants the minimum set of conditions to support claims
- Existing experiment is being audited for missing ablation conditions
</Use_When>

<Do_Not_Use_When>
- Experiment has only one independent variable — trivial, no matrix needed
- User is doing exploratory hyperparameter sweep (use a sweep tool, not an ablation matrix)
- Results already exist and the question is post-hoc analysis — use seed-variance skill
</Do_Not_Use_When>

<Why_This_Exists>
The two ablation failure modes that reviewers attack:
1. **Missing the obvious control** — e.g., claiming mHC helps without a parameter-matched single-gate baseline, so the gain could come from extra parameters alone.
2. **Unfair tuning budget** — proposed method tuned over 20 configs, baseline run with defaults once.

A disciplined matrix construction prevents both by enumerating every on/off combination the paper's claims require, flagging hidden knobs, and equalizing the tuning budget across conditions.
</Why_This_Exists>

<Execution_Policy>
- Full factorial when 2^k ≤ 8; fractional or one-at-a-time when 2^k > 16
- For every "proposed adds parameters" case, include a parameter-matched control variant of the baseline
- Tuning budget must be declared per condition and MUST be identical across conditions (same seeds, same LR search space)
- Each row gets a claim-support tag: which paper claim this row is evidence for (if none, drop the row)
</Execution_Policy>

<Steps>
1. Parse inputs:
   - Components list (e.g., `{mHC gate, spatial engram, mid-training, SFT}`)
   - Known baselines (frozen VLM, prior art)
   - Compute budget (GPU-hours available)
   - Paper claims to support

2. Build the full combination space (2^k rows). For each row, compute expected GPU-hours.

3. Prune rows that support no paper claim:
   - For each row, ask: "which claim breaks if this row is missing?"
   - If none, drop the row.

4. Add controls for confounds:
   - If any component adds parameters → add a parameter-matched baseline variant
   - If any component adds training data → add a data-matched baseline variant
   - If any component adds compute → add a compute-matched baseline variant

5. Check compute fit:
   - If total GPU-hours > budget, apply fractional factorial (resolution IV) OR reduce to one-at-a-time ablation with justification.

6. Declare tuning budget per condition:
   - Same LR search, same seeds (≥3), same data, same steps
   - State explicitly in the output

7. Tag each row with its supporting claim.

8. Emit the matrix as markdown table + compute budget + fairness attestation.
</Steps>

<Tool_Usage>
- Read: examine existing experiment configs to extract the current component list and budget conventions.
- Bash: inventory existing checkpoints/runs to avoid duplicating conditions already completed.
- Agent(subagent_type="experiment-designer"): convert the pruned matrix rows into full falsifiable experiment specs with baselines, control variables, and evaluation protocols
- Agent(subagent_type="compute-planner"): estimate GPU-hour cost per row, build dependency DAG, and flag over-budget portfolios with a Pareto-efficient subset
</Tool_Usage>

<Output_Format>
```
## Ablation Matrix: [experiment id]

### Components
- A: [name, short description]
- B: ...

### Matrix
| # | A | B | C | D | Seeds | GPU-hrs | Supports claim |
|---|---|---|---|---|---|---|---|
| 1 | ✗ | ✗ | ✗ | ✗ | 3 | ... | Baseline reference |
| 2 | ✓ | ✗ | ✗ | ✗ | 3 | ... | Claim 1: A alone helps |
| ... | ... | ... | ... | ... | ... | ... | ... |

### Controls for Confounds
| Control | Why needed | Matrix row # |
|---|---|---|
| Param-matched single-gate | mHC adds params | row 2b |

### Tuning Budget (applied to every row)
- LR search: [set]
- Seeds: N
- Data: [dataset, size]
- Steps: mid-training X, SFT Y

### Compute Summary
- Total GPU-hours: X
- Fits budget (Y hrs)? yes/no
- Design type: full factorial / fractional (resolution IV) / one-at-a-time

### Fairness Attestation
- All conditions share [list of shared settings]
- Known asymmetries: [list, with justification]

### Dropped Rows (no claim supported)
- [row config] — dropped because [reason]
```
</Output_Format>

<Examples>
<Good>
Input: Components {mHC, spatial, mid-training}, budget 120 GPU-hrs, claims {mHC>single-gate, spatial helps VSR, mid-training essential}.
Output matrix includes: baseline (frozen VLM), single-gate, mHC, mHC+spatial, mHC w/o mid-training, param-matched single-gate control. 6 rows × 3 seeds × 6 GPU-hrs = 108 GPU-hrs. Each row tagged with claim supported. Flags: mHC has more params than single-gate → param-matched control added.
</Good>

<Bad>
Output matrix: "Run baseline, run proposed, compare." No component decomposition, no confound controls, no tuning budget declaration, no seeds.
Why bad: Cannot attribute gains to specific components; reviewers will reject.
</Bad>
</Examples>

<Final_Checklist>
- [ ] Every row supports at least one claim
- [ ] Every parameter/data/compute asymmetry has a matched control
- [ ] Tuning budget is declared and identical across rows
- [ ] Seed count ≥3 per row (or explicit justification if fewer)
- [ ] Total compute fits budget (or fractional design justified)
- [ ] Fairness attestation lists shared settings and any remaining asymmetries
</Final_Checklist>
