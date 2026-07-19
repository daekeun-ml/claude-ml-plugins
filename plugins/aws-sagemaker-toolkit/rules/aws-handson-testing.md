# AWS Hands-on Code Testing

AWS ML 실습 코드/노트북을 만들 때 **환경에 맞는 테스트 사다리**를 함께 제공한다. 항상 적용.
(코드 스타일: [[code-style]] · 작성 규칙·cleanup: [[aws-authoring]] · SDK/API 사실은 [[fact-integrity]]로 검증.)

## 원칙
- **테스트는 환경 능력에 맞춘다.** 코드에 환경 감지(가용 디바이스·자격증명·리전)를 넣고, 능력별로 다른 경로를 태운다.
- **비용/과금을 항상 가드.** GPU 인스턴스·엔드포인트·클러스터는 안 지우면 계속 과금 → cleanup 필수, 무거운 셀엔 경고.
- **작게 시작.** 전체 학습 전에 1-step/1-batch로 파이프라인이 도는지부터.

## 테스트 사다리 (환경별)
1. **GPU 있는 개발환경** → **샘플 데이터로 실제 실행**. 소형 모델/부분 데이터로 학습·추론이 end-to-end로 도는지. 예: `torch.cuda.is_available()` 확인 → 작은 batch로 몇 step.
2. **CPU만** → **smoke test**. 실제 학습 대신 파이프라인 무결성만: import·데이터로딩·1-step forward·shape/dtype 체크·`--max-steps 1`·tiny 모델. GPU 강제 코드는 CPU fallback 또는 skip.
3. **SageMaker AI 학습/추론** → **직접 인스턴스 띄워 테스트**. `local mode`(로컬 컨테이너)로 먼저 검증 → 그다음 작은 `instance_type`으로 실제 Training Job / Endpoint. `estimator.fit()`·`deploy()` 후 반드시 teardown(`predictor.delete_endpoint()`).
4. **Docker 이미지** → **로드해서 테스트**. DLC 또는 커스텀 이미지를 `docker pull`/`docker run`으로 로컬 로드 → 컨테이너 안에서 스크립트 스모크 실행 → (필요시) ECR push 전 검증.
5. **엔드포인트 호출** → 배포 후 `invoke_endpoint`(boto3) 또는 `Predictor.predict()`로 실제 응답·지연·payload 한계 확인. (Serverless엔 GPU 없음 — LLM은 Real-time/GPU.)
6. **Agentic AI 연동** → 엔드포인트/모델을 **Strands SDK · LangGraph · Bedrock AgentCore** 와 연동해 에이전트 루프로 호출 테스트. 툴 호출·멀티스텝·상태를 검증.

## 환경 감지 스니펫 관용구
- 디바이스: `device = "cuda" if torch.cuda.is_available() else "cpu"` → 경로 분기.
- AWS 자격증명/리전: `boto3.Session().region_name` / STS `get_caller_identity`로 확인, 없으면 smoke test로 강등.
- SageMaker local mode: `instance_type="local"`(GPU면 `local_gpu`)로 과금 없이 먼저.

## Agentic 연동 주의 (⚠️ 사실 검증 필요)
- **Strands SDK · LangGraph · Bedrock AgentCore** 의 정확한 API/클래스/버전은 빠르게 바뀜 → 코드화 전 **공식 문서·repo로 검증**([[fact-integrity]], `aws-fact-checker`). 미검증 시그니처는 `# TODO verify` 주석.
- 연동 테스트도 과금 발생(모델 호출·엔드포인트) → 최소 호출 + cleanup.
- 시크릿(API key·role)은 env/플레이스홀더, 코드/노트북 출력에 노출 금지.

## CloudWatch 관측 다이렉트 링크 (특히 노트북)
SageMaker Training Job / Endpoint를 호출·배포하는 코드는 **CloudWatch로 상황(로그·메트릭)을 바로 볼 수 있는 다이렉트 링크를 자동으로 출력**한다. 특히 **Jupyter 노트북에서는 클릭 가능한 링크**(`IPython.display.HTML`)로.

- **언제**: `estimator.fit()` 직후(학습 로그), `deploy()`/엔드포인트 생성 직후(추론 로그+메트릭), `invoke_endpoint` 테스트 시.
- **무엇을 링크**: ① SageMaker 콘솔의 해당 Job/Endpoint 페이지 ② CloudWatch Logs 로그그룹 ③ (엔드포인트) CloudWatch Metrics(Invocations·ModelLatency·OverheadLatency·4xx/5xx).
- **로그그룹 규약**: 학습 = `/aws/sagemaker/TrainingJobs`(스트림 `<job-name>/…`), 엔드포인트 = `/aws/sagemaker/Endpoints/<endpoint-name>`.
- ⚠️ **콘솔 URL 형식은 현재 기준**이며 바뀔 수 있음(특히 Logs 경로는 `/` → `$252F` 이중 인코딩). 배포 전 실제 링크 클릭 확인. 리전·계정은 세션에서 동적으로(하드코딩 금지).

**노트북 헬퍼 관용구** (region 동적, 클릭 링크):
```python
from IPython.display import HTML, display
from urllib.parse import quote

def cw_links(region, *, training_job=None, endpoint=None):
    def enc(lg): return quote(quote(lg, safe=""), safe="")  # 로그그룹 이중 인코딩
    base = f"https://{region}.console.aws.amazon.com"
    rows = []
    if training_job:
        lg = "/aws/sagemaker/TrainingJobs"
        rows += [
            (f"SageMaker Job: {training_job}", f"{base}/sagemaker/home?region={region}#/jobs/{training_job}"),
            ("CloudWatch 학습 로그", f"{base}/cloudwatch/home?region={region}#logsV2:log-groups/log-group/{enc(lg)}"),
        ]
    if endpoint:
        lg = f"/aws/sagemaker/Endpoints/{endpoint}"
        rows += [
            (f"SageMaker Endpoint: {endpoint}", f"{base}/sagemaker/home?region={region}#/endpoints/{endpoint}"),
            ("CloudWatch 추론 로그", f"{base}/cloudwatch/home?region={region}#logsV2:log-groups/log-group/{enc(lg)}"),
            ("CloudWatch 메트릭(Invocations·ModelLatency)", f"{base}/cloudwatch/home?region={region}#metricsV2:graph=~();namespace=~'AWS*2fSageMaker"),
        ]
    display(HTML("<br>".join(f'🔗 <a href="{u}" target="_blank">{t}</a>' for t, u in rows)))

# 예: region = boto3.Session().region_name; cw_links(region, training_job=estimator.latest_training_job.name)
```
스크립트(.py)에서는 클릭 링크 대신 **URL을 로그로 print**(같은 형식). tail이 필요하면 `aws logs tail <log-group> --follow` 명령도 함께 안내.

## 산출물 형태
- 각 실습 코드에 **"테스트 방법" 섹션**(위 사다리 중 해당 환경 경로) + 예상 소요·과금 경고 + cleanup.
- SageMaker 학습/추론 코드에는 **CloudWatch 다이렉트 링크 출력**(노트북=클릭 링크, 스크립트=print).
- 가능하면 `if __name__ == "__main__"` 또는 `--smoke` 플래그로 스모크 경로를 코드에 내장.
