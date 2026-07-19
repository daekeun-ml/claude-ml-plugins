---
name: ckpt-health-check
description: Run the Check 1–4 training-health diagnostic on a VisEngram (or similar memory-augmented VLM) checkpoint — loss/optimization, gate-α & engram health, representation, data/masking. Produces pass/warn/fail verdicts with numeric evidence, saves plots to eval_plots/, and returns a trust verdict before downstream evaluation. Use before burning GPU time on VQA evaluation.
argument-hint: "<checkpoint path>, <log path>"
level: 3
---

<Purpose>
A checkpoint can train with a clean loss curve but have a fatally inert memory module (gate α saturated at 0, dead engram slots, broken answer mask). Downstream VQA numbers from such a checkpoint are misleading: they reflect the base VLM alone, not the proposed method. This skill enforces a four-check diagnostic before any checkpoint is trusted for claim-bearing evaluation.
</Purpose>

<Use_When>
- training-diagnostician is asked to assess a new checkpoint
- A training run finished but results "look too clean" or "look wrong"
- Before launching a multi-benchmark evaluation that will be cited in the paper
- Comparing two checkpoints where only one "should" have changed
</Use_When>

<Do_Not_Use_When>
- Checkpoint is a known-good published baseline being used only as reference
- The user is debugging training code itself, not evaluating a run (use debugger instead)
- No checkpoint or log path is available — skill requires ground truth
</Do_Not_Use_When>

<Why_This_Exists>
Silent failure is the most expensive failure mode. A gate stuck at α≈0 is mathematically equivalent to not having the memory module at all, but the loss curve reveals nothing. Without a routine diagnostic, weeks of downstream eval get built on a checkpoint that proves nothing about the proposed method. Four targeted checks catch this in minutes.
</Why_This_Exists>

<Execution_Policy>
- Read checkpoint files only — never overwrite
- Every check returns pass / warn / fail with a specific numeric threshold
- Every plot is saved to `eval_plots/checkN_<ckpt_tag>.png` and the filepath is reported
- On warn/fail: emit ≥2 ranked root-cause hypotheses with verification probes
- Do NOT recommend relaunching training without user approval
</Execution_Policy>

<Steps>
1. Confirm paths. Print the exact checkpoint path and step; print the log path. Abort if either is missing.

2. **Check 1 — Loss & Optimization**
   - Parse training log for train/val loss trajectory
   - Detect: divergence (val rising while train falls), plateau with high grad norm, NaN/Inf in grad
   - Verdict thresholds:
     - pass: train/val both decreasing, grad norm stable, no NaN
     - warn: grad norm spikes >5x median but no NaN
     - fail: val loss rising for > 20% of training, OR any NaN/Inf

3. **Check 2 — Gate α & Engram Health** (VisEngram-specific)
   - Compute over a held-out batch of 100 samples:
     - α mean, std, fraction saturated low (α<0.05), fraction saturated high (α>0.95)
     - Engram table slot norm distribution, fraction of cold slots (norm < 5% of mean)
     - mHC per-cell α correlation matrix; compute mean off-diagonal correlation (low = specialization)
   - Verdict thresholds:
     - fail: α saturated low > 80% OR cold slots > 50% OR off-diag correlation > 0.85
     - warn: α saturated low > 50% OR cold slots > 30%
     - pass: otherwise

4. **Check 3 — Representation**
   - Per layer: hidden state norm mean/std
   - Logit entropy at EOS and mid-sequence; attention entropy across heads
   - Verdict thresholds:
     - fail: hidden norm collapses (min-layer norm < 10% of max-layer norm) OR attention entropy < 0.5 nat on every head
     - warn: logit entropy at EOS < 1.0 nat (indicates over-confident, possibly collapsed generation)
     - pass: otherwise

5. **Check 4 — Data & Masking**
   - Load a batch from the training config; verify:
     - padding mask excludes PAD tokens from loss
     - answer-only loss mask: loss on context tokens is exactly zero
     - image token fraction matches expected range (5–30% typical)
   - Verdict thresholds:
     - fail: non-zero loss on context tokens OR image token fraction outside [0.01, 0.5]
     - pass: otherwise

6. For each warn/fail: list 2–3 ranked hypotheses, each with a one-line verification probe.

7. Save four plots:
   - `eval_plots/check1_<tag>.png` — loss + grad norm
   - `eval_plots/check2_<tag>.png` — α distribution + engram slot norms + cell correlation heatmap
   - `eval_plots/check3_<tag>.png` — per-layer hidden norm + attention entropy
   - `eval_plots/check4_<tag>.png` — masking sanity bar chart

8. Emit overall trust verdict: `trust / trust-with-caveat / do-not-trust`.
</Steps>

<Tool_Usage>
- Read: config files, small logs
- Bash: grep logs for loss history, ls checkpoints
- mcp__ide__executeCode: torch.load, compute statistics, save matplotlib plots
- No Edit/Write to training code without user approval
- Agent(subagent_type="training-diagnostician"): full training-run health diagnostician — inspects loss curves, gradient norms, gate α distributions, engram table utilization, checkpoint comparisons; runs Check 1–4 and emits trust verdict with ranked hypotheses
</Tool_Usage>

<Output_Format>
```
## CKPT Health: <checkpoint path> @ step <N>

| Check | Verdict | Headline |
|---|---|---|
| 1. Loss & Optim | pass/warn/fail | [key number] |
| 2. Gate & Engram | ... | [key number] |
| 3. Representation | ... | [key number] |
| 4. Data & Masking | ... | [key number] |

### Finding(s) on warn/fail
#### [Check N]
- Evidence: [numbers]
- Plot: eval_plots/checkN_<tag>.png
- Hypotheses (ranked):
  1. [hypothesis] — probe: [command / inspection]
  2. ...
- Minimal-change recommendation: [single action]

### Overall Verdict
- **Trust for downstream eval**: yes / yes-with-caveat / no
- **If no**: [what to do before trusting]
```
</Output_Format>

<Examples>
<Good>
Check 2 fail: α mean 0.03, 94% saturated low; engram table cold slots 68%. Hypotheses: (1) gate LR too high — probe: log gate.weight grad_norm over training; (2) gate bias init is negative — probe: print gate.bias tensor; (3) mid-training data has weak n-gram structure — probe: run oracle engram and re-check α. Recommendation: reduce gate LR 10x for next run. Plot saved at eval_plots/check2_v05_step4500.png. Overall: do-not-trust.
</Good>

<Bad>
"Training looks fine overall, gate seems low. Probably ok." No numbers, no plot, no hypotheses, no verdict.
</Bad>
</Examples>

<Final_Checklist>
- [ ] Every check has a numeric verdict against a stated threshold
- [ ] All four plots saved with filepaths reported
- [ ] Warn/fail findings each have ≥2 ranked hypotheses with probes
- [ ] Recommendations change one variable at a time
- [ ] Overall trust verdict stated plainly (yes / caveat / no)
</Final_Checklist>
