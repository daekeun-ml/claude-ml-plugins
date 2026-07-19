---
name: rebuttal-drafter
description: Turn reviewer comments into an evidence-mapped rebuttal. For each concern, classify (factual / methodological / clarity / out-of-scope) and draft a reply that either (a) points to existing evidence, (b) proposes an added experiment + outcome commitment, or (c) concedes and hardens prose. Enforces character/word budget and "do not argue, do not overclaim" tone. Use immediately after reviews arrive and before rebuttal deadline.
argument-hint: "<reviewer comments (per reviewer)>, <evidence inventory: tables/figures/code>, <venue rebuttal limit>"
level: 3
---

<Purpose>
Rebuttals are won by (a) answering every concrete objection, (b) showing new evidence where possible, (c) staying calm. Papers lose in rebuttal when authors argue tone, miss concerns, or promise vague "future work". This skill produces a structured, evidence-mapped rebuttal under venue constraints.
</Purpose>

<Use_When>
- Reviews have just arrived
- Preparing author response at NeurIPS/ICLR/ACL discussion phase
- Revisiting reviewer feedback before camera-ready
</Use_When>

<Do_Not_Use_When>
- Paper is desk-rejected (no rebuttal applicable)
- Reviewers gave only stylistic comments with no objections — just apply latex-polish
</Do_Not_Use_When>

<Why_This_Exists>
Rebuttal failure modes:
1. **Missing a concern** — reviewer will downgrade "authors did not respond".
2. **Arguing tone** — "we believe the reviewer misunderstood" triggers hostility.
3. **Vague promise** — "we will add this in the camera-ready" with no commitment to outcome / number.
4. **Exceeding character budget** — auto-truncated, critical response cut.
A structured pass addresses all four.
</Why_This_Exists>

<Execution_Policy>
- Every numbered concern must have a reply (none skipped)
- Tone: no "the reviewer is wrong" framing; use "to clarify" or "we have now added …"
- New experiments proposed must include: expected outcome range + when it will be delivered
- Word/character budget enforced per venue
- Classify each concern: factual / methodological / clarity / out-of-scope / misread
- Reply type: existing-evidence / added-experiment / prose-rewrite / concede
</Execution_Policy>

<Steps>
1. Parse reviews per reviewer. Segment into numbered concerns (sometimes bullet points are unnumbered — assign IDs R1.1, R1.2, …).

2. For each concern, classify:
   - Factual (a stated fact challenged)
   - Methodological (experimental design challenged)
   - Clarity (prose was ambiguous, caused misread)
   - Out-of-scope (beyond paper's claim)
   - Misread (reviewer conflated something)

3. Match to evidence inventory:
   - Is there an existing table / figure / appendix that already answers?
   - If yes, reply = "existing-evidence", pointer to exact location.
   - If no, decide: added-experiment (can we run it in rebuttal window?) or prose-rewrite or concede.

4. For added-experiment replies:
   - Specify the experiment (what / how long)
   - Commit to outcome range — "we expect +X to +Y pp" — venue readers prefer concrete commitments over "we will investigate"
   - Say when (24h / 48h / camera-ready)

5. Draft per-reviewer reply:
   - Opening: "We thank reviewer for constructive feedback. Below we address each concern."
   - Per concern: "**R1.1 [concern topic]**: [reply in 2–5 sentences]."
   - No stylistic arguments.

6. Budget check: count words/characters per reviewer, trim to limit. Preserve concrete numbers; cut hedging prose first.

7. Emit rebuttal document + action list (new experiments to run + prose changes for camera-ready).
</Steps>

<Tool_Usage>
- Read: reviews, paper draft, result tables
- Write: emit `rebuttal_draft.md` + `rebuttal_action_list.md`
- Agent(subagent_type="rebuttal-writer"): full rebuttal drafting specialist — parses reviewer concerns, classifies each, maps to evidence, drafts replies under venue character budget with calm "to clarify" tone
- Agent(subagent_type="experiment-designer"): design added experiments proposed in rebuttal with outcome commitment ranges
- Agent(subagent_type="vqa-eval-analyst"): aggregate existing eval results for evidence mapping, compute bootstrap CIs, run per-sample Δ decomposition to answer reviewer challenges
</Tool_Usage>

<Output_Format>
```
## Rebuttal Draft — [paper, venue]

### Budget
- Per-reviewer limit: 5000 chars
- Current: R1 4820 / R2 4950 / R3 3100

### Per-Reviewer Reply

#### Reviewer R1
Opening: ...

**R1.1 (classification: methodological) [concern: baseline fairness]**
Reply type: existing-evidence.
"We report matched hyperparameter sweeps for both methods in Appendix D, Table 12. Baseline LR was swept over {1e-4, 5e-4, 1e-3} with best selection; our method used the same sweep. ..."

**R1.2 (clarity)**
Reply type: prose-rewrite.
"We rephrased Section 3.2 to clarify: ... (camera-ready)."

**R1.3 (added-experiment)**
Reply type: added-experiment.
"We ran [experiment] over 48h; preliminary results show Δ = +2.1 pp (n=3 seeds). Full results attached in Appendix F by [date]."

#### Reviewer R2 ...

### Action List (for next 48h)
| Action | Owner | Expected Delta | Due |
|---|---|---|---|
| Add n=5 seed variance for main table | vqa-eval-analyst | ± 0.3 pp | 24h |
| Add appendix on hyperparameter sweep | writer | — | 36h |
| Run OOD VSR split | experiment-designer | Δ ∈ [+0.5, +1.5] | 48h |

### Concern Coverage Audit
| Concern | Replied? | Type |
|---|---|---|
| R1.1 | ✓ | existing-evidence |
| R1.2 | ✓ | prose-rewrite |
| ... |

### Verdict
- ready-for-submission / needs-more-experiments / over-budget
```
</Output_Format>

<Examples>
<Good>
3 reviewers, 11 concerns total. Classified: 4 factual (3 answered by existing tables), 3 methodological (1 added experiment with +2.1 pp commitment, 2 existing evidence), 3 clarity (rewritten), 1 out-of-scope (conceded politely). All concerns addressed. Character budget 4820/5000/3100. 3-item 48h action list emitted.
</Good>

<Bad>
"We disagree with reviewer R1." — arguing tone, no evidence pointer, concerns not enumerated, over budget.
</Bad>
</Examples>

<Final_Checklist>
- [ ] Every concern has a reply (none skipped)
- [ ] Each reply classified by type
- [ ] No arguing-tone prose ("reviewer misunderstands")
- [ ] Added experiments commit to outcome range + delivery time
- [ ] Character/word budget respected per reviewer
- [ ] Action list has owners + due times
- [ ] Concern coverage audit shows 100%
</Final_Checklist>
