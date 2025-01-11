package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type CompletionRequest struct {
	Prompt string `json:"prompt" binding:"required"`
}

func (h *Handler) GetUser(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"user": "user",
	})
}
