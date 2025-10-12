# 1. 베이스 이미지 선택 (파이썬 3.11 슬림 버전)
FROM python:3.11-slim

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. 라이브러리 설치 (코드보다 먼저 설치하여 캐싱 효율을 높임)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. 나머지 모든 소스 코드 복사
COPY . .

# run.sh 파일에 실행 권한 부여
RUN chmod +x run.sh

# 5. 컨테이너가 시작될 때 실행할 명령어
CMD ["./run.sh"]