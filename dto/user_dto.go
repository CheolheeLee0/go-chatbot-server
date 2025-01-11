package dto

type CreateGoogleUserRequest struct {
	Platform    string `json:"platform" binding:"required"`
	LoginType   string `json:"login_type" binding:"required"`
	Username    string `json:"username" binding:"required"`
	Email       string `json:"email" binding:"required,email"`
	IDToken     string `json:"id_token" binding:"required"`
	CallbackURL string `json:"callback_url" binding:"required"` // Add callback_url field here
}

type CompletionResponse struct {
	Completion string   `json:"completion"`
	Sources    []string `json:"sources,omitempty"`
}

type CallbackRequest struct {
	CallbackURL string             `json:"callback_url"`
	Response    CompletionResponse `json:"response"`
}
