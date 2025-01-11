package main

import (
	"log"

	"go-chatbot-server/config"
	"go-chatbot-server/db"
	sqlc "go-chatbot-server/db/sqlc"
	"go-chatbot-server/router"
	"go-chatbot-server/server"

	"github.com/joho/godotenv"
	"go.uber.org/zap"
)

const createMode = false

// const createMode = true
const testMode = false

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println(".env 파일을 찾을 수 없습니다. 기본 환경 변수를 사용합니다.", err)
	}

	logger, err := config.InitLogger()
	if err != nil {
		log.Fatalf("can't initialize zap logger: %v", err)
	}
	defer logger.Sync()

	dbConn, err := db.Connect(logger)
	if err != nil {
		logger.Fatal("Failed to connect to database", zap.Error(err))
	}
	defer dbConn.Close()

	queries := sqlc.New(dbConn)

	if err != nil {
		logger.Fatal("Failed to create OpenAI client", zap.Error(err))
	}

	r := router.New(queries, logger, dbConn)

	srv := server.New(r.Engine(), logger, ":8080")
	logger.Info("Starting server on :8080")
	if err := srv.Run(); err != nil {
		logger.Fatal("cannot start server", zap.Error(err))
	}
}
