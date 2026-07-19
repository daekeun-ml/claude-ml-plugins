---
name: seed-variance
description: Compute seed-level mean, std, bootstrap 95% CI, and paired significance for a VLM/LLM evaluation result across ≥3 seeds. Labels each reported Δ as robust / marginal / noise based on CI overlap with zero and seed-count rules. Use whenever a method-vs-baseline comparison is about to be cited — no single-seed claim survives review.
argument-hint: "<results json/csv with (model, seed, benchmark, metric)>"
level: 3
---

<Purpose>
Publication-grade VLM/LLM comparisons require variance reporting. A +2pp mean with an unknown std is not an improvement — it could be seed noise. This skill enforces a standard treatment: mean ± std over ≥3 seeds, paired bootstrap CI, and a transparent robust/marginal/noise label.
</Purpose>

<Use_When>
- vqa-eval-analyst is assembling the main results table or an ablation table
- A user wants to decide whether a Δ is paper-worthy
- Before any "method X beats baseline" claim is inserted into paper prose
</Use_When>

<Do_Not_Use_When>
- Only one seed is available — return an error and demand more seeds rather than fabricate variance
- The metric is inherently non-stochastic across seeds (rare; almost always wrong to assume)
- Post-hoc subset selection is being attempted — refuse and explain
</Do_Not_Use_When>

<Why_This_Exists>
Seed variance in VLM evals is large: 1–3pp swings on ChartQA-class benchmarks are common. Reporting a single seed or skipping significance testing is the easiest reviewer objection to anticipate, and the easiest to prevent. This skill gives the analyst a standard, replicable pipeline so every claim gets the same statistical treatment.
</Why_This_Exists>

<Execution_Policy>
- Minimum 3 seeds per condition. If fewer, emit a warning label and refuse to apply the "robust" tag regardless of Δ size.
- Paired bootstrap (1000 resamples) with per-example pairing when per-example outputs are available; otherwise seed-level paired t-test.
- CI at 95%. Any Δ whose CI crosses zero is NOT "robust".
- Significance test statement must include: test name, n, p-threshold, and outcome.
- Never collapse multiple benchmarks into a single average without ALSO reporting per-benchmark.
</Execution_Policy>

<Steps>
1. Load results. Expected columns: `model`, `seed`, `benchmark`, `metric_value`, optional `per_example_scores`.

2. Sanity-check seed count per (model, benchmark). If any cell has < 3 seeds, flag the cell as `low-seed` and continue.

3. For each (benchmark, model) aggregate:
   - Mean and std across seeds
   - Report as `mean ± std (N seeds)`

4. For each pairwise comparison (baseline, method) on each benchmark:
   - If per-example scores available: paired bootstrap of the mean Δ, 1000 resamples, 95% CI
   - Else: seed-level paired t-test; report p-value with n=(seed count)
   - Compute Cohen's d for effect size

5. Label each Δ:
   - **robust**: Δ > 0, 95% CI excludes zero, seeds ≥ 3, Cohen's d ≥ 0.5
   - **marginal**: Δ > 0, CI crosses zero but p < 0.1, OR Cohen's d in [0.2, 0.5)
   - **noise**: |Δ| < seed std OR p ≥ 0.1 OR Cohen's d < 0.2
   - **low-seed**: < 3 seeds (never labeled robust regardless of Δ)

6. Assemble table: per (benchmark × comparison), with mean, std, Δ, CI, p, d, label.

7. Warn explicitly if the user previously cited a Δ without this analysis.
</Steps>

<Tool_Usage>
- Read: load results file
- Bash / mcp__ide__executeCode: numpy / pandas / scipy for bootstrap and t-tests
- Write: save a `variance_report.md` or JSON if the user requests persistence
</Tool_Usage>

<Output_Format>
```
## Seed-Variance Report

### Per-Condition Aggregates
| Model | Benchmark | Mean ± Std | N seeds |
|---|---|---|---|
| Base | ChartQA | 25.1 ± 0.8 | 3 |
| Proposed | ChartQA | 37.2 ± 1.1 | 3 |

### Pairwise Comparisons
| Benchmark | Comparison | Δ | 95% CI | Test | p | Cohen's d | Label |
|---|---|---|---|---|---|---|---|
| ChartQA | Proposed − Base | +12.1 | [10.4, 13.7] | paired bootstrap (1000) | <0.001 | 2.4 | robust |
| TextVQA | Proposed − Base | +0.4 | [−0.9, +1.5] | paired bootstrap | 0.38 | 0.1 | noise |
| VSR | Proposed − Base | +1.1 | [−0.2, +2.4] | paired t (n=3) | 0.09 | 0.4 | marginal |

### Warnings
- [benchmark/condition] has only [N] seeds → cannot label robust

### Claim Guidance
- Claim "Proposed outperforms Base on ChartQA": SUPPORTED (robust)
- Claim "Proposed helps TextVQA": NOT SUPPORTED (noise)
- Claim "Proposed helps VSR": WEAK — ask for more seeds before citing
```
</Output_Format>

<Examples>
<Good>
Input: 3 seeds × 2 models × 4 benchmarks. Output reports per-benchmark mean±std, per-comparison Δ with bootstrap CI, label each as robust/marginal/noise, and gives explicit claim guidance per benchmark.
</Good>

<Bad>
"Proposed is +2pp on average, ship it."
Why bad: No per-benchmark breakdown, no std, no significance test, no CI. Hides potential regressions.
</Bad>
</Examples>

<Final_Checklist>
- [ ] Every cell has seed count printed and ≥3 or flagged low-seed
- [ ] Every Δ has mean, CI, test, p-value, and effect size
- [ ] Labels (robust/marginal/noise/low-seed) applied consistently per rule
- [ ] Per-benchmark breakdown present, not just a mean across benchmarks
- [ ] Explicit claim guidance emitted for the user
</Final_Checklist>
