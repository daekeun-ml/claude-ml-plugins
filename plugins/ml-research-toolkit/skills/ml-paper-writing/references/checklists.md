# Venue-Specific Submission Checklists

---

## 공통 체크리스트

### 구조
- [ ] Abstract ≤ venue 제한 (NeurIPS 150단어, ICML 200단어 등)
- [ ] Introduction 1–1.5페이지, contribution bullet 2–4개
- [ ] Method: 수식 전 직관 설명
- [ ] Experiments: setup → main results → ablation → analysis 순서
- [ ] Conclusion: 기여 요약 + 한계 + 미래 방향
- [ ] Related Work: 각 선행연구와의 차이 명시

### LaTeX / 형식
- [ ] 모든 수식에 번호
- [ ] Figure caption 자립적
- [ ] Table caption 위 (figure caption은 아래)
- [ ] 참고문헌 스타일 venue 규정 준수
- [ ] 페이지 제한 준수 (appendix 별도 카운트 여부 확인)
- [ ] 익명 제출 여부 확인 (double-blind 여부)

### 재현성
- [ ] 하이퍼파라미터 전체 명시
- [ ] 랜덤 시드 명시
- [ ] 컴퓨팅 환경 (GPU 종류, 학습 시간)
- [ ] 코드/데이터 가용성 명시

---

## NeurIPS

- [ ] Broader Impact 섹션 (필수)
- [ ] NeurIPS Checklist 첨부 (필수, 논문 마지막)
- [ ] 9페이지 본문 + 무제한 참고문헌 + 무제한 appendix
- [ ] Paper checklist: reproducibility, ethics, limitations

## ICML

- [ ] 8페이지 본문 (references 제외)
- [ ] Reproducibility statement (선택이지만 권장)
- [ ] Author response period 있음 (1–2페이지 리버탈)

## ICLR

- [ ] 8페이지 본문
- [ ] OpenReview 공개 리뷰 → 리버탈 1페이지
- [ ] Reproducibility 강조 (코드 링크 권장)

## ACL / EMNLP / NAACL

- [ ] Limitations 섹션 (ACL 2021+ 필수, 카운트 제외)
- [ ] Ethics Statement (해당 시 필수)
- [ ] Human evaluation → crowdworker 정보, IRB
- [ ] 8페이지 본문 (ACL) / 9페이지 (EMNLP)
- [ ] ACL Anthology BibTeX 스타일

## CVPR / ICCV / ECCV

- [ ] 8페이지 본문 (references 제외)
- [ ] Supplementary material 별도 PDF (최대 100MB)
- [ ] Qualitative results figure 필수
- [ ] Comparison figure (테이블만으론 부족)
- [ ] Double-blind (저자/기관 익명)

---

## 제출 전 30분 최종 점검

```
Narrative:
[ ] 제목만 보고 기여 추측 가능
[ ] Abstract 5문장 완결성
[ ] Introduction 마지막 contribution bullet 명시
[ ] Main table에 Δ 명확

Clarity:
[ ] Figure 1이 핵심 아이디어 시각화
[ ] 수식 전 직관 설명 있음
[ ] 모든 notation 첫 등장 시 정의

Reviewer 관점:
[ ] "왜 이 베이스라인?" 답 있음
[ ] "왜 이 데이터셋?" 답 있음
[ ] 한계 솔직히 논의
[ ] 하이퍼파라미터/시드/환경 명시
```
