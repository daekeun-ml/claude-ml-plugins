# daekeun-ml-plugins

*[English](README.md) · 한국어*

Claude Code **플러그인 마켓플레이스**입니다. AWS ML 인프라용과 VLM/LLM 연구용, 두 개의 플러그인을 담고 있으며 각각 스킬·서브에이전트·규칙으로 구성됩니다.

## 플러그인

| plugin | 상태 | 설명 |
|---|---|---|
| [`aws-sagemaker-toolkit`](plugins/aws-sagemaker-toolkit) | ✅ 사용 가능 | EC2/HyperPod/SageMaker 3-tier — 플랫폼 선택, 가이드 작성, SageMaker 심화, E2E 파인튜닝(인터뷰→학습→배포→agentic), 실습 코드, 사실 검증. 11 skills + 5 subagents + 6 rules |
| [`ml-research-toolkit`](plugins/ml-research-toolkit) | ✅ 사용 가능 | VLM/LLM 연구 파이프라인 — 아이디어/문헌, 실험·ablation 설계, 컴퓨트 계획, 학습 진단, 평가 분석, 해석성, 논문 작성, 리뷰 대응. 21 skills + 12 subagents + 3 rules |

각 플러그인의 스킬·에이전트 상세는 해당 폴더의 README를 참고하세요.

## 설치

```
# 마켓플레이스 등록 (한 번만)
/plugin marketplace add <owner>/claude-ml-plugins

# 개별 플러그인 설치
/plugin install aws-sagemaker-toolkit@daekeun-ml-plugins
/plugin install ml-research-toolkit@daekeun-ml-plugins
```

`<owner>`는 이 저장소를 올린 GitHub 계정으로 바꿔 주세요. 설치 없이 한 세션만 테스트하려면 각 플러그인 README의 `--plugin-dir` 방법을 참고하세요.

> 참고: 마켓플레이스 이름은 `daekeun-ml-plugins`이고, 저장소(repo) 이름은 `claude-ml-plugins`입니다. 둘은 별개이며, 설치 명령의 `@daekeun-ml-plugins`는 마켓플레이스 이름입니다.

## 구조

```
claude-ml-plugins/
├── .claude-plugin/
│   └── marketplace.json          # 마켓플레이스 카탈로그 (플러그인 목록)
├── plugins/
│   ├── aws-sagemaker-toolkit/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/               # 11 skills
│   │   ├── agents/               # 5 subagents
│   │   ├── rules/                # 6 rules (README의 로딩 안내 참고)
│   │   ├── hooks/hooks.json      # SessionStart 규칙 주입
│   │   ├── README.md · README_ko.md
│   └── ml-research-toolkit/      # 21 skills + 12 subagents + 3 rules
│       ├── .claude-plugin/plugin.json
│       ├── skills/
│       ├── agents/
│       ├── rules/                # 3 rules (code-style·communication·fact-integrity)
│       ├── hooks/hooks.json      # SessionStart 규칙 주입
│       └── README.md · README_ko.md
├── LICENSE
├── README.md · README_ko.md
```

## ⚠️ 규칙(rules) 로딩

Claude Code 플러그인은 `CLAUDE.md`나 `@import`를 자동으로 로드하지 않습니다. 두 플러그인 모두 ① SessionStart 훅으로 핵심 규칙을 세션 시작 시 주입하고, ② 규칙 전문을 각자의 `rules/` 폴더에 포함합니다. 규칙을 항상 로드하고 싶으시면 각 플러그인 README의 안내를 따라 주세요.


## 라이선스
MIT
