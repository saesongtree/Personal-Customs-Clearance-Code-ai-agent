#관세 행정 AI 에이전트 (RAG) - 개발 요약 및 실행 가이드

이 프로젝트는 일반 국민(개인)을 대상으로 한 관세 행정 질문에 답변하는 RAG(Retrieval-Augmented Generation) AI 에이전트입니다. 관세청 웹사이트의 공개 정보(HTML, PDF)를 기반으로 벡터 데이터베이스를 구축하고, 로컬 LLM(Llama 3B)을 사용하여 근거 기반 답변을 생성합니다.

이 문서는 이 프로젝트를 구축하며 수행한 핵심 작업과 문제 해결 과정을 요약하고, 다른 환경에서 이를 재현하기 위한 실행 가이드를 제공합니다.

##🚀 1. 프로젝트 주요 특징 (우리가 수행한 작업들)

이 프로젝트는 단순한 스크립트 실행을 넘어, 실제 운영 환경에서 발생하는 다양한 문제들을 해결한 결과물입니다.

Docker 기반 데이터 파이프라인: docker-compose를 사용하여 데이터 수집(datacollect.py), 전처리(preprocess_data.py), 색인(index_data.py) 과정을 app 컨테이너에서 원클릭으로 자동 실행합니다.

커스텀 Elasticsearch 환경: elasticsearch/Dockerfile을 통해 한국어 형태소 분석기 nori가 사전 설치된 커스텀 Elasticsearch 이미지를 빌드하여 사용합니다.

Windows/Linux 호환성 보장:

Windows(CRLF)와 Linux(LF) 간의 줄 바꿈 차이로 인한 app/run.sh의 exec format error 오류를 해결하기 위해 .gitattributes 파일을 구성하여 run.sh 파일의 LF 형식을 강제합니다.

app/Dockerfile에 dos2unix를 설치하여 빌드 시점에 스크립트 형식을 자동으로 변환합니다.

Ollama 404 오류 해결 (프록시 우회):

로컬 customs_agent.py가 Ollama(localhost:11434)로 요청 시 404 Not Found가 발생하는 (시스템 프록시로 인한) 문제를 해결했습니다.

requests 라이브러리가 시스템 프록시를 강제로 무시하도록 proxies={'http': None, 'https_': None} 옵션을 requests.post()에 명시적으로 전달하여 문제를 해결했습니다.

Ollama 모델 경로 문제 해결:

model 'llama3:8b' not found 오류는 OLLAMA_MODELS 환경 변수가 제대로 적용되지 않아 발생했습니다.

Windows 시스템 환경 변수에 OLLAMA_MODELS를 등록하고 PC를 재부팅하여 Ollama가 E 드라이브의 모델을 정상적으로 인식하도록 조치했습니다.

LLM 출력 제어:

Llama 3B 모델이 영어로 답변하는 문제를 해결하기 위해, SYSTEM_PROMPT에 "반드시, 무조건, 예외 없이 한국어로만 작성"하라는 강력한 지시문을 추가하여 한국어 답변을 강제했습니다.

C: 드라이브 용량 확보 (필수 가이드):

Docker의 거대한 .vhdx 가상 디스크를 Docker 설정 > Resources > Advanced를 통해 E 드라이브로 이전했습니다.

빌드 시 C 드라이브 용량이 차오르는 문제는 Docker 설정 > Docker Engine의 daemon.json에 data-root를 E 드라이브로 지정하여 빌드 캐시까지 이전시켰습니다.

Ollama 모델 또한 OLLAMA_MODELS 환경 변수를 통해 E 드라이브로 이전하여 C 드라이브 공간을 확보했습니다.

##⚙️ 2. 기술 스택

LLM: Llama 3B (llama3:8b) / Ollama

Vector DB: Elasticsearch (v9.1.1)

Embedding Model: jhgan/ko-sroberta-multitask

Orchestration: Docker / docker-compose

Core: Python, sentence-transformers, elasticsearch-py, requests

##🏃 3. 프로젝트 실행 가이드 (A-Z)

이 프로젝트를 새로운 환경에서 처음부터 실행하는 전체 과정입니다.

1단계: 필수 프로그램 설치 (Docker & Ollama)

Docker Desktop 설치: Docker를 설치하고 실행합니다.

Ollama 설치: Ollama를 설치하고 실행합니다.

2단계: (중요) C: 드라이브 용량 확보 설정

설치 직후, C 드라이브에 용량이 부족해지는 것을 막기 위해 모든 데이터를 E 드라이브(또는 다른 드라이브)로 이전합니다.

