---
name: arxiv-verify
description: Verify arXiv / ACL Anthology / venue metadata for a paper reference before citing. Fetches the canonical source, confirms authors, title, year, venue, and normalizes the arXiv ID. Use this before inserting ANY citation into a literature review, Related Work section, or paper draft — training-data recall is not sufficient.
argument-hint: "<arxiv id | paper title | URL>"
level: 3
---

<Purpose>
Citation fabrication is the single most damaging error a research agent can commit. This skill replaces recall with retrieval: every citation insertion must pass through a verification step that fetches the canonical source and extracts metadata from it, not from memory.
</Purpose>

<Use_When>
- paper-scout is about to list a paper in a literature scan
- academic-writer is about to insert a `\cite{...}` or `[Author, Year]` reference into a draft
- A user claims "I saw a paper called X by Y" and wants it grounded before building on top
- Related Work is being assembled and each entry must be verifiable
</Use_When>

<Do_Not_Use_When>
- The user only wants a casual pointer to a well-known foundational paper AND explicitly accepts unverified recall
- The reference is already marked `[unverified]` and the user has chosen to keep it that way
- The skill is being invoked for a non-paper artifact (blog post, GitHub repo) — use WebFetch directly
</Do_Not_Use_When>

<Why_This_Exists>
A plausible-looking but fabricated `arXiv:2XXX.XXXXX` destroys reviewer trust and can get a paper desk-rejected for integrity reasons. Models are known to confabulate arXiv IDs, author orderings, and venues. The only defense is to fetch the canonical page every time and extract metadata from the fetched content, not from prior belief.
</Why_This_Exists>

<Execution_Policy>
- Always fetch at least one canonical source (arXiv abs page, ACL Anthology page, or venue proceedings page) before emitting a citation
- If fetching fails for all candidate sources, emit `[unverified]` — never fall back to recall
- Normalize arXiv IDs to the canonical `YYMM.NNNNN` form (no `v2` suffix unless the user specifically wants a version pin)
- Record the fetched URL alongside the metadata so future agents can re-verify
</Execution_Policy>

<Steps>
1. Parse input. Three accepted forms:
   - arXiv ID (e.g., `2403.12345`)
   - paper title (free text)
   - URL (arxiv.org, aclanthology.org, openreview.net, proceedings page)

2. Resolve to canonical URL:
   - arXiv ID → `https://arxiv.org/abs/<id>`
   - Title → WebSearch for `site:arxiv.org "<title>"` and `site:aclanthology.org "<title>"`; pick the top match whose fetched title matches the query (case-insensitive, allow minor punctuation)
   - URL → use as-is

3. WebFetch the canonical URL. Extract from the fetched content:
   - Title (exact)
   - Author list (full, in order)
   - Year (from submission date, not today's date)
   - Venue (arXiv preprint / conference / journal — do NOT upgrade arXiv to "NeurIPS 2024" without venue evidence)
   - Abstract (first 500 chars, for downstream summarization)
   - arXiv ID (canonical form, no version suffix)

4. Cross-check:
   - If the user supplied a title, verify the fetched title matches (fuzzy match, flag if diverges > 10%)
   - If the user supplied expected authors, verify first author matches
   - If mismatch, return a verification-failed record with the discrepancy highlighted

5. Emit a verified citation record.
</Steps>

<Tool_Usage>
- WebFetch: canonical source retrieval. Do NOT rely on WebSearch result snippets alone — snippets can be wrong.
- WebSearch: title → URL resolution only. Never use search result text as the citation source.
</Tool_Usage>

<Output_Format>
```
## Citation Verified

- **Title**: [exact fetched title]
- **Authors**: [first-author et al. | full list if ≤4]
- **Year**: YYYY
- **Venue**: [arXiv preprint | ACL 2024 | NeurIPS 2023 | ...]
- **arXiv ID**: YYMM.NNNNN  (or "N/A")
- **Canonical URL**: [URL fetched]
- **Verification**: fetched_at=<timestamp>, matches_query=yes/no
```

On verification failure:
```
## Citation UNVERIFIED

- **Query**: [what was searched]
- **Reason**: [fetch failed | title mismatch | multiple candidates]
- **Candidates seen**: [up to 3]
- **Recommendation**: ask user to supply arXiv ID or full URL
```
</Output_Format>

<Examples>
<Good>
Input: "Engram paper by Cheng"
Action: WebSearch `site:arxiv.org "Engram" Cheng`; fetch top candidate abs page; extract {title, authors, year, id}. Return verified record with canonical URL.
</Good>

<Good>
Input: `2601.07372`
Action: WebFetch `https://arxiv.org/abs/2601.07372`; parse metadata from fetched page.
</Good>

<Bad>
Input: "some recent LaVIT follow-up"
Action: Return a made-up arXiv ID from memory.
Why bad: Confabulation. Instead, WebSearch for candidates and return the verified top match OR `[unverified]` with recommendation.
</Bad>
</Examples>

<Final_Checklist>
- [ ] Canonical URL was actually fetched (not just searched)
- [ ] Metadata was extracted from fetched content, not recalled
- [ ] arXiv ID is in canonical `YYMM.NNNNN` form
- [ ] Venue is not upgraded beyond what the source claims (arXiv ≠ NeurIPS)
- [ ] Mismatch between query and fetched title is flagged, not hidden
</Final_Checklist>
