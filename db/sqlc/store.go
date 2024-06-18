package sqlc

import (
	"database/sql"
)

type Store interface {
	Querier
}

type SQLStore struct {
	// connPool *pgxpool.Pool
	db *sql.DB
	*Queries
}

func NewStore(db *sql.DB) Store {
	return &SQLStore{
		db:      db,
		Queries: New(db),
	}
}

// func (store *SQLStore) ExecTx(ctx context.Context, fn func(*Queries) error) error {
// 	tx, err := store.connPool.Begin(ctx)
// 	if err != nil {
// 		return err
// 	}

// 	q := New(tx)
// 	err = fn(q)
// 	if err != nil {
// 		if rbErr := tx.Rollback(ctx); rbErr != nil {
// 			return fmt.Errorf("tx err: %v, rb err: %v", err, rbErr)
// 		}
// 		return err
// 	}
// 	return tx.Commit(ctx)
// }
