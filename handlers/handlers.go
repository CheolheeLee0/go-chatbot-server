package handlers

import (
	sqldb "database/sql"
	db "go-chatbot-server/db/sqlc"
	"net/http"

	"github.com/google/generative-ai-go/genai"
	"github.com/gorilla/websocket"
	"github.com/qdrant/go-client/qdrant"
	"github.com/tmc/langchaingo/llms"
	"go.uber.org/zap"

	goopenai "github.com/sashabaranov/go-openai"
)

type Handler struct {
	queries         *db.Queries
	logger          *zap.Logger
	db              *sqldb.DB
	upgrader        websocket.Upgrader
	geminiClient    *genai.Client
	jwtSecret       []byte
	llm             llms.LLM
	client          *qdrant.Client
	embeddingClient *goopenai.Client
}

func New(queries *db.Queries, logger *zap.Logger, db *sqldb.DB) *Handler {
	return &Handler{
		queries: queries,
		logger:  logger,
		db:      db,
		upgrader: websocket.Upgrader{
			ReadBufferSize:  1024,
			WriteBufferSize: 1024,
			CheckOrigin: func(r *http.Request) bool {
				return true
			},
		},
	}
}
