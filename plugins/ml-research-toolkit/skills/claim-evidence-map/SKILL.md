---
name: claim-evidence-map
description: Build a paper-wide claim-to-evidence map. Every declarative claim in abstract / intro / method / experiments must link to a table cell, figure panel, section pointer, or appendix reference. Detects broken links, orphan claims (no evidence), orphan evidence (no claim), and claim-evidence mismatch (claim says "significant" but evidence has no test). Use before every submission and after each major rewrite.
argument-hint: "<paper tex dir>, <table/figure index>, <result log dir>"
level: 3
---

<Purpose>
A paper is a directed graph of (claim → evidence) edges. Every broken edge is a reviewer attack surface. This skill builds the graph explicitly, finds broken edges, and forces the author to fix them before submission.
</Purpose>

<Use_When>
- Pre-submission final pass
- After adding a new experiment (re-map only the new nodes)
- After reviewer feedback "unclear what supports this"
- Camera-ready preparation
</Use_When>

<Do_Not_Use_When>
- Early draft; claims still in flux
- Notes-style document, not a paper
</Do_Not_Use_When>

<Why_This_Exists>
Recurring submission failures:
1. **Orphan claim** — "our method scales" with no scaling figure.
2. **Orphan evidence** — Figure 5 in the paper, referenced nowhere in prose.
3. **Claim-evidence mismatch** — "+3.2 pp" in prose, "+3.0 pp" in the table (rounding or copy-paste error).
4. **Missing "significance"** — "significantly better" with no CI or test in evidence.
A graph audit catches all four mechanically.
</Why_This_Exists>

<Execution_Policy>
- Every declarative sentence with a quantifier ("we achieve", "N% better", "more than", "significant") must map to evidence
- Every table/figure must be referenced at least once in prose
- Every numeric claim must match evidence to ≤ 0.1 pp
- Significance-claim sentences must point to evidence that contains a test (bootstrap / paired / n-seeds)
- Emit a single-page map that a reader can audit in 60 seconds
</Execution_Policy>

<Steps>
1. Parse paper sources. Extract:
   - Every declarative claim (sentence-level) — especially ones with numbers, "significant", "state-of-the-art", "achieves", "improves".
   - Every table / figure / appendix section (nodes).
   - Every `\ref{}` / `\Cref{}` (existing edges).

2. Build the graph:
   - Nodes: claims + evidence (tables, figures, appendix refs)
   - Edges: explicit `\ref` in prose OR number-match ("+3.2 pp" in prose matches Table 2 row with 3.2)

3. Detect issues:
   a. **Orphan claim**: claim sentence with a quantifier but no edge
   b. **Orphan evidence**: table/figure never referenced in prose
   c. **Number mismatch**: claim says X, evidence says Y, |X-Y| > 0.1
   d. **Missing significance**: claim contains "significant" / "robust" / "consistent" but evidence lacks seed-variance / CI
   e. **Stale reference**: `\ref` points to a renamed or deleted label

4. Cross-check against result logs:
   - For each table cell, find the producing experiment run
   - If not found, flag as "evidence not reproducible"

5. Emit map (tabular + optional graphviz output) + action list.

6. For each issue, classify:
   - Fix-by-rewrite (edit prose)
   - Fix-by-add-evidence (add a new table/figure/appendix)
   - Fix-by-drop-claim (remove overclaim if evidence not achievable)
</Steps>

<Tool_Usage>
- Read: all .tex, result log dir, existing figures/tables
- Grep: claim-quantifier patterns, `\ref{}` / `\cite{}` patterns
- Bash: number-match regex across prose and tables
- Write: emit `claim_evidence_map.md` + `broken_edges.md`
- Agent(subagent_type="paper-architect"): full structural-integrity pass — owns the claim-evidence map, flags orphan claims and orphan evidence, detects number mismatches across all sections
- Agent(subagent_type="academic-writer"): rewrite orphan-claim sentences to either soften the claim or anchor it to existing evidence; map every quantified claim to a table cell
</Tool_Usage>

<Output_Format>
```
## Claim–Evidence Map — [paper]

### Graph Summary
- Claims detected: 47
- Evidence nodes (tables/figures/appendix): 18
- Edges (explicit + number-matched): 39
- Orphan claims: 5
- Orphan evidence: 2
- Number mismatches: 3
- Missing significance: 2
- Stale refs: 1

### Broken Edges

| Issue | Location | Claim / Evidence | Fix |
|---|---|---|---|
| orphan-claim | abstract.tex:8 | "Our method scales robustly" | add scaling table OR soften claim |
| orphan-evidence | Table 7 (appendix) | never referenced | add cite in section 5 OR drop table |
| number-mismatch | method.tex:120 | "+3.2 pp" vs Table 2 cell "+3.0 pp" | unify to +3.0 |
| missing-significance | intro.tex:15 | "significantly better" | run seed-variance (handoff) |
| stale-ref | exp.tex:54 | `\ref{tab:old}` not defined | update label |

### Action List
- [ ] Add scaling figure (orphan claim) — handoff to experiment-designer
- [ ] Decide: drop orphan Table 7 or reference it in Section 5
- [ ] Fix 3 number mismatches (find-replace)
- [ ] Run seed-variance on main table (handoff)
- [ ] Update stale ref

### Evidence Reproducibility
| Table/Figure | Source run | Exists in log dir? |
|---|---|---|
| Table 2 | qcap_v3 step2000 | ✓ |
| Figure 3 | — | **missing** — rerun needed |

### Verdict
- submission-ready / N broken edges / needs-experiments
```
</Output_Format>

<Examples>
<Good>
47 claims × 18 evidence nodes → 39 edges. Found 5 orphan claims (1 dropped, 4 fixed by adding evidence pointers), 2 orphan evidences (1 dropped, 1 now cited), 3 number mismatches (fixed by find-replace), 2 "significant" without test (handed off to seed-variance). Final graph: 0 broken edges.
</Good>

<Bad>
"All claims supported." No graph, no count, no verification.
</Bad>
</Examples>

<Final_Checklist>
- [ ] Every declarative + quantitative claim extracted
- [ ] Every table / figure counted as evidence node
- [ ] Orphan-claim scan done
- [ ] Orphan-evidence scan done
- [ ] Number-match check done (tolerance 0.1 pp)
- [ ] Missing-significance check done
- [ ] Evidence reproducibility verified against logs
- [ ] Action list with handoffs emitted
- [ ] Verdict emitted
</Final_Checklist>
