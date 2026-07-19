# ML Paper Writing Philosophy

Nanda, Karpathy, Farquhar, Lipton, Steinhardt의 작성 철학 요약.

---

## The Narrative Principle

**Nanda**: "논문은 짧고 엄밀하며 증거 기반의 기술적 이야기다. 독자가 신경 쓰는 takeaway가 있어야 한다."

세 기둥:
- **What**: 1–3개의 구체적이고 falsifiable한 새로운 주장
- **Why**: 강한 베이스라인과 경쟁 가설을 구별하는 실험
- **So What**: 커뮤니티가 중요하게 여기는 문제와의 연결

**Karpathy**: "논문은 하나의 것을 판다. 전체가 그 핵심 기여 중심으로 외과적 정밀도로 구성된다."

---

## 시간 배분 (Nanda)

각각 **같은 시간**을 투자:
1. Abstract
2. Introduction
3. Figure
4. 나머지 전부

**리뷰어 읽기 패턴**: title → abstract → introduction → figures → (관심 있으면) methods

---

## Abstract 5문장 공식 (Farquhar)

1. 무엇을 달성했나 ("We introduce...", "We prove...")
2. 왜 어렵고 중요한가
3. 어떻게 했나 (specialist keyword 포함)
4. 어떤 증거가 있나
5. 가장 인상적인 수치

**Lipton**: "첫 문장이 어떤 ML 논문에도 붙일 수 있으면 삭제하라."

---

## Sentence-Level Clarity (Gopen & Swan 1990)

**Topic–Stress 원칙:**
- 문장 시작 = **Topic** (독자가 이미 아는 것, 연결점)
- 문장 끝 = **Stress** (새로운 정보, 강조점)

```
❌ "A new approach is proposed in this paper to address..."
✅ "We address X by proposing Y, which achieves Z."
```

**단락 구조**: 첫 문장이 단락 전체를 예고해야 함. 독자는 첫 문장을 읽고 건너뛸지 결정한다.

---

## Word Choice (Lipton)

- **"significant"** → 수치로 대체 ("3.2% improvement on benchmark X")
- **"novel"** → 왜 새로운지 설명
- **"state-of-the-art"** → 어떤 벤치마크에서, 언제 기준인지 명시
- **passive voice** → 행위자가 분명할 때는 active ("We show" vs "It is shown")

---

## Mathematical Writing

수식 직전에 직관부터:
```
❌ 수식 → 설명
✅ "직관: Q와 K의 내적이 클수록 해당 위치에 집중한다.
   수식: Attention(Q,K,V) = softmax(QK^T/√d_k)V"
```

모든 심볼: 첫 등장 시 즉시 정의.
수식은 문장의 일부처럼 구두점 포함.

---

## Figure Design

- **Figure 1**: 아이디어 전체를 시각화 (메서드 다이어그램 또는 motivation figure)
- Caption이 자립적이어야 함 (본문 없이 이해 가능)
- 색상: 컬러블라인드 친화 팔레트
- 폰트: figure 내 텍스트 ≥ 8pt

---

## Common Mistakes (Steinhardt)

1. **Contribution이 불명확**: bullet이 "we study X" 형태 → falsifiable claim으로 교체
2. **베이스라인 불공정**: 자기 방법만 튜닝 → 모든 방법 동일 조건
3. **한계 숨기기**: 리뷰어가 발견하면 신뢰도 급락 → 선제적으로 논의
4. **Related Work가 목록**: 각 선행연구와의 차이를 명시적으로 서술
5. **수치만 있고 이해 없음**: 왜 개선됐는지 분석 포함
