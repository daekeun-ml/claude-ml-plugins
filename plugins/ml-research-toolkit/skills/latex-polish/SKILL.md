---
name: latex-polish
description: Polish LaTeX paper sources for top-tier venue submission — enforce math-mode hygiene, citation style, macro consistency, spacing conventions, float placement, and bibliography normalization. Detects common reviewer-irritants (double-subscript, missing \text{} inside math, wrong \cite variants, inconsistent notation, stray tabs, orphan widows). Use before each submission/camera-ready pass and after any large content rewrite.
argument-hint: "<paper tex dir or main.tex path>, <venue style (neurips|iclr|acl|emnlp|cvpr)>"
level: 2
---

<Purpose>
Reviewers form a first impression from typography, not from content. A paper riddled with `\cite{}` instead of `\citep{}`, `$A_i_j$`, or `Figure 3` (should be `\Cref{fig:foo}`) signals a rushed submission and bleeds reviewer patience. This skill performs a deterministic pass over the .tex sources to fix the mechanical issues before a human reviewer sees them.
</Purpose>

<Use_When>
- Pre-submission pass 1 day before deadline
- After any major rewrite or merge
- When importing prose from a doc/markdown draft into a .tex template
- Camera-ready preparation
</Use_When>

<Do_Not_Use_When>
- The draft is still pre-figure / pre-table — polish is wasted on prose that will be rewritten
- The .tex file is a single-author note not for submission
- You need *semantic* rewriting — that's academic-writer's job, not this one
</Do_Not_Use_When>

<Why_This_Exists>
LaTeX has dozens of conventions that differ silently between venues (NeurIPS uses `\citep`, ACL uses `\cite`, CVPR uses `\cite` with `cvpr.sty`). Every year papers regress in review because of mechanical slippage that a 30-min pass would have fixed. Automating this pass frees human attention for arguments and evidence.
</Why_This_Exists>

<Execution_Policy>
- Operate only on .tex / .bib files; never touch figure sources
- Produce a diff-style report (original → rewrite) for each change class, not silent edits
- Never change semantic content — if a "polish" would alter meaning, emit a TODO instead of rewriting
- Classify findings by severity: blocker (compile error) / reviewer-noise (will annoy) / nit (optional)
</Execution_Policy>

<Steps>
1. Detect venue style file (`neurips_*.sty`, `iclr*.sty`, `acl*.sty`, `cvpr*.sty`) and set citation/format expectations.
2. Scan for the following classes:
   a. **Math hygiene**: `$A_i_j$` (double subscript), `$log(x)$` (should be `\log`), `$\mathbf{x}^T$` vs `$\top$` inconsistency, missing `\text{}` inside math, `$f(x)$` inside text vs `$f$`.
   b. **Citations**: wrong `\cite` variant for venue (`\cite` vs `\citep` vs `\citet`), missing non-breaking space `~\citep{}`, duplicate bibkeys, orphan bib entries.
   c. **References**: hard-coded "Figure 3" / "Table 2" / "Section 4" → `\Cref{}` / `\cref{}` where cleveref is available.
   d. **Macros**: inconsistent method name (`\methodname` vs literal), undefined macros, macros defined twice, orphan macros.
   e. **Spacing**: `e.g.` without `\eg{}`, `i.e.` without `\ie{}`, wrong en-dash/em-dash, French spacing after periods ending initials (`A. B.` vs `A.~B.`), stray `~` misuse.
   f. **Floats**: `[h]` only placement (should include `tb!`), figures outside their referencing section, missing `\label`.
   g. **Typography**: widow/orphan lines, long sentences that trigger overfull hbox, lowercase caption first word, missing period at caption end.
   h. **Bib hygiene**: arXiv entries that now have venue version, missing DOI, inconsistent author formatting (`J. Smith` vs `Smith, J.`), year typos.
3. For each finding classify blocker / reviewer-noise / nit.
4. Apply auto-fixes for deterministic cases (hard-coded refs → `\Cref`, `\cite → \citep` under NeurIPS, etc.). Emit a human-review list for ambiguous cases.
5. Re-compile via latexmk if available; confirm clean build + zero overfull hbox.
6. Emit report + diff bundle + TODO list.
</Steps>

<Tool_Usage>
- Read: .tex, .bib, .sty, .cls files
- Grep: scan for citation variants, math patterns, hard-coded refs
- Edit: apply deterministic fixes
- Bash: run `latexmk -pdf -interaction=nonstopmode` to verify clean build
- Write: emit `latex_polish_report_<date>.md` with diff
</Tool_Usage>

<Output_Format>
```
## LaTeX Polish Report — [paper name, venue]

### Compile Status
- clean / warnings / errors: ...
- overfull hbox count: ...

### Blockers (compile / reference errors)
- [file:line] — undefined ref `\ref{fig:foo}` — add `\label` or fix key

### Reviewer-noise (mechanical issues)
| File:line | Class | Original | Rewrite | Applied? |
|---|---|---|---|---|
| intro.tex:42 | citation | `\cite{devlin19}` | `\citep{devlin19}` | ✓ |
| method.tex:88 | math | `$log(x)$` | `$\log(x)$` | ✓ |
| exp.tex:120 | hard-ref | `Figure 3` | `\Cref{fig:arch}` | ✓ |

### Nits (optional)
| File:line | Suggestion |
|---|---|

### Needs Human Review
- [file:line] — ambiguous rewrite (explain why)

### Bib Hygiene
- [key] — arXiv → venue version found, consider updating

### Verdict
- [submission-ready / needs-human-pass / blockers-present]
```
</Output_Format>

<Examples>
<Good>
Found 23 `\cite{}` → `\citep{}` replacements (NeurIPS), 4 `$log$` → `$\log$`, 7 hard-coded "Figure X" → `\Cref`, 2 duplicate bib keys, 1 overfull hbox from an unbroken URL. Applied 34 deterministic fixes, flagged 3 for human review (macro name collision). Clean build confirmed.
</Good>

<Bad>
Output: "polished the tex."
Why bad: no diff, no count, no severity classification, can't be trusted.
</Bad>
</Examples>

<Final_Checklist>
- [ ] Venue style detected and citation convention applied
- [ ] Math hygiene scan complete
- [ ] Hard-coded refs replaced with cleveref where possible
- [ ] Macro consistency verified
- [ ] Bib duplicate / orphan / arXiv-upgradable check
- [ ] latexmk clean build confirmed
- [ ] Diff bundle emitted; no silent rewrites
</Final_Checklist>
