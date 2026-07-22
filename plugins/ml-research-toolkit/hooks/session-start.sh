#!/usr/bin/env bash
# Emit this plugin's rules as SessionStart additionalContext.
# (SessionStart does not support prompt-type hooks; command-type + JSON stdout is the supported path.)
cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "[ml-research-toolkit rules — apply to VLM/LLM research work]\n\nFact & citation integrity: never write a guessed fact/citation as confirmed. Prefer primary sources (arXiv / ACL Anthology / venue proceedings originals, official repos). Verify citations before use — delegate to arxiv-verify / citation-workflow (skills), prior-art survey to paper-lookup / literature-scout. Mark unverifiable citations as PLACEHOLDER + TODO; never fabricate. State uncertainty; label estimates as estimates. Author↔review separation: don't self-approve your own claims — a claim-evidence map / reviewer-angle pass is a separate lane.\n\nCode style: match surrounding code; small focused diffs; type hints on public signatures; fix seeds for reproducibility; be explicit about device/dtype; no hardcoded secrets or absolute local paths; notebooks beginner-friendly, scripts precise.\n\nCommunication: Korean prose, English for technical terms / identifiers / code. No unsupported superlatives ('always/best/perfect'); conditionals instead. Conclusion first. Honest status reporting (failed experiments reported as failed, with evidence).\n\nFull rule text ships in this plugin's rules/ directory (code-style, communication, fact-integrity). See the plugin README to enable them as always-on @import rules in your own CLAUDE.md."
  }
}
JSON
exit 0
