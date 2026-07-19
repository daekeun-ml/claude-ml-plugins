---
name: abstract-writer
description: Structure and refine the Abstract and Introduction of a VLM/LLM paper so every sentence maps to one of {problem, gap, method-in-one-line, main-result, impact}. Detects buried lede, missing gap sentence, overclaim verbs, unsupported superlatives, and the "method first" anti-pattern. Use when drafting abstract/intro for the first time, after experiments land, or before submission.
argument-hint: "<draft abstract or intro text>, <main result claim with numbers>, <target venue>"
level: 2
---

<Purpose>
Reviewers decide how hard to read within the first 200 words. An abstract/intro that hides the gap, leads with method, or overclaims dooms the paper regardless of the experiments. This skill enforces a structural template and catches the recurring failures.
</Purpose>

<Use_When>
- First abstract / intro draft
- After experiments finalize, before submission rewrite
- Responding to reviewer "the contribution is unclear"
- Re-framing for a different venue
</Use_When>

<Do_Not_Use_When>
- Method section or Related Work (different structures)
- Blog posts / informal writing
</Do_Not_Use_When>

<Why_This_Exists>
Across hundreds of reviews, three failures dominate abstracts/intros:
1. **Buried lede** — main result appears in sentence 5 instead of 2.
2. **Missing gap** — method stated, but not what's wrong with prior art.
3. **Overclaim** — "we prove / we establish / state-of-the-art" without specific benchmark/number.
A structural pass catches these mechanically.
</Why_This_Exists>

<Execution_Policy>
- Map every sentence to role: problem / gap / method / result / impact / other
- "Other" sentences > 20% of total → warn (too much setup)
- Result sentence must contain concrete number with benchmark name
- Method sentence ≤ 25 words; if longer, split
- Gap sentence must name a failure mode of prior art, not just "little work exists"
- Scan for overclaim verbs and superlatives
</Execution_Policy>

<Steps>
1. Split the abstract / intro into sentences. Tag each by role:
   - **Problem**: what phenomenon / task?
   - **Gap**: what's wrong with existing approaches?
   - **Method**: what did we do (1–2 sentences max)?
   - **Result**: concrete numbers on named benchmarks
   - **Impact**: why does it matter beyond the numbers?
   - **Other**: transition / setup

2. Check structural coverage:
   - Abstract: problem=1, gap=1, method=1–2, result=1–2, impact=0–1 (optional)
   - Intro: problem=1–2, gap=1–2, method=2–3, contribution list=1 paragraph, result=embedded

3. Order check:
   - For abstract: main result should appear by sentence 3–4 at latest.
   - For intro: gap must precede method.

4. Overclaim scan:
   - Verbs: "prove", "establish", "demonstrate that", "show that"
   - Superlatives: "state-of-the-art", "unprecedented", "significantly", "substantially"
   - Each hit gets a hedged alternative suggestion.

5. Missing-element check:
   - No gap sentence → propose one based on prior art
   - No concrete number in result → emit TODO
   - No impact sentence → propose one (optional, strong on NeurIPS/ICLR)

6. Emit a rewritten abstract skeleton with role-tagged sentences + suggested edits + TODOs.
</Steps>

<Tool_Usage>
- Read: current abstract/intro, main result tables
- Grep: overclaim verb / superlative regex
- Write: emit `abstract_pass_<date>.md` with side-by-side rewrite
- Agent(subagent_type="academic-writer"): publication-grade prose rewrite — maps every sentence to {problem, gap, method, result, impact}, enforces Farquhar 5-sentence formula, kills buried ledes and overclaim verbs, produces submission-ready English
</Tool_Usage>

<Output_Format>
```
## Abstract / Intro Structural Pass — [paper]

### Sentence Role Map
| # | Role | Sentence | Issue |
|---|---|---|---|
| 1 | problem | "VLMs struggle with ..." | ok |
| 2 | other | "In this work we ..." | redundant |
| 3 | method | "Our approach trains ..." | 34 words, split |
| 4 | result | "On ChartQA we achieve 67.4%." | ok |
| 5 | impact | — | missing |

### Coverage Check
- problem: ✓   gap: ✗   method: ✓   result: ✓   impact: ✗
- Main result position: sentence 4 (ok)

### Overclaim Scan
| Original | Issue | Suggested rewrite |
|---|---|---|
| "We prove that ..." | correlational | "Our results suggest ..." |
| "state-of-the-art" | no comparison | "+1.2 pp over [Cheng et al. 2026] on ChartQA" |

### Missing Elements
- No gap sentence. Proposal: "Prior discrete-memory approaches fix the lookup key to be deterministic [cite], which limits ..."
- No impact sentence (optional for NeurIPS).

### Rewrite Proposal (side-by-side)
[original | rewrite] paragraph form

### Verdict
- ready / needs-rewrite / needs-additional-evidence
```
</Output_Format>

<Examples>
<Good>
6-sentence abstract. Role map: 1 problem, 2 other (redundant setup), 3 method (too long, 31 words, split), 4 method-cont, 5 result (ChartQA 67.4% ✓), 6 other. Missing gap. Proposed gap sentence from prior-art survey, suggested 31-word split, cut the two redundant setup sentences. Final abstract: 7 sentences with all 5 roles present, main result at sentence 4.
</Good>

<Bad>
"Abstract looks good." No role map, no coverage check.
</Bad>
</Examples>

<Final_Checklist>
- [ ] Every sentence role-tagged
- [ ] Coverage (problem/gap/method/result/impact) verified
- [ ] Main result position ≤ sentence 4 for abstract
- [ ] Method ≤ 2 sentences, each ≤ 25 words
- [ ] Overclaim verbs + superlatives scanned
- [ ] Gap sentence concrete (names prior-art failure mode)
- [ ] Side-by-side rewrite proposal emitted
</Final_Checklist>
