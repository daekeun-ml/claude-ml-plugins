---
name: device-audit
description: Training code device mapping audit — finds nn.Module/buffer/parameter instances not moved to the target device
argument-hint: "[--dir <path>] [--device cuda]"
triggers: ["device 확인", "device audit", "device 오류", "device mapping", "cpu 오류", "device mismatch"]
---

<Purpose>
PyTorch training 코드 전체에서 `nn.Module`, `register_buffer`, `nn.Parameter` 등으로
생성된 모든 텐서/모듈을 찾아, 각 training script에서 `.to(device)` 호출이 누락된 항목을 리포트.

실행 전에 "Expected all tensors to be on the same device" 에러를 사전 예방.
</Purpose>

<Use_When>
- "device 오류났어", "cpu/cuda mismatch", "device 확인해줘"
- 새 모듈/버퍼를 모델 정의 파일에 추가한 직후
- 새 training script 작성 후 device 이동 코드 점검 시
- 실험 실행 전 사전 검증 (pre-flight check)
</Use_When>

<Do_Not_Use_When>
- 특정 런타임 에러 스택트레이스 디버깅 — 직접 수정하는 것이 빠름
- 단순 import 오류나 argparse 오류
</Do_Not_Use_When>

<Steps>

## Step 1: 대상 파일 수집

`--dir` 미지정 시 현재 워킹 디렉토리에서 아래 두 범주 파일 탐색:

**모델 정의 파일** (모듈/버퍼가 선언되는 곳):
```bash
find . -path "./.venv" -prune -o -name "*.py" -print | \
  xargs grep -l "nn\.Module\|register_buffer\|nn\.Parameter" | \
  grep -v __pycache__
```

**Training script** (device 이동이 일어나야 하는 곳):
```bash
find . -path "./.venv" -prune -o -name "*.py" -print | \
  xargs grep -l "\.to(device\|\.to(args\." | \
  grep -v __pycache__
```

## Step 2: 모듈/버퍼 정의 추출 (정의 측)

모델 정의 파일에서 아래 패턴 grep:

```
self\.\w+\s*=\s*nn\.Linear
self\.\w+\s*=\s*nn\.Embedding
self\.\w+\s*=\s*nn\.Conv\w*
self\.\w+\s*=\s*nn\.Parameter
self\.\w+\s*=\s*nn\.\w*Layer\w*
self\.register_buffer\(\s*["'](\w+)["']
self\.\w+\s*=\s*\w*Module\w*\(
```

각 항목에 대해 수집:
- `file`: 파일 경로
- `name`: 속성 이름 (`self.<name>`)
- `line`: 라인 번호
- `kind`: Linear / Embedding / Conv / Buffer / Parameter / Module
- `conditional`: `= None`으로 초기화 후 조건부 할당이면 `True`

## Step 3: `.to(device)` 호출 추출 (이동 측)

Training script에서 아래 패턴 grep:

```
model\.\w+\s*=\s*model\.\w+\.to\(
\.\w+\s*=\s*\.\w+\.to\(device
device_map\s*=
\.to\(args\.device\)
\.to\(device\)
\.cuda\(\)
```

패턴 grep → `{script: [moved_names]}` 매핑 생성.

## Step 4: 교차 분석

각 training script에 대해:
- 정의된 모든 모듈/버퍼 이름 집합: `D`
- 해당 script에서 `.to(device)` 호출된 이름 집합: `M`
- **누락 목록** = `D - M`

**자동 커버 예외 처리:**
- `model.to(device)` 또는 `model = model.to(device)` — `__init__` 시점에 등록된 서브모듈 자동 커버
- `device_map="auto"` 또는 `device_map=device` — HuggingFace 모델 자동 배치
- 단, `__init__` 이후 **조건부/동적으로 생성된** 속성 (`self.foo = None` → 나중에 `self.foo = nn.Linear(...)`)은 `model.to()` 적용 범위 밖 → 개별 확인 필요

## Step 5: 리포트 출력

```
══════════════════════════════════════════════════════
 Device Audit Report
══════════════════════════════════════════════════════

[모델 정의 파일: <path>]

  self.<name_a>   nn.Linear       line <N>
  self.<name_b>   register_buffer line <N>  (conditional)
  ...

[Training Script: <path>]

  ✅ model.<name>  → .to(device)  line <N>
  ✅ model.<name>  → device_map   (auto-covered)
  ❌ MISSING: model.<name_b>  — defined in <file>:<line>, no .to(device) found
     ↳ conditional: None-guard 필요

══════════════════════════════════════════════════════
 Summary: <N> scripts checked | <N> OK | <N> has missing device moves
 Missing items: <N> across <N> scripts
══════════════════════════════════════════════════════

[Fix 제안]
<script_path> — build_model() 또는 모델 초기화 블록 마지막에 추가:

    if model.<name_b> is not None:
        model.<name_b> = model.<name_b>.to(device)
```

## Step 6: 자동 수정 제안 (선택)

누락 항목마다 가장 적합한 삽입 위치 탐색:
- 기존 `.to(device)` 블록 바로 아래가 이상적
- 조건부 모듈(`if model.xxx is not None`)은 None 가드 포함
- dtype 캐스팅 패턴(`.to(torch.float32)` 등)이 주변에 있으면 함께 제안

</Steps>

<Tool_Usage>
- Bash: grep 패턴으로 정의/이동 수집
- Read: 정확한 컨텍스트 확인
- Edit: 자동 수정 시 (사용자 승인 후)
- 결과는 인라인 리포트로 출력 — 별도 파일 생성 불필요
</Tool_Usage>

<Final_Checklist>
- [ ] 모델 정의 파일의 모든 nn.Module/register_buffer/nn.Parameter 항목 추출
- [ ] 각 training script별 .to(device) 커버 여부 교차 확인
- [ ] 조건부 할당 (`= None` → 나중에 `= nn.Linear(...)`) 케이스 탐지
- [ ] `model.to(device)` / `device_map=` 패턴으로 자동 이동되는 경우 예외 처리
- [ ] 누락 항목마다 fix 코드 스니펫 제시 (None-guard 포함)
- [ ] eval/inference script도 포함 확인 (학습 외 경로에서도 동일 문제 발생 가능)
</Final_Checklist>
