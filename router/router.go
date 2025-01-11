package router

import (
	"net/http"
	"runtime"
	"time"

	sqldb "database/sql"
	db "go-chatbot-server/db/sqlc"
	"go-chatbot-server/handlers"

	"github.com/gin-gonic/gin"
	"github.com/google/generative-ai-go/genai"
	"github.com/qdrant/go-client/qdrant"
	"github.com/tmc/langchaingo/llms"
	"go.uber.org/zap"

	goopenai "github.com/sashabaranov/go-openai"

	"github.com/gin-contrib/cors"
)

type Router struct {
	engine  *gin.Engine
	handler *handlers.Handler
}

func New(queries *db.Queries, logger *zap.Logger, db *sqldb.DB, geminiClient *genai.Client, llm llms.LLM, client *qdrant.Client, embeddingClient *goopenai.Client) *Router {
	r := &Router{
		engine:  gin.Default(),
		handler: handlers.New(queries, logger, db, geminiClient, llm, client, embeddingClient),
	}
	config := cors.DefaultConfig()
	config.AllowAllOrigins = true
	// // CORS 설정 추가
	// config := cors.DefaultConfig()
	// config.AllowOrigins = []string{"http://localhost:3000"} // Flutter 웹 앱의 URL
	// config.AllowMethods = []string{"GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"}
	// config.AllowHeaders = []string{"Origin", "Content-Length", "Content-Type", "Authorization"}
	// config.AllowCredentials = true

	r.engine.Use(cors.New(config))

	r.setupRoutes()
	return r
}

func (r *Router) setupRoutes() {
	r.setupUserRoutes()
	r.setupQARoutes()
	r.setupHealthCheckRoute()
}

func (r *Router) setupQARoutes() {
	r.engine.GET("/api/v1/user", r.handler.GetUser)
}

func (r *Router) setupUserRoutes() {

}

func (r *Router) setupHealthCheckRoute() {
	r.engine.GET("/api/v1/health", func(c *gin.Context) {
		var memStats runtime.MemStats
		runtime.ReadMemStats(&memStats)

		healthInfo := map[string]interface{}{
			"status": "healthy",
			"time":   time.Now(),
			"memory": map[string]uint64{
				"alloc":      memStats.Alloc,
				"totalAlloc": memStats.TotalAlloc,
				"sys":        memStats.Sys,
				"numGC":      uint64(memStats.NumGC),
			},
			"cpu": map[string]int{
				"numCPU": runtime.NumCPU(),
			},
		}

		c.JSON(http.StatusOK, healthInfo)
	})
}

func (r *Router) Engine() *gin.Engine {
	return r.engine
}
