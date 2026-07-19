# daekeun-ml-plugins

*English · [한국어](README_ko.md)*

A Claude Code **plugin marketplace** distributing skills, subagents, and rules for AWS ML infrastructure and VLM/LLM research.

## Plugins

| plugin | status | description |
|---|---|---|
| [`aws-sagemaker-toolkit`](plugins/aws-sagemaker-toolkit) | ✅ available | EC2 / HyperPod / SageMaker 3-tier — platform selection, SageMaker deep-dive, E2E fine-tuning (interview → training → deploy → agentic), hands-on lab code. 11 skills + 5 subagents + 6 rules |
| [`ml-research-toolkit`](plugins/ml-research-toolkit) | ✅ available | VLM/LLM research pipeline — ideation/literature, experiment & ablation design, compute planning, training diagnostics, eval analysis, interpretability, paper writing, rebuttals. 21 skills + 12 subagents + 3 rules |

## Install

```
# Add the marketplace (once)
/plugin marketplace add daekeun-ml/claude-ml-plugins

# Install individual plugins
/plugin install aws-sagemaker-toolkit@daekeun-ml-plugins
/plugin install ml-research-toolkit@daekeun-ml-plugins
```

For local testing, see each plugin's README for `--plugin-dir`.

> Note: the marketplace name is `daekeun-ml-plugins` and the repository name is `claude-ml-plugins`. They are distinct — the `@daekeun-ml-plugins` in the install command is the marketplace name.

## Update

```
# Pull the latest marketplace catalog (do this first)
/plugin marketplace update daekeun-ml-plugins

# Reinstall a plugin to pick up the latest version
/plugin install aws-sagemaker-toolkit@daekeun-ml-plugins
```

> `marketplace update` only refreshes the catalog — already-installed plugins are not auto-upgraded. Reinstall as above (or run `/reload-plugins`) to apply the latest version.

## Uninstall

```
# Remove a single plugin
/plugin uninstall aws-sagemaker-toolkit@daekeun-ml-plugins

# Remove the whole marketplace (also removes its plugins)
/plugin marketplace remove daekeun-ml-plugins
```

> Tip: `/plugin` with no arguments opens an interactive manager where you can browse, enable/disable, update, and remove everything from a menu.

## Structure

```
claude-ml-plugins/
├── .claude-plugin/
│   └── marketplace.json          # marketplace catalog (plugin list)
├── plugins/
│   ├── aws-sagemaker-toolkit/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/               # 11 skills
│   │   ├── agents/               # 5 subagents
│   │   ├── rules/                # 6 rules (see README for loading)
│   │   ├── hooks/hooks.json      # SessionStart rule injection
│   │   └── README.md
│   └── ml-research-toolkit/      # 21 skills + 12 subagents + 3 rules
│       ├── .claude-plugin/plugin.json
│       ├── skills/
│       ├── agents/
│       ├── rules/                # 3 rules (code-style·communication·fact-integrity)
│       ├── hooks/hooks.json      # SessionStart rule injection
│       └── README.md
├── LICENSE
└── README.md
```

## ⚠️ Loading rules
Plugins do **not** auto-load `CLAUDE.md`/`@import`. Each plugin injects its core rules via a SessionStart hook and ships the full rule text under `rules/`. For always-on loading, follow the instructions in each plugin's README.

## License
MIT
