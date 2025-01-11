package main

import (
	"context"
	"log"
	"os"

	"go-chatbot-server/config"
	"go-chatbot-server/db"
	sqlc "go-chatbot-server/db/sqlc"
	"go-chatbot-server/router"
	"go-chatbot-server/server"

	"github.com/google/generative-ai-go/genai"
	"github.com/joho/godotenv"
	"github.com/qdrant/go-client/qdrant"
	goopenai "github.com/sashabaranov/go-openai"
	"github.com/tmc/langchaingo/llms/openai"
	"go.uber.org/zap"
	"google.golang.org/api/option"
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

	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		logger.Fatal("GEMINI_API_KEY not set in .env file")
	}
	ctx := context.Background()
	geminiClient, err := genai.NewClient(ctx, option.WithAPIKey(apiKey))
	if err != nil {
		logger.Fatal("Failed to create Gemini client", zap.Error(err))
	}
	defer geminiClient.Close()

	llm, err := openai.New(
		openai.WithModel("gpt-4o-mini"),
	)
	if err != nil {
		logger.Fatal("Failed to create OpenAI client", zap.Error(err))
	}

	embeddingClient := goopenai.NewClient(os.Getenv("OPENAI_API_KEY"))

	logger.Info("Creating qdrant client...")
	client, err := qdrant.NewClient(&qdrant.Config{
		Host: "localhost",
		Port: 6334,
	})
	if err != nil {
		logger.Fatal("Failed to create Qdrant client", zap.Error(err))
	}

	r := router.New(queries, logger, dbConn, geminiClient, llm, client, embeddingClient)

	srv := server.New(r.Engine(), logger, ":8080")
	logger.Info("Starting server on :8080")
	if err := srv.Run(); err != nil {
		logger.Fatal("cannot start server", zap.Error(err))
	}
}
