---
name: idea-brainstorming
description: Generate and stress-test research ideas for VLM/LLM papers by (1) mapping the problem to orthogonal novelty axes, (2) sampling ≥8 candidate directions per axis, (3) running contradiction/competitor checks against each, (4) scoring by {novelty, feasibility, evaluation clarity, paper-story strength}. Use when starting a new project, pivoting after negative results, or expanding a single idea into a paper-worthy portfolio.
argument-hint: "<problem statement>, <known constraints>, <prior art pointers (optional)>"
level: 3
---

<Purpose>
Researchers often anchor on the first plausible idea and miss orthogonal axes that would yield stronger contributions. This skill forces explicit enumeration along multiple novelty axes and adversarial filtering so the author selects on evidence, not gut.
</Purpose>

<Use_When>
- Starting a new paper and choosing the main contribution
- After a negative result, deciding what to pivot to
- Expanding a kernel of an idea into a 4–6 experiment portfolio
- When "I have too many ideas and cannot rank them"
</Use_When>

<Do_Not_Use_When>
- The idea is already locked in and tested — use reviewer-angle / ablation-matrix instead
- Pure engineering task with no research contribution
</Do_Not_Use_When>

<Why_This_Exists>
Top-venue novelty is almost never "a new layer" — it's a **new axis of variation** on an existing problem. Authors who brainstorm along a single axis (e.g., "make the model bigger") miss the axis that actually produces novelty ("make the supervision signal structurally different"). Multi-axis enumeration surfaces overlooked directions; contradiction check prunes dead ends cheaply.
</Why_This_Exists>

<Execution_Policy>
- Identify ≥3 orthogonal novelty axes before generating candidates
- Generate ≥8 candidate ideas total, ≥2 per axis
- For each candidate, run (a) "has this been done?" check (paper-lookup handoff), (b) contradiction/failure-mode probe, (c) evaluability check
- Score on 4 dimensions, not a single "goodness" scalar
- Emit top-3 shortlist with why-each-beats-the-rest
</Execution_Policy>

<Steps>
1. Restate the problem in one sentence. Extract:
   - Input modality / output goal
   - What existing methods assume (the implicit axes they chose)
   - What the user has *already tried* (do not re-propose)

2. Enumerate novelty axes. Typical VLM/LLM axes:
   - **Architecture**: new module / new gate / new memory / new tokenizer
   - **Supervision signal**: new loss / new negative sampling / self-labeling
   - **Data**: new source / new augmentation / new curriculum
   - **Representation**: new space / new discretization / new alignment target
   - **Inference**: new decoding / test-time compute / retrieval
   - **Interpretability hooks**: new diagnostic that also drives learning
   - **Scaling behavior**: phenomenon that appears only at N, data D, or with condition C

   Select ≥3 axes that are orthogonal to what the user already tried.

3. For each axis, generate ≥2 candidate ideas. Each candidate described by:
   - "What changes" (1 sentence)
   - "Why it might help" (mechanism hypothesis, 1–2 sentences)
   - "What falls apart if hypothesis is wrong" (failure mode)

4. For each candidate, contradiction check:
   a. Has it been published (invoke paper-lookup)?
   b. Is there a natural competitor baseline (name it)?
   c. What would the reviewer attack first (use reviewer-angle logic)?
   d. Is the evaluation clear (which benchmark, which metric)?

5. Score each candidate 0–3 on:
   - **Novelty** (orthogonal to existing lit?)
   - **Feasibility** (buildable with current compute / data?)
   - **Evaluation clarity** (can we cleanly measure success?)
   - **Paper-story strength** (one-line pitch compelling?)

6. Emit top-3 shortlist with explicit "why it beats the rest" 1-sentence comparisons.

7. For each shortlisted idea, suggest first experiment + ablation axis (handoff to experiment-designer / ablation-matrix).
</Steps>

<Tool_Usage>
- WebSearch / WebFetch: light contradiction check (full survey → paper-lookup)
- Read: existing project notes, prior experiment docs
- Write: emit `ideas_<topic>_<date>.md` with full scoring table
- Agent(subagent_type="research-ideator"): deep ideation with novelty-axis mapping, failure-mode probing, and top-3 shortlist with score matrix
- Agent(subagent_type="literature-scout"): multi-source prior-art survey (arXiv + Semantic Scholar + OpenReview) to confirm freshness of shortlisted ideas
</Tool_Usage>

<Output_Format>
```
## Idea Brainstorm — [problem]

### Problem restate
[1 sentence]

### What user already tried (skip these axes)
- ...

### Novelty axes (≥3 orthogonal)
1. [Axis name] — rationale: ...
2. ...

### Candidates (≥8)

#### Axis A — Candidate A1: [name]
- What changes: ...
- Why might help: ...
- Failure mode: ...
- Prior art: [handoff to paper-lookup, initial hit: ...]
- Competitor baseline: ...
- Eval plan: [benchmark, metric]
- Scores: novelty=2, feasibility=3, eval=3, story=2 → **10/12**

#### Axis A — Candidate A2: ...
...

### Top-3 Shortlist
| Rank | Idea | Score | Why it beats the rest |
|---|---|---|---|
| 1 | ... | 11 | unique on axis A; clean eval |
| 2 | ... | 10 | ... |
| 3 | ... | 9 | ... |

### Recommended Next Step
- For rank 1: run experiment-designer → ablation-matrix
- For rank 2: first do paper-lookup to confirm freshness
```
</Output_Format>

<Examples>
<Good>
Problem: "VLM memory is unstable across tasks." 4 axes identified (architecture / supervision / representation / interpretability). 10 candidates across axes. 3 pruned by paper-lookup (already published). Top-3: (a) contrastive-anchored codebook, (b) cross-modal n-gram context, (c) gate-parametrization learnable temperature. All scored ≥10/12 with explicit rank-1 reason "orthogonal to all 3 cited competitors".
</Good>

<Bad>
"Here are 3 ideas: make it bigger, add a new loss, add attention." Single-axis, no scoring, no contradiction check.
</Bad>
</Examples>

<Final_Checklist>
- [ ] ≥3 orthogonal novelty axes identified
- [ ] ≥8 candidate ideas generated across axes
- [ ] Each candidate has explicit failure mode
- [ ] Contradiction check (prior art + competitor baseline) run per candidate
- [ ] 4-dimension scoring applied
- [ ] Top-3 shortlist with comparative rationale
- [ ] Handoff target named for each shortlisted idea
</Final_Checklist>
