---
name: figure-storyboard
description: Turn a planned paper into a figure-by-figure storyboard — for each figure, enforce (1) one sentence message, (2) visual grammar (axes, encoding, color semantic), (3) evidence pointer, (4) caption draft. Detects redundancy, missing "teaser" figure, weak interpretability figures. Use when planning paper figures before drafting, or after experiments land to decide what to show.
argument-hint: "<paper outline or section list>, <experiment result index>"
level: 2
---

<Purpose>
Top-venue readers look at figures before prose. A paper with 6 strong figures beats a paper with identical results but weak / duplicated / cluttered figures. This skill forces a storyboard pass: every figure must have one sentence to deliver, a visual grammar that matches that sentence, and direct evidence that backs it.
</Purpose>

<Use_When>
- After experiments land, before figure production
- When revising figures after initial submission
- When the paper feels "result-heavy, message-light"
- Teaser / architecture / main-result / ablation / interpretability figures need coordination
</Use_When>

<Do_Not_Use_When>
- Figures are locked and venue forbids changes (camera-ready already in)
- Work is still pre-experiment (nothing to visualize yet)
</Do_Not_Use_When>

<Why_This_Exists>
Three recurring figure failures sink papers:
1. **Two figures tell the same thing** — reader discount second, author wastes space.
2. **Caption restates the figure instead of the message** — "Figure 3 shows attention weights" (no) vs "Gate α opens on the cell that matches the question modality" (yes).
3. **Interpretability figure lacks quantitative backing** — "we see that..." without a counter-example rate is reviewer bait.
A storyboard pass catches all three before Illustrator touches the file.
</Why_This_Exists>

<Execution_Policy>
- Each figure gets ONE sentence message — if it takes two, split the figure
- Every figure's message must be backed by a specific table row / number / counter-example rate
- Redundancy detection: scan all figure messages for semantic overlap; flag when Jaccard > 0.6
- Required figure classes for a full paper: [teaser, architecture, main-result, ≥1 ablation, ≥1 interpretability]; warn on missing
- Caption drafts must follow the "message → evidence → aside" pattern
</Execution_Policy>

<Steps>
1. Read paper outline + experiment index. Enumerate existing figure plans or generate the required set if missing.

2. For each figure, fill the storyboard card:
   - **Figure ID**: fig:teaser, fig:arch, fig:main, fig:ablation_xyz, fig:interp_abc
   - **Class**: teaser / architecture / main-result / ablation / interpretability / diagnostic
   - **One-sentence message**: what reader should take away
   - **Visual grammar**: axes (x, y), encoding (color, shape, size meaning), legend logic
   - **Evidence pointer**: which experiment table / seed / sample supports it
   - **Caption draft**: "[message sentence]. [evidence sentence]. [aside/caveat if any]."
   - **Risks**: reviewer-attack angles ("cherry-picked sample?", "only 1 seed?")

3. Redundancy scan across all messages. For each pair, compute Jaccard on content tokens. If > 0.6, flag.

4. Coverage check: verify required figure classes present. If missing a teaser or interpretability figure, propose one.

5. For interpretability figures specifically, ensure **counter-example rate** is either on the figure or in the caption — handoff to counter-example-search if missing.

6. For main-result figures, ensure **seed variance / CI** is shown — handoff to seed-variance if missing.

7. Emit storyboard sheet with figure-by-figure cards and action list.
</Steps>

<Tool_Usage>
- Read: paper outline, experiment result files, prior figure tex/pdf if available
- Write: emit `figures_storyboard.md` with cards
- Agent(subagent_type="paper-architect"): cross-section structural integrity pass — figure coverage audit, redundancy scan, and claim-evidence map to ensure every figure card links to a table cell or appendix
- Handoff: counter-example-search, seed-variance for evidence gaps
</Tool_Usage>

<Output_Format>
```
## Figure Storyboard — [paper name]

### Coverage
| Class | Present? | Figure ID |
|---|---|---|
| teaser | ✓ | fig:teaser |
| architecture | ✓ | fig:arch |
| main-result | ✓ | fig:main |
| ablation | ✓ | fig:ablation_components |
| interpretability | ✗ | — add one |

### Figure Cards

#### fig:teaser — class: teaser
- **Message**: "A single gate α localises memory contribution to the patch that matches the question."
- **Visual grammar**: 2x2 grid, rows = question types, cols = image patches; gate α heatmap.
- **Evidence**: Table 2 row "mHC-gate" + sample ID #2317.
- **Caption draft**: "Gate α routes memory contribution per-cell ... (Section 3.2). Intensities are averaged over n=500 samples; see Appendix C for variance."
- **Risks**: reviewer may ask "cherry-picked sample?" — add counter-example rate.

#### fig:arch — ...

### Redundancy Scan
| fig A | fig B | Jaccard | Action |
|---|---|---|---|
| fig:main | fig:ablation_components | 0.72 | Merge? Or split message. |

### Action List
- [ ] Add interpretability figure (missing class)
- [ ] fig:teaser needs counter-example rate — handoff to counter-example-search
- [ ] fig:main needs CI — handoff to seed-variance

### Verdict
- ready-for-production / needs-additions / redundancy-to-resolve
```
</Output_Format>

<Examples>
<Good>
5 planned figures. Storyboard detected 2 with Jaccard 0.78 (both "ablation of spatial key") — merged into 1 with split facets. Interpretability figure missing — generated proposal for "bin-to-text alignment heatmap" with caption draft. Main-result figure lacks CI → handoff to seed-variance.
</Good>

<Bad>
"Your figures look fine." No cards, no redundancy check, no coverage audit.
</Bad>
</Examples>

<Final_Checklist>
- [ ] Every figure has a one-sentence message
- [ ] Every message traces to specific evidence
- [ ] Redundancy scanned, high-Jaccard pairs flagged
- [ ] Required figure classes covered (teaser, arch, main, ablation, interp)
- [ ] Interpretability figures have counter-example rate
- [ ] Main-result figures have seed variance / CI
- [ ] Captions follow message → evidence → aside
</Final_Checklist>
