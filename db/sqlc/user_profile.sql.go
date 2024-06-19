// Code generated by sqlc. DO NOT EDIT.
// versions:
//   sqlc v1.22.0
// source: user_profile.sql

package sqlc

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
)

const createUserProfile = `-- name: CreateUserProfile :exec
INSERT INTO users (
    user_id, image_url, first_name, last_name
    )
VALUES ($1, $2, $3, $4)
`

type CreateUserProfileParams struct {
	UserID    uuid.UUID      `json:"user_id"`
	ImageUrl  sql.NullString `json:"image_url"`
	FirstName sql.NullString `json:"first_name"`
	LastName  sql.NullString `json:"last_name"`
}

func (q *Queries) CreateUserProfile(ctx context.Context, arg CreateUserProfileParams) error {
	_, err := q.db.ExecContext(ctx, createUserProfile,
		arg.UserID,
		arg.ImageUrl,
		arg.FirstName,
		arg.LastName,
	)
	return err
}

const deleteUserProfileByID = `-- name: DeleteUserProfileByID :exec
DELETE FROM users WHERE user_id = $1
`

func (q *Queries) DeleteUserProfileByID(ctx context.Context, userID uuid.UUID) error {
	_, err := q.db.ExecContext(ctx, deleteUserProfileByID, userID)
	return err
}

const getUserProfile = `-- name: GetUserProfile :one
SELECT
  u.id,
  u.username,
  u.email,
  u.phone,
  u.created_at,
  u.is_verified,
  us.first_name,
  us.last_name,
  us.image_url
FROM
  authentications u
JOIN
  users us ON u.id = us.user_id
WHERE
  (u.username = $1 OR u.id::text = $1)
`

type GetUserProfileRow struct {
	ID         uuid.UUID      `json:"id"`
	Username   sql.NullString `json:"username"`
	Email      string         `json:"email"`
	Phone      sql.NullString `json:"phone"`
	CreatedAt  sql.NullTime   `json:"created_at"`
	IsVerified sql.NullBool   `json:"is_verified"`
	FirstName  sql.NullString `json:"first_name"`
	LastName   sql.NullString `json:"last_name"`
	ImageUrl   sql.NullString `json:"image_url"`
}

func (q *Queries) GetUserProfile(ctx context.Context, username sql.NullString) (GetUserProfileRow, error) {
	row := q.db.QueryRowContext(ctx, getUserProfile, username)
	var i GetUserProfileRow
	err := row.Scan(
		&i.ID,
		&i.Username,
		&i.Email,
		&i.Phone,
		&i.CreatedAt,
		&i.IsVerified,
		&i.FirstName,
		&i.LastName,
		&i.ImageUrl,
	)
	return i, err
}

const getUserProfileByUID = `-- name: GetUserProfileByUID :one
SELECT id, user_id, first_name, last_name, image_url FROM users WHERE user_id = $1 LIMIT 1
`

func (q *Queries) GetUserProfileByUID(ctx context.Context, userID uuid.UUID) (User, error) {
	row := q.db.QueryRowContext(ctx, getUserProfileByUID, userID)
	var i User
	err := row.Scan(
		&i.ID,
		&i.UserID,
		&i.FirstName,
		&i.LastName,
		&i.ImageUrl,
	)
	return i, err
}

const updateImgUserProfile = `-- name: UpdateImgUserProfile :exec
UPDATE users SET image_url = $2 WHERE user_id = $1
`

type UpdateImgUserProfileParams struct {
	UserID   uuid.UUID      `json:"user_id"`
	ImageUrl sql.NullString `json:"image_url"`
}

func (q *Queries) UpdateImgUserProfile(ctx context.Context, arg UpdateImgUserProfileParams) error {
	_, err := q.db.ExecContext(ctx, updateImgUserProfile, arg.UserID, arg.ImageUrl)
	return err
}
