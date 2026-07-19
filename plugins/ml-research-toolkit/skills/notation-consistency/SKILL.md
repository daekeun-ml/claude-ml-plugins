---
name: notation-consistency
description: Scan the paper for notation inconsistencies across sections (variable re-use, dimension mismatch, index letter collisions, bold/italic rules, undefined symbols, Greek-vs-Roman name drift). Emits a symbol table with declarations and all usages; flags conflicts and proposes a canonical form. Use after the paper is structurally complete, before the polish pass.
argument-hint: "<tex source dir>, <method section path>"
level: 2
---

<Purpose>
Reviewers and readers lose patience the moment a symbol means two different things. Notation drift happens silently as a paper is rewritten: `d_h` in Section 3 becomes `d_\text{hidden}` in Section 4, `\alpha` is a gate in one figure and a learning rate in another. This skill enforces a single source of truth.
</Purpose>

<Use_When>
- Paper is structurally complete but prose is still malleable
- After major rewrite or merge of separate drafts
- Before first submission
- When reviewer said "notation was confusing"
</Use_When>

<Do_Not_Use_When>
- Early draft; notation will still churn
- Post camera-ready
</Do_Not_Use_When>

<Why_This_Exists>
Top-venue papers have surprisingly many notation bugs, most introduced during late rewrites. Symptoms:
1. **Variable reuse** — `i` is batch index in eq. 2, token index in eq. 7.
2. **Dimension drift** — `W_q ∈ R^{D × D}` in one place, `R^{d × D}` in another.
3. **Bold/italic churn** — `\mathbf{v}` vs `v` for the same object.
4. **Undefined symbols** — `\Phi` appears without a definition.
5. **Greek-Roman drift** — `\alpha` becomes `a` in prose.
A pass through the full source with a symbol table catches all five.
</Why_This_Exists>

<Execution_Policy>
- Extract every `$...$` math fragment and `\begin{equation}` block
- Build symbol table: {symbol, first-appearance, meaning, dimension, style(bold/italic)}
- Flag any symbol whose {meaning, dimension, style} changes between usages
- Require every non-standard symbol to have a declaration sentence
- Suggest canonical form and auto-replace where deterministic
</Execution_Policy>

<Steps>
1. Parse .tex sources. For each math fragment:
   - Tokenise into symbols (single letters + Greek + `\mathbf{...}` groups)
   - Record surrounding sentence as local context

2. For each unique symbol, determine declaration:
   - Look backward in source for "let X = ...", "X denotes ...", "where X is ..."
   - If none found in preceding 200 words, flag "undeclared".

3. For each symbol, determine meaning from declaration. Normalize to a short tag.

4. Cross-section sweep:
   - Same symbol, different meaning → **collision**
   - Same symbol, different dimension → **dimension drift**
   - Same meaning, different symbol → **synonym drift** (less critical but noted)
   - Same symbol, bold in one place, plain in another → **style drift**

5. Standard-index convention check:
   - `b` for batch, `t` for time/token, `h/w` for height/width, `l` for layer, `i/j` generic
   - Flag unconventional use (e.g., `b` used for batch in eq. 2 and hidden dim in eq. 5)

6. Propose canonical form:
   - Pick dominant-usage form for each symbol
   - Emit find-replace suggestions with file:line pointers

7. Generate symbol table for Appendix / "Notation" paragraph if paper lacks one.
</Steps>

<Tool_Usage>
- Read: all .tex files
- Grep: math-mode patterns, `\newcommand` definitions
- Edit: apply deterministic find-replace for style / bold-italic
- Write: emit `notation_audit.md` + `symbol_table.md`
</Tool_Usage>

<Output_Format>
```
## Notation Audit — [paper]

### Symbol Table
| Symbol | Meaning | Dimension | Style | First declared | Usage count |
|---|---|---|---|---|---|
| $\alpha$ | gate value | scalar ∈ [0,1] | plain | method.tex §3.2 eq 4 | 23 |
| $\mathbf{v}$ | visual engram embedding | R^{d_e} | bold | method.tex §3.1 | 17 |
| $d_e$ | engram dim | scalar | plain italic | method.tex §3 intro | 12 |

### Conflicts
| Symbol | Issue | Locations | Proposed fix |
|---|---|---|---|
| $i$ | batch in eq.2, token in eq.7 | method.tex:42, :88 | Rename eq.7 to $t$ |
| $W_q$ | R^{D×D} vs R^{d×D} | method.tex:51, experiments.tex:12 | Use R^{d×D} (dominant) |
| $\alpha$ | gate vs learning rate | method.tex:60, appendix.tex:15 | Rename LR to $\eta$ |

### Undeclared Symbols
- $\Phi$ — first appears method.tex:105 without declaration — add "where $\Phi$ is the ..."

### Style Drift
| Symbol | Occurrences | Suggested canonical |
|---|---|---|
| $v$ vs $\mathbf{v}$ | 7 vs 17 | always $\mathbf{v}$ |

### Standard-Index Compliance
- $b$ used for batch ✓
- $i$ reused for token — rename to $t$

### Apply Suggestions
- [ ] Deterministic replacements ready to apply (11 items)
- [ ] Human-review needed (3 items)

### Verdict
- clean / minor-fixes / major-conflicts
```
</Output_Format>

<Examples>
<Good>
Paper has 47 unique symbols. 3 collisions (i / α / W_q), 2 style drifts (v bold/plain), 1 undeclared (Φ). 11 deterministic fixes applied, 3 flagged for human review. Emitted symbol table for appendix.
</Good>

<Bad>
"Looks consistent to me." No symbol table, no collision check.
</Bad>
</Examples>

<Final_Checklist>
- [ ] Every math symbol extracted with first appearance
- [ ] Each symbol has declaration or is flagged undeclared
- [ ] Collision sweep across sections complete
- [ ] Dimension drift check complete
- [ ] Style drift (bold/italic) check complete
- [ ] Standard index convention applied
- [ ] Symbol table ready for appendix if missing
</Final_Checklist>
