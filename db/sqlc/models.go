// Code generated by sqlc. DO NOT EDIT.
// versions:
//   sqlc v1.27.0

package db

import (
	"database/sql"

	"github.com/sqlc-dev/pqtype"
)

type AiCharacter struct {
	CharacterID int32          `json:"character_id"`
	Name        string         `json:"name"`
	Role        string         `json:"role"`
	Description sql.NullString `json:"description"`
	HireCost    string         `json:"hire_cost"`
	IsPremium   sql.NullBool   `json:"is_premium"`
	ImageUrl    sql.NullString `json:"image_url"`
	Prompt      sql.NullString `json:"prompt"`
	CreatedAt   sql.NullTime   `json:"created_at"`
	UpdatedAt   sql.NullTime   `json:"updated_at"`
}

type ChatParticipant struct {
	RoomID      int32         `json:"room_id"`
	UserID      sql.NullInt32 `json:"user_id"`
	CharacterID sql.NullInt32 `json:"character_id"`
	JoinedAt    sql.NullTime  `json:"joined_at"`
	UpdatedAt   sql.NullTime  `json:"updated_at"`
}

type ChatRoom struct {
	RoomID    int32          `json:"room_id"`
	Name      sql.NullString `json:"name"`
	CreatedBy sql.NullInt32  `json:"created_by"`
	CreatedAt sql.NullTime   `json:"created_at"`
	UpdatedAt sql.NullTime   `json:"updated_at"`
	IsGroup   sql.NullBool   `json:"is_group"`
}

type Message struct {
	MessageID         int32                 `json:"message_id"`
	RoomID            sql.NullInt32         `json:"room_id"`
	SenderUserID      sql.NullInt32         `json:"sender_user_id"`
	SenderCharacterID sql.NullInt32         `json:"sender_character_id"`
	Content           string                `json:"content"`
	Feedback          pqtype.NullRawMessage `json:"feedback"`
	SentAt            sql.NullTime          `json:"sent_at"`
	UpdatedAt         sql.NullTime          `json:"updated_at"`
}

type User struct {
	UserID       int32          `json:"user_id"`
	Platform     string         `json:"platform"`
	LoginType    string         `json:"login_type"`
	IDToken      sql.NullString `json:"id_token"`
	Username     string         `json:"username"`
	Email        string         `json:"email"`
	PasswordHash sql.NullString `json:"password_hash"`
	ImageUrl     sql.NullString `json:"image_url"`
	CreatedAt    sql.NullTime   `json:"created_at"`
	UpdatedAt    sql.NullTime   `json:"updated_at"`
	LastLogin    sql.NullTime   `json:"last_login"`
}

type UserCharacter struct {
	UserID      int32        `json:"user_id"`
	CharacterID int32        `json:"character_id"`
	HiredAt     sql.NullTime `json:"hired_at"`
	UpdatedAt   sql.NullTime `json:"updated_at"`
}
