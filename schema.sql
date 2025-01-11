-- Add new schema named "public"
CREATE SCHEMA IF NOT EXISTS "public";
-- Set comment to schema: "public"
COMMENT ON SCHEMA "public" IS 'standard public schema';
-- Create "users" table
CREATE TABLE "public"."users" (
    "user_id" serial NOT NULL,
    -- "platform" character varying(50) NULL,
    -- "login_type" character varying(50) NULL,
    "platform" character varying(50) NOT NULL,
    "login_type" character varying(50) NOT NULL,
    "id_token" character varying(255) NULL,
    "username" character varying(50) NOT NULL,
    "email" character varying(100) NOT NULL,
    "password_hash" character varying(255) NULL,
    "image_url" character varying(255) NULL,
    "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
    "last_login" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "users_email_key" UNIQUE ("email")
);