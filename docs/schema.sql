-- SQL dump generated using DBML (dbml-lang.org)
-- Database: PostgreSQL
-- Generated at: 2024-06-13T11:13:08.435Z

CREATE TABLE "authentications" (
  "id" uuid PRIMARY KEY NOT NULL,
  "email" varchar UNIQUE NOT NULL,
  "username" varchar,
  "phone" varchar,
  "password_hash" varchar NOT NULL,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz,
  "is_suspended" boolean DEFAULT false,
  "is_deleted" boolean DEFAULT false,
  "is_verified" boolean DEFAULT false,
  "is_email_verified" boolean DEFAULT false,
  "deleted_at" timestamptz,
  "verified_at" timestamptz,
  "suspended_at" timestamptz,
  "login_attempts" int DEFAULT 0,
  "password_last_changed" timestamptz,
  "lockout_duration" int DEFAULT 60,
  "lockout_until" timestamptz,
  "is_mfa_enabled" boolean DEFAULT false
);

CREATE TABLE "users" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid UNIQUE NOT NULL,
  "first_name" varchar,
  "last_name" varchar,
  "image_url" varchar
);

CREATE TABLE "roles" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "name" varchar
);

CREATE TABLE "user_roles" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "role_id" int NOT NULL
);

CREATE TABLE "email_verification_requests" (
  "id" BIGSERIAL PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "email" varchar NOT NULL,
  "token" varchar UNIQUE NOT NULL,
  "is_verified" boolean DEFAULT false,
  "created_at" timestamptz DEFAULT (now()),
  "expires_at" timestamptz DEFAULT (now() + interval 15 minutes)
);

CREATE TABLE "user_logins" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid,
  "login_at" timestamptz DEFAULT (now()),
  "ip_address" inet,
  "user_agent" varchar
);

CREATE TABLE "sessions" (
  "id" uuid PRIMARY KEY NOT NULL,
  "user_id" uuid,
  "refresh_token" varchar UNIQUE NOT NULL,
  "refresh_token_exp" timestamptz NOT NULL,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz,
  "invalidated_at" timestamptz,
  "last_active_at" timestamptz,
  "blocked_at" timestamptz,
  "user_agent" text NOT NULL,
  "ip_address" inet NOT NULL
);

CREATE TABLE "password_reset_requests" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "email" varchar NOT NULL,
  "token" varchar UNIQUE NOT NULL,
  "used" boolean DEFAULT false,
  "created_at" timestamptz DEFAULT (now()),
  "expires_at" timestamptz
);

CREATE TABLE "account_recovery_requests" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "email" varchar NOT NULL,
  "used" boolean DEFAULT false,
  "recovery_token" varchar UNIQUE NOT NULL,
  "requested_at" timestamptz DEFAULT (now()),
  "expires_at" timestamptz NOT NULL,
  "completed_at" timestamptz
);

CREATE TABLE "two_factor_secrets" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "secret_key" varchar NOT NULL,
  "is_active" boolean DEFAULT true
);

CREATE TABLE "two_factor_revocation" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "revoked_at" timestamptz,
  "revocation_reason" varchar,
  "revoked_by" uuid
);

CREATE TABLE "two_factor_backup_codes" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "code" varchar NOT NULL,
  "used" boolean DEFAULT false
);

CREATE TABLE "change_identifier_requests" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid,
  "identifier" varchar NOT NULL,
  "token" varchar UNIQUE NOT NULL,
  "type" varchar NOT NULL,
  "used" boolean DEFAULT false,
  "created_at" timestamptz DEFAULT (now()),
  "expires_at" timestamptz
);

CREATE TABLE "login_failures" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid,
  "timestamp" timestamptz,
  "user_agent" varchar,
  "ip_address" inet
);

CREATE TABLE "banned_users" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid,
  "banned_at" timestamptz,
  "reason" varchar
);

CREATE TABLE "security_questions" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid,
  "question" varchar,
  "answer" varchar,
  "expired_at" timestamptz
);

CREATE TABLE "social_providers" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "name" varchar UNIQUE,
  "api_key" varchar,
  "oauth_settings" json
);

CREATE TABLE "social_provider_users" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "provider_id" int,
  "provider_user_id" varchar,
  "user_id" uuid,
  "access_token" varchar,
  "refresh_token" varchar
);

CREATE TABLE "audit_logs" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid,
  "action" varchar,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz
);

CREATE TABLE "user_preferences" (
  "user_id" uuid,
  "preferences" json
);

CREATE TABLE "notifications" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid,
  "title" varchar,
  "action" varchar,
  "content" varchar,
  "details" json,
  "read_at" timestamptz,
  "created_at" timestamptz DEFAULT (now())
);

CREATE TABLE "api_keys" (
  "id" INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "user_id" uuid,
  "key" varchar UNIQUE,
  "permissions" json,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz,
  "last_used_at" timestamptz,
  "is_active" boolean,
  "is_deleted" boolean
);

CREATE TABLE "user_api_keys" (
  "user_id" uuid,
  "api_key_id" int
);

CREATE INDEX ON "authentications" ("email", "username", "created_at", "updated_at");

CREATE INDEX ON "user_roles" ("role_id");

CREATE INDEX ON "email_verification_requests" ("user_id", "token", "email", "created_at");

CREATE INDEX ON "user_logins" ("user_id", "login_at");

CREATE INDEX ON "sessions" ("user_id", "refresh_token_exp", "updated_at");

CREATE INDEX ON "password_reset_requests" ("user_id", "token");

CREATE INDEX ON "account_recovery_requests" ("user_id", "recovery_token");

CREATE INDEX ON "change_identifier_requests" ("user_id", "identifier", "token", "expires_at");

CREATE INDEX ON "login_failures" ("user_id", "timestamp");

CREATE INDEX ON "banned_users" ("user_id");

CREATE INDEX ON "social_provider_users" ("provider_id", "provider_user_id");

CREATE INDEX ON "audit_logs" ("user_id", "updated_at", "created_at");

CREATE INDEX ON "notifications" ("user_id", "created_at", "read_at");

CREATE INDEX ON "api_keys" ("user_id", "key", "updated_at", "created_at");

CREATE INDEX ON "user_api_keys" ("user_id", "api_key_id");

COMMENT ON COLUMN "two_factor_secrets"."secret_key" IS 'Encrypted';

COMMENT ON COLUMN "two_factor_backup_codes"."code" IS 'Encrypted';

ALTER TABLE "users" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "user_roles" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "user_roles" ADD FOREIGN KEY ("role_id") REFERENCES "roles" ("id");

ALTER TABLE "email_verification_requests" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "user_logins" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "sessions" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "password_reset_requests" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "account_recovery_requests" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "two_factor_secrets" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "two_factor_revocation" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "two_factor_revocation" ADD FOREIGN KEY ("revoked_by") REFERENCES "authentications" ("id");

ALTER TABLE "two_factor_backup_codes" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "change_identifier_requests" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "login_failures" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "banned_users" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "security_questions" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "social_provider_users" ADD FOREIGN KEY ("provider_id") REFERENCES "social_providers" ("id");

ALTER TABLE "social_provider_users" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "audit_logs" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "user_preferences" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "notifications" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "api_keys" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "user_api_keys" ADD FOREIGN KEY ("user_id") REFERENCES "authentications" ("id");

ALTER TABLE "user_api_keys" ADD FOREIGN KEY ("api_key_id") REFERENCES "api_keys" ("id");
