package router

import (
	"net/http"
	"runtime"
	"time"

	sqldb "database/sql"
	db "go-chatbot-server/db/sqlc"
	"go-chatbot-server/handlers"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"

	"github.com/gin-contrib/cors"
)

type Router struct {
	engine  *gin.Engine
	handler *handlers.Handler
}

func New(queries *db.Queries, logger *zap.Logger, db *sqldb.DB) *Router {
	r := &Router{
		engine:  gin.Default(),
		handler: handlers.New(queries, logger, db),
	}
	config := cors.DefaultConfig()
	config.AllowAllOrigins = true

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
