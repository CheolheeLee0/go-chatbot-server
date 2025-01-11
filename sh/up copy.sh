#!/bin/bash

# 로그 파일 경로 설정
LOG_FILE="./deployment.log"

# 로그 함수 정의: 콘솔과 파일에 동시에 로그 출력
log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

START_TIME=$(date +%s.%N)
log "스크립트 시작"

SSH_HOST="fye"
CONTAINER_NAME="go-chatbot-server"
IMAGE_NAME="wks0968/go-chatbot-server:latest"
PORT="8081"
log "변수 설정 완료"

# Docker 데몬 실행 확인 및 대기 함수
wait_for_docker() {
    local max_attempts=30
    local attempt=1

    while ! docker info > /dev/null 2>&1; do
        if [ $attempt -ge $max_attempts ]; then
            log "Docker 데몬이 $max_attempts 번의 시도 후에도 시작되지 않았습니다. 스크립트를 종료합니다."
            exit 1
        fi

        log "Docker 데몬이 실행 중이지 않습니다. 시작을 시도합니다... (시도 $attempt/$max_attempts)"
        open -a Docker
        sleep 5
        ((attempt++))
    done

    log "Docker 데몬이 실행 중입니다."
}

# Docker 데몬 실행 확인 및 대기
wait_for_docker

log "로컬 Docker 컨테이너 관리 시작"
docker rm -f $CONTAINER_NAME 2>/dev/null
log "로컬 Docker 컨테이너 관리 완료"

log "Docker 이미지 빌드 및 푸시 시작"
# docker-compose build
docker-compose build 
docker-compose push 
docker-compose up -d
log "Docker 이미지 빌드 및 푸시 완료"

# log "로컬 ${PORT} 포트의 프로세스 종료 시도"
# lsof -i tcp:${PORT} | awk 'NR!=1 {print $2}' | xargs kill -9
# log "로컬 ${PORT} 포트의 프로세스 종료 완료"

log "로컬에서 사용하지 않는 Docker 이미지 제거 시작"
docker image prune -f
log "로컬에서 사용하지 않는 Docker 이미지 제거 완료"

log "AWS 서버에 SSH 접속 시작"
ssh $SSH_HOST << EOF
    log() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] \$1"
    }
    
    log "원격 서버 작업 시작"
    
    log "원격 서버에서 ${PORT} 포트의 프로세스 종료 시도"
    sudo fuser -k ${PORT}/tcp 2>/dev/null
    log "원격 서버에서 ${PORT} 포트의 프로세스 종료 완료"

    log "원격 서버에서 Docker 컨테이너 관리 시작"
    sudo docker rm -f $CONTAINER_NAME 2>/dev/null
    sudo docker pull $IMAGE_NAME
    sudo docker run -d --name $CONTAINER_NAME -p ${PORT}:${PORT} --rm $IMAGE_NAME
    log "원격 서버에서 Docker 컨테이너 관리 완료"

    log "원격 서버에서 사용하지 않는 Docker 이미지 제거 시작"
    # sudo docker image prune -f
    log "원격 서버에서 사용하지 않는 Docker 이미지 제거 완료"
    
    log "원격 서버 작업 완료"
EOF
log "AWS 서버 SSH 접속 및 작업 완료"

END_TIME=$(date +%s.%N)
EXECUTION_TIME=$(echo "$END_TIME - $START_TIME" | bc)
log "스크립트 실행 완료. 총 실행 시간: $(printf "%.3f" $EXECUTION_TIME) 초"