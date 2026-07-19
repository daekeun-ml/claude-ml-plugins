---
name: counter-example-search
description: Actively search for samples that CONTRADICT a proposed interpretability claim before labeling the claim as strong evidence. Forces adversarial sampling, quantifies the counter-example rate, and downgrades claim strength when counter-examples exceed tolerance. Use whenever an interpretability finding is about to be promoted from "we observed" to "we claim".
argument-hint: "<claim in falsifiable form>, <probe script/data>"
level: 3
---

<Purpose>
Interpretability claims are trivially falsifiable by a reviewer who finds a counter-example — and trivially strengthened by the researcher who finds one first. This skill forces the research loop to include an adversarial sampling pass: before claiming "cells specialize", we must try to find samples where they don't, and report what we found.
</Purpose>

<Use_When>
- interpretability-researcher is about to label a claim as "strong evidence"
- A beautiful heatmap exists and the user wants to build a paper section on it
- A pattern looks suspiciously clean across a small curated sample
- Before inserting an interpretability figure into the paper draft
</Use_When>

<Do_Not_Use_When>
- The claim is already qualified as "in some cases" or "on this example" — no promotion is being claimed
- The probe is not yet implemented — run the probe first, then this skill
- The sample size for the positive case is < 100 — collect more positive evidence first (counter-example search is meaningful only when the positive case is already aggregated)
</Do_Not_Use_When>

<Why_This_Exists>
Confirmation bias in interpretability work is acute: it is natural to sample until a pretty picture appears, then stop. A claim built on that pattern will not survive a reviewer who runs 10 random samples. This skill inverts the search: instead of "find 3 samples that support X", ask "find 3 samples where X should hold but does not". The ratio of failures on adversarial sampling directly calibrates claim strength.
</Why_This_Exists>

<Execution_Policy>
- Claim must be stated in falsifiable form (e.g., "for each domain d, ∃ cell c with E[α_c|d] > 2× E[α_c|other]")
- Adversarial sample size ≥ 100, drawn from the SAME population as the positive evidence
- Counter-example rate ≥ 20% → downgrade claim to "moderate"
- Counter-example rate ≥ 40% → downgrade to "weak" or retract
- Always report the counter-examples, don't hide them
</Execution_Policy>

<Steps>
1. Restate the claim in falsifiable form. Define:
   - Prediction: "if the claim holds, observing X implies Y"
   - Contradiction: "counter-example = observing X but NOT Y"

2. Define the adversarial sampling strategy. Examples:
   - Random sample from the evaluation split (default)
   - Edge-case sample: rare classes, long inputs, unusual compositions
   - Stratified: balanced across domains / question types / image kinds

3. Draw ≥ 100 samples. Run the probe on each. Record per-sample prediction outcome.

4. Classify:
   - Supports: X holds AND Y holds
   - Contradicts: X holds AND Y does NOT hold (counter-example)
   - Not applicable: X does not hold

5. Compute counter-example rate = contradicts / (supports + contradicts).

6. Characterize the counter-examples:
   - Are they clustered by domain / length / difficulty?
   - Do they share a distinct feature?
   - If clustered, the claim may hold on a subset — re-scope the claim.

7. Assign final evidence label:
   - **strong**: counter-rate < 10% AND no systematic cluster
   - **moderate**: 10–30% OR a distinct systematic cluster exists
   - **weak**: > 30% OR claim only holds on a narrow subset
   - **retract**: > 50%

8. Report: claim (falsifiable), sample size, counter rate, characterization, final label. Recommend paper phrasing.
</Steps>

<Tool_Usage>
- Read: load probe scripts and positive-evidence artifacts
- Bash / mcp__ide__executeCode: run the probe across adversarial samples, compute statistics, save counter-example index list
- Write: save `interpret/counter_examples_<claim_id>.json` with sample IDs and stats
</Tool_Usage>

<Output_Format>
```
## Counter-Example Search: [claim_id]

### Falsifiable Claim
- Stated: [user's claim]
- Prediction: [if claim holds, X → Y]
- Contradiction: [X and not Y]

### Sampling
- Strategy: [random / stratified / edge]
- N samples: 200
- Split: [eval split name]

### Results
- Supports: N1
- Contradicts: N2
- Not applicable: N3
- **Counter-example rate**: N2 / (N1 + N2) = X%

### Characterization of Counter-Examples
- Cluster: [they concentrate on ... / no cluster detected]
- Examples (3): [sample IDs with brief descriptions]

### Final Label
- **Strength**: strong / moderate / weak / retract
- **Reason**: [tie to counter-rate and cluster result]

### Recommended Paper Phrasing
- [If strong]: "We observe [claim] holds in N% of cases."
- [If moderate]: "We observe [claim] on [sub-population]; the effect is weaker on [complement]."
- [If weak]: do not claim in main text; mention as limitation.
```
</Output_Format>

<Examples>
<Good>
Claim: "mHC cells specialize to domains". Adversarial sampling: 200 random samples across ChartQA/ScienceQA/TextVQA. Result: supports 142, contradicts 58 → counter-rate 29%. Counter-examples cluster on ambiguous domain samples (charts with lots of text). Label: moderate. Recommended phrasing: "Cells specialize on clean-domain inputs but overlap on mixed-modality inputs."
</Good>

<Bad>
Claim: "Cells specialize". Only positive samples inspected. No adversarial pass. Labeled strong based on 3 beautiful examples.
Why bad: No test of the claim — pure confirmation bias. Will be attacked by reviewers.
</Bad>
</Examples>

<Final_Checklist>
- [ ] Claim restated in falsifiable form with explicit contradiction condition
- [ ] Adversarial sample ≥ 100 from the same population as positive evidence
- [ ] Counter-example rate computed and reported
- [ ] Counter-examples characterized for clustering
- [ ] Final label assigned per rule, not by feel
- [ ] Paper phrasing recommendation matches label strength
</Final_Checklist>
