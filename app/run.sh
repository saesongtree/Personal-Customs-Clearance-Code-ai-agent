# app/run.sh

#!/bin/sh

# 스크립트 실행 중 오류가 발생하면 즉시 중단
set -e

echo "--- 데이터 수집 시작 ---"
python datacollect.py

echo "--- 데이터 전처리 및 분할 시작 ---"
python preprocess_data.py

echo "--- 데이터 색인 시작 ---"
python index_data.py

echo "--- 모든 작업 완료 ---"