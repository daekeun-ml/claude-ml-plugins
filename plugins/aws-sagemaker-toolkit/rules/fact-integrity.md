# Fact & Citation Integrity

사실·인용을 산출물(가이드·코드 주석·논문·슬라이드·고객 답변)에 쓸 때 도메인 불문 항상 적용.

- **추측을 confirmed로 쓰지 말 것.** 기억(training-data recall)만으로 단정하지 않는다. 확인 못 한 것은 "uncertain / open question"으로 명시.
- **1차 소스 우선.** AWS는 공식 문서(docs.aws.amazon.com) + 공식 GitHub raw. 논문은 arXiv/ACL Anthology/venue proceedings 원문. 마케팅 블로그·2차 요약은 보조.
- **최소 2소스 교차검증**, 특히 숫자·한계값·GA/preview·버전·API 시그니처. 문서와 실제 repo(코드/CRD/config)가 일치하는지.
- **빠르게 바뀌는 값**(리전·GA·요금·서비스 한계)은 "현재 기준(as of YYYY-MM)" + "배포/공유 전 재확인" 표기. 절대 단정 금지.
- **적대적 태도**: 통념을 refute 시도. 틀리면 corrected_statement + 근거 URL.
- **위임**: AWS 사실 → `aws-fact-verify`(스킬) / `aws-fact-checker`(서브에이전트). 논문 인용 → `arxiv-verify` / `citation-workflow`. 확인 불가한 인용은 PLACEHOLDER + TODO로 표시하고 절대 지어내지 않는다.
- **작성↔검증 분리**: 자기 산출물의 사실을 같은 컨텍스트에서 자기승인하지 말 것 — 검증 lane으로 넘긴다.

관련: [[aws-authoring]] · [[communication]]
