package services

import (
	"context"
	"errors"
	"fmt"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/steve-mir/bukka_backend/db/sqlc"
	"github.com/steve-mir/bukka_backend/utils"
	"github.com/steve-mir/bukka_backend/worker"
)

const (
	codeLength    = int64(1000000)
	length        = 6
	ResetMsg      = "if an account exists a password reset email will be sent to you"
	UnexpectedErr = "an unexpected error occurred"
)

func SendVerificationEmail(qtx *sqlc.Queries, ctx context.Context, td worker.TaskDistributor, userId uuid.UUID, email string) error {

	verificationCode, err := utils.GenerateSecureRandomNumber(codeLength)
	if err != nil {
		return fmt.Errorf("failed to generate secure random number %v", err)
	}
	code := fmt.Sprintf("%06d", verificationCode)
	content := fmt.Sprintf("Use this to verify you email. code %s", code)

	// Use a WaitGroup to wait for both goroutines to complete
	var wg sync.WaitGroup
	wg.Add(2) // We have two goroutines

	// Error channel with buffer for two errors
	errChan := make(chan error, 2)

	go func() {
		defer wg.Done() // Notify the WaitGroup that this goroutine is done
		// Send email here.
		if err := SendEmail(td, ctx, email, content); err != nil {
			errChan <- fmt.Errorf("failed to send verification email %v", err)
		}
	}()

	go func() {
		defer wg.Done() // Notify the WaitGroup that this goroutine is done
		// Add link to db
		if err := qtx.CreateEmailVerificationRequest(ctx, sqlc.CreateEmailVerificationRequestParams{
			UserID:    userId,
			Email:     email,
			Token:     code,
			ExpiresAt: time.Now().Add(time.Minute * 15),
		}); err != nil {
			errChan <- fmt.Errorf("failed to create email verification request %v", err)
		}
	}()

	// Wait for both goroutines to complete
	wg.Wait()
	close(errChan) // Close the channel so that the range loop can finish

	// Collect errors from the error channel
	for err := range errChan {
		if err != nil {
			return err // Return the first error encountered
		}
	}

	return nil

}
func VerifyEmail(ctx context.Context, store sqlc.Store, code string) error {
	ctx, cancel := context.WithTimeout(ctx, time.Second*10) // Adjust the timeout as needed
	defer cancel()

	if len(code) != length {
		return errors.New("invalid token")
	}

	linkData, err := store.GetEmailVerificationRequestByToken(context.Background(), code)
	if err != nil {
		return err
	}

	if condition := linkData.ExpiresAt.Before(time.Now()); condition {
		return fmt.Errorf("token expired")
	}

	if condition := linkData.IsVerified.Bool; condition {
		return fmt.Errorf("token already verified")
	}

	// Update token to used
	usr, err := store.UpdateEmailVerificationRequest(context.Background(), sqlc.UpdateEmailVerificationRequestParams{
		Token:      code,
		IsVerified: pgtype.Bool{Bool: true, Valid: true},
	})
	if err != nil {
		return err
	}

	// Verify user in "users" db
	_, err = store.UpdateUser(ctx, sqlc.UpdateUserParams{
		ID:              usr.UserID,
		IsEmailVerified: pgtype.Bool{Bool: true, Valid: true},
	})
	if err != nil {
		return fmt.Errorf("error updating profile %s", err)
	}

	// TODO: Generate access token with "verified" as true

	return nil

}
