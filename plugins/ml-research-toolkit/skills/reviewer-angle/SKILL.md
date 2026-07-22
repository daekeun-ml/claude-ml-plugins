---
name: reviewer-angle
description: 'Generate ≥5 likely reviewer objections to a VLM/LLM paper draft section and draft 1–3 sentence responses for each. Targets the common VLM reviewer attack vectors: fairness of baseline, OOD leakage, seed variance, cherry-picked benchmarks, unsupported superlatives, missing ablation, causal overclaim. Use before declaring a draft section "done".'
argument-hint: "<draft section path or inline text>, <evidence inventory>"
level: 3
---

<Purpose>
Reviewers are adversarial readers. Papers fail not because the work is bad but because the prose makes the work look weak, overclaimed, or unfair. This skill forces the writer to adopt a reviewer's stance before submission: enumerate the objections a reviewer would raise and prepare a response for each — either by hardening the prose, adding a footnote, or logging a TODO for additional experiments.
</Purpose>

<Use_When>
- academic-writer has a draft section and is about to mark it "ready"
- Before camera-ready submission
- During rebuttal preparation (same logic, different audience)
- When the user asks "how would a reviewer attack this?"
</Use_When>

<Do_Not_Use_When>
- The draft is a first sketch — wait until it has claim-evidence mapping before reviewer-proofing
- The task is blog prose or informal writing — lower bar, skip this skill
- The user wants only a grammar/style polish — use a different workflow
</Do_Not_Use_When>

<Why_This_Exists>
Two failure modes at review:
1. **Weak defense against predictable attacks** — every VLM paper gets "is the baseline fair?" and "how many seeds?". Authors who did the work but didn't pre-write the defense waste rebuttal space.
2. **Overclaim that invites attack** — saying "we prove" when evidence shows "we observe" triggers reviewer hostility that bleeds into other scores.

Both are prevented by routinely running the draft through a standardized reviewer-objection list and hardening or hedging before submission.
</Why_This_Exists>

<Execution_Policy>
- Generate at least 5 objections per draft section
- Every objection gets a response classified as: harden-prose (rewrite suggestion), add-footnote (minor), add-experiment (TODO for another agent)
- Flag overclaim verbs ("prove", "demonstrate", "establish") and propose hedged alternatives where evidence is correlational
- Flag superlatives ("state-of-the-art", "substantially", "significantly") without backing evidence
</Execution_Policy>

<Steps>
1. Read the draft section. Extract:
   - Every claim sentence
   - Every numeric value (must trace to a Table/Figure)
   - Every citation

2. Run through the standard VLM-reviewer objection checklist:
   a. **Baseline fairness**: did baselines get same tuning / data / seeds / params?
   b. **Seed variance**: is variance reported? how many seeds?
   c. **OOD leakage**: is the "OOD" set really held-out in style and distribution?
   d. **Cherry-picked benchmarks**: are there benchmarks where the method regresses that were omitted?
   e. **Hyperparameter sensitivity**: is the gain robust across LR / batch / steps?
   f. **Causal vs correlational claim**: does prose claim cause when evidence is association?
   g. **Compute fairness**: does proposed method use more compute / params / data without acknowledging?
   h. **Reproducibility**: are code, configs, and seeds releasable?
   i. **Comparison to strongest prior art**: are numbers compared to the best published baseline, not a weak one?
   j. **Metric ambiguity**: is Relaxed Accuracy / F1 tolerance fully specified?

3. Scan for overclaim verbs and superlatives; list each with a hedged alternative.

4. For every objection, draft a response (1–3 sentences) classified:
   - **harden-prose**: rewrite the sentence in place
   - **add-footnote**: small defensive clarification
   - **add-experiment**: additional work needed; emit TODO

5. Emit reviewer-objection report + prose rewrite suggestions + TODO list.
</Steps>

<Tool_Usage>
- Read: the draft section, linked tables/figures for evidence check
- Grep: scan the draft for overclaim verb patterns (`prove|demonstrate|establish|state-of-the-art|significantly|substantially`)
- Write: emit `reviewer_pass_<section>.md` with the full report
</Tool_Usage>

<Output_Format>
```
## Reviewer-Angle Pass: [section]

### Claim Inventory
| Claim | Evidence ref | Hedging |
|---|---|---|
| ... | Table 2 | "we show" |

### Objections & Responses
1. **Objection**: [Baseline fairness — the proposed method is tuned over 20 LRs while the baseline uses default]
   **Response**: [1–3 sentences]
   **Action**: harden-prose / add-footnote / add-experiment
   (if harden-prose: show the rewrite)
   (if add-experiment: record as TODO)

2. **Objection**: ...

(≥5 total)

### Overclaim Scan
| Original | Issue | Suggested rewrite |
|---|---|---|
| "We prove that..." | correlational evidence only | "Our results suggest..." |
| "state-of-the-art" | no comparison table | remove OR add Table ref |

### TODOs (additional work)
- [ ] [What to run] — [which agent: experiment-designer / vqa-eval-analyst / ...]

### Verdict
- [ready-for-submission / needs-minor-rewrites / needs-experiments]
```
</Output_Format>

<Examples>
<Good>
Section claims "mHC significantly outperforms single-gate on ChartQA." Reviewer-angle finds: (1) "significantly" is used without reporting a test — harden prose to "...by 3.2pp (paired bootstrap 95% CI [1.8, 4.6], n=3 seeds)"; (2) baseline fairness — baseline used default LR while mHC was swept — TODO: re-run baseline with matched LR sweep; (3) OOD claim — ChartQA was not in mid-training, confirmed — add footnote. Verdict: needs-minor-rewrites + 1 TODO.
</Good>

<Bad>
Output: "Looks good to me, a few small style fixes."
Why bad: Did not run the objection checklist. Missed fairness / variance / overclaim issues.
</Bad>
</Examples>

<Final_Checklist>
- [ ] ≥5 objections emitted, each with a response and action classification
- [ ] Overclaim verbs and superlatives scanned and addressed
- [ ] Baseline fairness explicitly checked
- [ ] Seed variance reporting explicitly checked
- [ ] OOD leakage explicitly checked
- [ ] TODOs routed to the correct downstream agent
- [ ] Verdict emitted (ready / minor-rewrites / needs-experiments)
</Final_Checklist>
