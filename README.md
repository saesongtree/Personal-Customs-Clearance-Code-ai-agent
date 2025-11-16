관세 행정 AI 에이전트 (RAG)이 프로젝트는 일반 국민(개인)을 대상으로 한 관세 행정 질문에 답변하는 RAG(Retrieval-Augmented Generation) AI 에이전트입니다.관세청 웹사이트의 공개 정보(HTML, PDF)를 기반으로 Elasticsearch에 벡터 데이터베이스를 구축하고, 로컬 LLM(Llama 3B)을 사용하여 사용자의 질문에 근거 기반으로 답변합니다.🚀 주요 기술 스택LLM (언어 모델): Llama 3B (llama3:8b) / OllamaVector DB (벡터 DB): Elasticsearch (v9.1.1)Embedding Model (임베딩): jhgan/ko-sroberta-multitask (Hugging Face)Orchestration (환경): Docker / docker-composeData Pipeline (데이터): Python (datacollect.py, preprocess_data.py, index_data.py)RAG Agent (에이전트): Python (customs_agent.py)📁 프로젝트 구조/AI_AGENT
├── docker-compose.yml      # 1. ES + 데이터 파이프라인 실행
├── elasticsearch/
│   └── Dockerfile          # Elasticsearch + 'nori' (한국어 분석기) 설치
├── app/
│   ├── Dockerfile          # 2. 데이터 파이프라인 Docker 이미지
│   ├── run.sh              # 3. 아래 3개 스크립트를 순차 실행 (Docker 내부)
│   ├── datacollect.py      #    (1) 관세청 HTML/PDF 데이터 수집
│   ├── preprocess_data.py  #    (2) 텍스트 전처리 및 청킹
│   ├── index_data.py       #    (3) 임베딩 및 Elasticsearch 색인
│   └── requirements.txt    #    파이프라인에 필요한 Python 라이브러리
├── pdf_files/              # 원본 데이터로 사용되는 PDF 파일들
├── customs_agent.py        # 4. RAG AI 에이전트 (로컬 실행)
└── .gitattributes          # (run.sh의 줄바꿈 오류(CRLF) 방지용)
⚙️ 1단계: 필수 환경 준비이 프로젝트를 실행하기 전에, 로컬 PC에 Docker와 Ollama가 반드시 설치되어 있어야 합니다.Docker Desktop 설치: Docker를 설치하고 실행합니다.Ollama 설치: Ollama를 설치하고 실행합니다.Llama 3B 모델 다운로드:Ollama가 실행 중인 상태에서, 터미널에 아래 명령어를 입력하여 AI 모델을 다운로드합니다.ollama pull llama3:8b
💾 2단계: 데이터베이스 구축 (Docker 실행)이 단계는 관세청 데이터를 수집하고 벡터화하여 Elasticsearch에 저장하는 일회성 작업입니다.이 GitHub 저장소를 로컬 PC에 복제(Clone)합니다.터미널을 열어 프로젝트의 최상위 폴더(AI_AGENT/)로 이동합니다.아래 명령어를 실행하여 Docker Compose를 빌드하고 실행합니다.이 명령어는 elasticsearch 컨테이너(nori 분석기 포함)와 app 컨테이너를 실행시킵니다.app 컨테이너는 run.sh 스크립트를 통해 데이터 수집부터 색인까지 모든 작업을 자동으로 수행합니다.docker-compose up -d --build
데이터 색인이 완료될 때까지 기다립니다.(매우 중요!)다른 터미널을 열어 아래 명령어로 로그를 확인합니다.docker-compose logs -f app
로그가 멈추고 >> 모든 작업 완료! ... 와 --- 모든 Docker 작업 완료 --- 메시지가 보이면 데이터 준비가 끝난 것입니다.🤖 3단계: AI 에이전트 실행 (로컬 Python)데이터 준비가 완료되었으니, 이제 AI 에이전트를 실행하여 질문할 수 있습니다.프로젝트 폴더에서 Python 가상환경(.venv)을 생성하고 활성화합니다.# 가상환경 생성 (최초 1회)
python -m venv .venv

# 가상환경 활성화 (PowerShell 기준)
.venv\Scripts\activate
customs_agent.py 실행에 필요한 라이브러리를 설치합니다.pip install -r app/requirements.txt
Ollama 프로그램이 실행 중인지 다시 한번 확인합니다. (Docker와 별개)customs_agent.py 스크립트를 실행합니다!python customs_agent.py
터미널에 환영 메시지가 뜨면, 관세 행정에 대해 질문하시면 됩니다.[질문 입력] > 반출입금지 물품에 대해서 설명해줘
![alt text](image-1.png)
🏁 종료하기AI 에이전트 종료:customs_agent.py가 실행 중인 터미널에서 q 또는 exit를 입력합니다.Docker 컨테이너 종료: (Elasticsearch DB 종료)docker-compose down
