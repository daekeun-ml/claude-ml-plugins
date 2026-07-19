---
name: paper-lookup
description: Survey prior art for a specific claim or method using Semantic Scholar, arXiv, OpenReview, ACL Anthology, and venue proceedings. Returns a deduplicated, per-paper structured summary (TL;DR, contribution, method, key result, relevance, gap this work could fill) and a freshness-checked citation graph. Use when writing Related Work, positioning a contribution, or verifying that an idea hasn't been published.
argument-hint: "<topic or specific claim>, <time window e.g. 2022-2026>, <target venues>"
level: 3
---

<Purpose>
Top-venue reviewers know the recent literature. Missing a paper from the last 12 months that does something similar is the single fastest path to a desk reject. This skill does a structured, multi-source survey with explicit deduplication and freshness check, so the author walks in knowing every close neighbour and exactly how the new work differs.
</Purpose>

<Use_When>
- Drafting Related Work section
- Positioning a new contribution ("what is our novelty axis?")
- Responding to a reviewer who cites a paper you haven't seen
- Pre-submission "have we missed anything?" sanity check
- Planning a new experiment and need to confirm the idea is fresh
</Use_When>

<Do_Not_Use_When>
- You need a single known-paper lookup — use arxiv-verify directly
- The survey is tangential to your work — skip, save budget for core neighbours
</Do_Not_Use_When>

<Why_This_Exists>
Relying on training-data recall is dangerous — cutoff drift, venue name confusion, year mistakes, and hallucinated titles are all common. A disciplined lookup with explicit source URLs and cross-source verification is the only trustworthy method. Structured per-paper summaries also let the writer copy-paste into Related Work with minimal rewriting.
</Why_This_Exists>

<Execution_Policy>
- Query at least 3 distinct sources (Semantic Scholar API, arXiv, OpenReview or venue proceedings)
- Dedup by arXiv ID + title substring match
- Every entry must have a verifiable URL and (if arXiv) canonical ID
- Never invent titles or author lists — if unsure, flag as "needs-manual-verify"
- Sort by relevance × recency, not by title
</Execution_Policy>

<Steps>
1. Parse the topic into 2–4 query variants (broad, narrow, keyword-based, author-based if known).
2. For each source:
   a. **Semantic Scholar**: query, pull top 20 by relevance, collect {title, authors, year, venue, TL;DR, citation count, arXiv ID if any}.
   b. **arXiv**: search by terms + filter by date window.
   c. **OpenReview**: if target venue is NeurIPS/ICLR/ACL, scan the current and previous year's accepted papers.
   d. **Venue proceedings** (ACL Anthology, CVF Open Access): final published versions with DOIs.
3. Deduplicate across sources by {arXiv ID, title substring ≥ 0.9 Jaccard}.
4. For each unique entry, fetch abstract (and first page if available) and produce structured summary:
   - TL;DR (1 sentence)
   - Contribution (what's new)
   - Method (2–3 bullets)
   - Key result (1 number / claim)
   - Relevance to our work (1–3 sentences)
   - Gap our work would fill (1 sentence)
5. Build a citation graph: for the top-5 most relevant, fetch their "cited by" and "references" lists, dedup against our set, re-add any that passed relevance threshold.
6. Cross-verify freshness: flag entries where cutoff > 12 months old if the topic is fast-moving.
7. Emit survey report with explicit source URLs and per-entry gap analysis.
</Steps>

<Tool_Usage>
- WebFetch: Semantic Scholar graph API, arXiv API, OpenReview API, venue sites
- WebSearch: as fallback for less-indexed items
- Read: existing related-work .tex files to avoid re-surveying what's already cited
- Write: emit `paper_lookup_<topic>_<date>.md`
</Tool_Usage>

<Output_Format>
```
## Paper Lookup — [topic], [window], [venues]

### Query Strategy
- Query 1 (broad): "..."
- Query 2 (narrow): "..."
- Sources hit: Semantic Scholar, arXiv, OpenReview

### Core Neighbours (top-N by relevance × recency)
#### [1] Paper Title — Authors, Venue Year
- **arXiv**: 2501.xxxxx  |  **OpenReview**: ...  |  **Citations**: 47
- **TL;DR**: ...
- **Contribution**: ...
- **Method**: • ... • ... • ...
- **Result**: [number / claim]
- **Relevance to our work**: ...
- **Gap we could fill**: ...

#### [2] ...

### Adjacent / Dual-Use Neighbours
- (list with 1-line summary each)

### Potentially Redundant Work (flag)
- [paper] — does X; overlaps with our proposed Y; need to differentiate by ...

### Citation Graph Additions (from cited-by / references sweep)
- ...

### Verdict
- Novelty axis intact / needs-differentiation / idea-already-published
- Missing citations to add to Related Work: [bibkeys]
```
</Output_Format>

<Examples>
<Good>
Topic: "query-conditioned memory key for VLM". 3 sources × 2 queries = 9 hits, dedup → 14 unique. Found 2 direct competitors (one NeurIPS'25, one arXiv'26), both differ on "key stays deterministic" — our novelty axis holds. 3 adjacent works cited for Related Work. Cited-by sweep surfaced 1 more OpenReview submission with pending decision.
</Good>

<Bad>
Output: a list of 30 papers from training-data recall, no URLs, no dedup.
Why bad: unverifiable, likely hallucinated, no gap analysis.
</Bad>
</Examples>

<Final_Checklist>
- [ ] ≥3 sources queried
- [ ] Deduplicated by arXiv ID + title
- [ ] Each entry has verifiable URL
- [ ] Top-5 citation graph (cited-by + references) expanded
- [ ] Gap analysis per entry
- [ ] Freshness flagged for stale entries
- [ ] Verdict on novelty-axis integrity
</Final_Checklist>