경고: 이 작업은 C 드라이브의 파일을 수동으로 Ctrl+X 해서 옮기면 절대 안 됩니다. 반드시 프로그램의 공식 설정을 통해 이전해야 합니다.

A. Docker 데이터 이전 (2곳)

데이터 본체 (.vhdx) 이전:

Docker Desktop > Settings > Resources > Advanced

Disk image location을 E:\DockerData\wsl-data와 같이 E 드라이브의 새 폴더로 지정합니다.

Apply & restart를 누르고 "Moving disk image..." 팝업을 통해 이동이 완료될 때까지 기다립니다.

(만약 C에 파일이 남아있다면 wsl --shutdown 후 수동 삭제)

빌드 캐시 (data-root) 이전:

Docker Desktop > Settings > Docker Engine

daemon.json 파일에 data-root 경로를 추가합니다. (경로는 \\ 사용)

{
  "data-root": "E:\\DockerData\\docker-root"
}


Apply & restart를 눌러 적용합니다.

B. Ollama 모델 이전

환경 변수 설정:

Windows 검색창에 시스템 환경 변수 편집을 검색하여 실행합니다.

환경 변수 버튼을 클릭합니다.

사용자 변수 섹션에서 새로 만들기를 클릭합니다.

변수 이름: OLLAMA_MODELS

변수 값: E:\ollama-models (E 드라이브에 새로 만든 폴더)

파일 이동 및 재부팅:

Ollama를 완전히 종료합니다. (작업 관리자에서 ollama.exe 강제 종료)

C:\Users\[사용자명]\.ollama\models 안의 파일들을 E:\ollama-models 폴더로 Ctrl+X (잘라내기)하여 옮깁니다.

컴퓨터를 재부팅하여 환경 변수를 시스템에 완전히 적용시킵니다.

3단계: AI 모델 다운로드

재부팅 후, Ollama가 E 드라이브를 인식하는지 확인합니다. 터미널을 열고 llama3:8b 모델을 다운로드합니다.

# E 드라이브의 모델을 인식하는지 확인
ollama list

# 모델 다운로드 (E 드라이브에 저장됨)
ollama pull llama3:8b


4단계: 데이터베이스 구축 (Docker 실행)

프로젝트의 핵심 데이터 파이프라인을 실행합니다.

# 1. 이 프로젝트를 Git에서 클론(Clone)합니다.
git clone [저장소 URL]
cd [프로젝트 폴더]

# 2. Docker Compose로 Elasticsearch와 데이터 색인 스크립트를 실행합니다.
# (app/run.sh가 자동으로 실행되어 datacollect, preprocess, index 스크립트를 차례로 실행합니다)
docker-compose up -d --build


(중요!)
app 컨테이너가 모든 데이터(77개 문서)를 임베딩하고 색인할 때까지 몇 분 정도 기다려야 합니다. 아래 명령어로 로그를 확인하세요.

docker-compose logs -f app


>> 모든 작업 완료! ... 와 --- 모든 Docker 작업 완료 --- 메시지가 보이면 다음 단계로 넘어갑니다.

5단계: RAG AI 에이전트 실행 (로컬)

이제 준비된 데이터베이스와 LLM을 연결하는 customs_agent.py를 로컬에서 실행합니다.

# 1. Python 가상환경 생성 및 활성화
python -m venv .venv
.venv\Scripts\activate

# 2. 필요한 라이브러리 설치
# (app/requirements.txt에는 app 컨테이너용 라이브러리만 있으므로,
#  customs_agent.py에 필요한 라이브러리도 설치해야 합니다.)
pip install -r app/requirements.txt
pip install sentence-transformers elasticsearch-py requests

# 3. AI 에이전트 실행
python customs_agent.py


6단계: 질문하기

터미널에 [질문 입력] > 프롬프트가 뜨면, 관세 행정에 대해 질문합니다.

[질문 입력] > 해외 이사물품 통관 절차 알려줘
[1/3] '해외 이사물품 통관 절차 알려줘' (와)과 관련된 문서를 검색합니다...
✅ 총 3개의 관련 문서를 찾았습니다.
[2/3] 검색된 문서를 바탕으로 답변을 생성합니다...
✅ 답변 생성 완료.
[3/3] 최종 답변을 반환합니다.

[커스텀-봇 답변] 🤖:
(Llama 3B가 생성한 한국어 답변)


7단계: 종료하기

# 1. AI 에이전트 종료 (q 또는 exit 입력)

# 2. Docker 컨테이너(Elasticsearch) 종료
docker-compose down
