-- name: GetUserByGoogle :one
SELECT *
FROM users
WHERE email = $1
    AND id_token = $2
    AND login_type = $3
LIMIT 1;
-- name: CheckAccountExists :one
SELECT EXISTS(
        SELECT 1
        FROM users
        WHERE email = $1
    );
-- name: GetUserByEmail :one
SELECT *
FROM users
WHERE email = $1
LIMIT 1;
-- name: CreateUser :one
INSERT INTO users (
        platform,
        login_type,
        id_token,
        username,
        email,
        password_hash
    )
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING user_id,
    platform,
    login_type,
    id_token,
    username,
    email,
    image_url,
    created_at,
    updated_at,
    last_login;
-- name: UpdateLastLogin :exec
UPDATE users
SET last_login = CURRENT_TIMESTAMP
WHERE user_id = $1;
-- name: GetUser :one
SELECT user_id,
    platform,
    login_type,
    id_token,
    username,
    email,
    image_url,
    created_at,
    updated_at,
    last_login
FROM users
WHERE user_id = $1
LIMIT 1;
-- name: UpdateUser :one
UPDATE users
SET username = COALESCE($2, username),
    email = COALESCE($3, email),
    image_url = COALESCE($4, image_url),
    updated_at = CURRENT_TIMESTAMP,
    last_login = COALESCE($5, last_login)
WHERE user_id = $1
RETURNING user_id,
    platform,
    login_type,
    id_token,
    username,
    email,
    image_url,
    created_at,
    updated_at,
    last_login;
-- name: DeleteUser :exec
DELETE FROM users
WHERE user_id = $1;
-- name: ListUsers :many
SELECT user_id,
    platform,
    login_type,
    id_token,
    username,
    email,
    image_url,
    created_at,
    updated_at,
    last_login
FROM users
ORDER BY user_id
LIMIT $1 OFFSET $2;