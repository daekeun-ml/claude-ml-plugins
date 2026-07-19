# Reviewer Evaluation Criteria — LLM/VLM Research

리뷰어가 평가하는 주요 기준과 선제 대응 방법.

---

## NeurIPS / ICML / ICLR 공통 기준

| 기준 | 점수 범위 | 선제 대응 |
|------|----------|---------|
| Originality | 1–4 | contribution bullet을 falsifiable하게 |
| Quality | 1–4 | ablation으로 각 컴포넌트 검증 |
| Clarity | 1–4 | Figure 1 + 직관적 수식 설명 |
| Significance | 1–4 | 커뮤니티 영향 명시 |

---

## 자주 나오는 약한 리뷰 이유 (예방법)

### 1. "Contribution이 불명확"
- **원인**: "we study X" 형태의 bullet
- **예방**: "We propose X that improves Y by Z% on W" 형태로

### 2. "베이스라인이 공정하지 않다"
- **원인**: 제안 방법만 튜닝
- **예방**: 모든 베이스라인 동일 조건 + 튜닝 방법 명시

### 3. "실험이 제한적"
- **원인**: 단일 데이터셋/태스크
- **예방**: 최소 2–3개 벤치마크, 다양한 설정

### 4. "왜 이 방법이 효과적인지 이해 못 함"
- **원인**: 수치만 있고 분석 없음
- **예방**: ablation + 오류 분석 + 시각화

### 5. "관련 연구 누락"
- **원인**: 서베이 불충분
- **예방**: `literature-scout` 에이전트로 사전 서베이, related work에서 차이 명시

### 6. "재현성 부족"
- **원인**: 하이퍼파라미터/시드 미명시
- **예방**: 구현 세부사항 appendix에 전부 기재

---

## LLM/VLM 논문 특화 리뷰 포인트

### "더 큰 모델이면 해결되는 거 아닌가?"
- 예방: 동일 파라미터 수 베이스라인 비교, 또는 파라미터 효율성 분석

### "트레이닝 데이터가 다른 것 아닌가?"
- 예방: 트레이닝 데이터 구성 명시, 공정한 비교 기준 설명

### "Eval 데이터가 트레이닝에 포함된 것 아닌가?"
- 예방: 데이터 중복 검사 결과 명시

### "Prompt engineering에 의존하는 거 아닌가?"
- 예방: 여러 prompt 템플릿으로 robustness 확인

### "Human evaluation이 없다"
- 예방: human eval 추가 또는 자동 지표의 human correlation 인용

---

## Rebuttal 전략

1. 리뷰어 점수별 우선순위: weak accept 이상 → 강화, borderline → 결정적 증거 추가
2. 새 실험 결과 포함 가능 (대부분 venue 허용)
3. 오해에는 정중히 clarification, 약점에는 인정 + 추가 증거
4. 장황한 변명 대신 수치로 답변

`rebuttal-drafter` 스킬 활용.
