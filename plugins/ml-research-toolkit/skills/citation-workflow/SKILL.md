---
name: citation-workflow
description: Verify and fetch BibTeX for paper citations using Semantic Scholar, arXiv, and DOI APIs. Searches by title/author, confirms metadata, fetches canonical BibTeX, and marks unresolvable entries as PLACEHOLDER with TODO comments. Use when adding new citations to a paper or auditing an existing .bib file for hallucinated entries.
argument-hint: "<paper title or partial citation>, <.bib file path (optional)>"
level: 2
---

<Purpose>
AI-generated citations have ~40% error rate. A hallucinated BibTeX entry (wrong authors, wrong year, non-existent DOI) is academic misconduct and damages credibility. This skill enforces a three-source verification chain before any citation enters the .bib file.
</Purpose>

<Use_When>
- Adding new \cite{} entries to a paper draft
- Auditing an existing .bib file for hallucinated or stale entries
- Resolving [CITATION NEEDED] / PLACEHOLDER markers left during drafting
- Bulk-verifying a reference list before camera-ready submission
</Use_When>

<Do_Not_Use_When>
- Citation is already in a trusted .bib file pulled from a venue anthology (ACL Anthology, IEEE Xplore BibTeX export) — those are authoritative
- The user only wants a reference summary, not a .bib entry
</Do_Not_Use_When>

<Critical_Rule>
**NEVER fabricate BibTeX from memory.** If a citation cannot be confirmed via API, mark it as:
```latex
\cite{PLACEHOLDER_author2024_keyword}  % TODO: verify manually
```
and emit a TODO item. A placeholder that is honest beats a hallucinated entry that is wrong.
</Critical_Rule>

<Verification_Chain>
Search in this order; stop at the first source that confirms the paper:

1. **Semantic Scholar** — title + author keyword search, returns externalIds (ArXiv, DOI, CorpusId)
2. **arXiv** — direct abs/pdf URL if ArXiv ID is known; parse title/author/abstract to confirm identity
3. **DOI → BibTeX** — fetch canonical BibTeX via `https://doi.org/{doi}` with `Accept: application/x-bibtex`

If none confirm: mark PLACEHOLDER.
</Verification_Chain>

<Steps>
1. Parse input: extract paper title (or partial title), author name hints, year hint if given.

2. **Semantic Scholar search**:
```python
import requests
r = requests.get(
    "https://api.semanticscholar.org/graph/v1/paper/search",
    params={
        "query": "<title keywords>",
        "fields": "title,authors,year,externalIds,venue",
        "limit": 5
    }
)
```
   - Match top result: confirm title similarity (≥80% token overlap) AND author last-name match
   - Extract: `externalIds.ArXiv`, `externalIds.DOI`, `externalIds.CorpusId`
   - If no confident match → proceed to arXiv

3. **arXiv confirmation** (if ArXiv ID found or suspected):
```python
abs_url = f"https://arxiv.org/abs/{arxiv_id}"
# Fetch and parse: <title>, <authors>, <abstract>
```
   - Confirm title and author match
   - Extract: submission date → year, authors list → BibTeX author field

4. **BibTeX fetch** (if DOI confirmed):
```python
import requests
doi = "<confirmed DOI>"
r = requests.get(
    f"https://doi.org/{doi}",
    headers={"Accept": "application/x-bibtex"},
    allow_redirects=True
)
bibtex = r.text  # canonical BibTeX from publisher/crossref
```
   - If DOI fetch fails, construct BibTeX manually from confirmed Semantic Scholar / arXiv metadata
   - Use cite key format: `author2024keyword` (first-author lastname + year + 1-2 word title token)

5. **Unresolvable entries**: emit placeholder with TODO:
```bibtex
@misc{PLACEHOLDER_smith2024attention,
  title  = {<title as given>},
  author = {<author as given>},
  year   = {2024},
  note   = {TODO: verify — could not confirm via Semantic Scholar/arXiv/DOI}
}
```

6. **Bulk audit mode** (when a .bib file is provided):
   - Parse all entries; for each, run the verification chain
   - Flag: confirmed ✓ / unverified ⚠ / likely-hallucinated ✗
   - "Likely hallucinated": title search returns 0 results AND DOI 404s AND no arXiv match

7. Append verified entries to target .bib file (or create `citations_verified.bib`)
   - Never overwrite the original .bib; append or write a separate file
   - Emit a summary table of all resolved / placeholder entries

8. Emit action list for TODOs.
</Steps>

<Tool_Usage>
- WebFetch: Semantic Scholar API, arXiv abs pages, DOI → BibTeX endpoint
- WebSearch: fallback when API returns 0 results (Google Scholar / ACL Anthology / venue proceedings search)
- Read: existing .bib file to audit, paper .tex files to extract \cite{} keys
- Write: append to .bib file or create `citations_verified_<date>.bib`; emit `citation_todos.md`
- Agent(subagent_type="literature-scout"): when a citation search requires broader multi-source survey (cited-by graph expansion, deduplication across sources)
- Agent(subagent_type="paper-scout"): when full per-paper metadata (TL;DR, contribution, method) is needed alongside the BibTeX entry
</Tool_Usage>

<Output_Format>
```
## Citation Verification — [date]

### Verified ✓
| Cite key | Title | Source | DOI / ArXiv |
|---|---|---|---|
| vaswani2017attention | Attention Is All You Need | Semantic Scholar + DOI | 10.48550/arXiv.1706.03762 |

### Placeholders ⚠ (need manual check)
| Cite key | Given title | Reason |
|---|---|---|
| PLACEHOLDER_smith2024foo | "Foo bar baz" | No Semantic Scholar match; DOI 404 |

### Likely Hallucinated ✗
| Cite key | Given title | Evidence |
|---|---|---|
| jones2023novel | "Novel method for..." | 0 SS results, no arxiv, author unknown |

### BibTeX written to
- `citations_verified_2026-04-29.bib` (N entries)

### TODO List
- [ ] Manually verify PLACEHOLDER_smith2024foo — try ACL Anthology / Google Scholar
- [ ] Confirm jones2023novel is not hallucinated before submission
```
</Output_Format>

<Examples>
<Good>
Input: "cite: 'Memory-augmented neural networks, Graves 2016'". 
→ Semantic Scholar search: top hit "Hybrid computing using a neural network with dynamic external memory", Graves et al. 2016, DOI 10.1038/nature20101. 
→ DOI BibTeX fetched. Cite key: graves2016hybrid. Confirmed ✓.
</Good>

<Good>
Bulk audit of 30-entry .bib file: 24 confirmed ✓, 4 placeholders ⚠ (no DOI but arXiv confirmed), 2 likely hallucinated ✗ (0 search results, non-existent DOIs). Summary table + 6-item TODO list emitted.
</Good>

<Bad>
"The citation looks correct based on my knowledge." — No API call, no confirmation, no cite key, no BibTeX. Fails the verification chain entirely.
</Bad>
</Examples>

<Final_Checklist>
- [ ] Semantic Scholar search attempted for every entry
- [ ] arXiv confirmation run when ArXiv ID available
- [ ] DOI → BibTeX fetch run when DOI available
- [ ] Unresolvable entries marked PLACEHOLDER with TODO comment
- [ ] Likely-hallucinated entries flagged separately
- [ ] Cite keys follow `author2024keyword` format
- [ ] Output written to separate file (original .bib never overwritten)
- [ ] Summary table + TODO list emitted
</Final_Checklist>
