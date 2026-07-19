---
name: related-work-miner
description: Design the Related Work section as a taxonomy of positions around the paper's contribution, not a chronological citation dump. For each axis, group prior work into 2–4 clusters with per-cluster "how our work differs" sentences. Detects the "list-of-papers" anti-pattern, missing must-cites, and accidental self-positioning in a redundant cluster. Use after paper-lookup produces a neighbour set, before drafting the Related Work prose.
argument-hint: "<contribution statement>, <paper-lookup survey output>"
level: 2
---

<Purpose>
A strong Related Work section positions the paper in a conceptual map, not a list. Reviewers use it to decide "is this a new axis or a me-too?" before reading the method. This skill forces explicit axis choice + clustering + per-cluster differentiation.
</Purpose>

<Use_When>
- After paper-lookup lands a neighbour set (≥15 papers)
- Rewriting Related Work for a resubmission where a reviewer said "unclear how this differs from X"
- Positioning for a different venue (axes may need reordering)
</Use_When>

<Do_Not_Use_When>
- Before paper-lookup is done — need the neighbours first
- Workshop / short paper where Related Work = 1 paragraph (trim instead)
</Do_Not_Use_When>

<Why_This_Exists>
Two failure modes ruin Related Work:
1. **List-of-papers**: "Smith et al. did A. Jones et al. did B. Kim et al. did C." — reader has no taxonomy, no sense of where the paper lives.
2. **Wrong self-positioning**: author places work next to "large, well-known" cluster even though it solves a different axis — reviewer then compares against the wrong baseline.
A taxonomy with explicit axes forces the author to name where they live.
</Why_This_Exists>

<Execution_Policy>
- Identify 2–4 conceptual axes along which the field organises
- Within each axis, cluster papers into 2–4 groups
- Every cluster gets a "our work differs by…" sentence anchored to a specific mechanism
- Must-cite filter: any paper in the top-10 of paper-lookup that isn't placed in a cluster must have a reason (dismissed / off-topic)
- Cross-citation check: all papers cited in method/experiments must appear in Related Work or Preliminaries
</Execution_Policy>

<Steps>
1. Read contribution statement. Extract the novelty axes (which dimensions does the paper claim to be new on?).

2. From paper-lookup output, gather neighbour set. For each, tag:
   - Primary axis (architecture / supervision / data / representation / interpretability / …)
   - Secondary axis (if dual-use)
   - Closest match to our contribution (Y / adjacent / distant)

3. Choose Related Work axes (2–4). They should map to the paper's own novelty axes plus one "prior families" axis.

4. For each axis, cluster papers into 2–4 groups. Name each cluster descriptively (not "other").

5. For each cluster:
   - 1–2 representative citations
   - 1-sentence cluster summary
   - "Our work differs by …" sentence — must name a concrete mechanism

6. Self-positioning: place our paper explicitly in one or more clusters or create a "new cluster" if the contribution is genuinely off-axis.

7. Must-cite audit: which top-10 papers didn't land in a cluster? For each, either (a) place them, (b) mark "not cited — off topic, justification: …".

8. Cross-citation check: scan method/experiment sections for citations; every such citation must exist in Related Work or Preliminaries.

9. Emit a Related Work outline (axis → cluster → bib keys + differentiation sentence).
</Steps>

<Tool_Usage>
- Read: paper-lookup output, current Related Work, method/experiments for cross-citation
- Write: emit `related_work_taxonomy.md`
- Agent(subagent_type="literature-scout"): orchestrated multi-source survey (arXiv + Semantic Scholar + OpenReview) with citation-graph expansion and gap analysis when the neighbour set is incomplete
- Agent(subagent_type="paper-scout"): per-paper deep summaries (TL;DR / Contribution / Method / Relevance / Limitations) for each cluster representative to sharpen differentiation sentences
</Tool_Usage>

<Output_Format>
```
## Related Work Taxonomy — [paper]

### Chosen Axes (2–4)
1. Discrete memory structures
2. Query-conditioned retrieval
3. Interpretability of multimodal representations

### Axis 1 — Discrete memory structures
| Cluster | Representative cites | Summary | Our differentiation |
|---|---|---|---|
| n-gram hash memory | Cheng 2026; Zhang 2025 | hash-based offloading | we make the key query-conditioned and text-grounded |
| kNN-LM-style | Khandelwal 2020; Ma 2022 | stored keys are fixed | we update semantics via contrastive loss |
| Codebook VQ | LaVIT; VQ-VAE-2 | frozen codebook | we anchor bin semantics post-hoc, codebook still frozen |

### Axis 2 — ...

### Self-Positioning
Our work lives at the intersection of clusters {n-gram hash} and {Codebook VQ}, with a new differentiation on text-anchoring that no existing cluster covers.

### Must-Cite Audit
| Paper | Cluster | If not cited, reason |
|---|---|---|
| Smith 2025 | n-gram hash | placed |
| Kim 2024 | — | not cited: off-topic (text-only, no vision) |

### Cross-Citation Check
- method.tex cites [Cheng 2026] → present in RW ✓
- experiment.tex cites [Khandelwal 2020] → present in RW ✓
- method.tex cites [Jones 2023] → **missing from RW** — add or move to Preliminaries

### Rendered Outline (for prose drafting)
[axis → cluster → 2-3 sentence paragraph template]

### Verdict
- taxonomy-ready / needs-additional-cluster / must-cite-gaps
```
</Output_Format>

<Examples>
<Good>
18 neighbours, 3 axes chosen (memory structure / query conditioning / interpretability). 9 clusters total. Self-positioning: intersection of "n-gram hash" × "learnable semantic anchor" — new cluster. 2 must-cite gaps surfaced, 1 cross-citation from experiments missing from RW — fixed.
</Good>

<Bad>
"Here's a list of 18 papers grouped by year." No axes, no differentiation, no self-positioning.
</Bad>
</Examples>

<Final_Checklist>
- [ ] 2–4 conceptual axes chosen
- [ ] Each axis has 2–4 clusters
- [ ] Each cluster has concrete "our work differs by …" sentence
- [ ] Self-positioning explicit
- [ ] Must-cite audit run on top-10 neighbours
- [ ] Cross-citation check method/experiments ↔ Related Work
- [ ] Outline ready for prose drafting
</Final_Checklist>
