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
    PRIMARY KEY ("user_id"),
    CONSTRAINT "users_email_key" UNIQUE ("email")
);
-- Create "ai_characters" table
CREATE TABLE "public"."ai_characters" (
    "character_id" serial NOT NULL,
    "name" character varying(100) NOT NULL,
    "role" character varying(50) NOT NULL,
    "description" text NULL,
    "hire_cost" numeric(10, 2) NOT NULL,
    "is_premium" boolean NULL DEFAULT false,
    "image_url" character varying(255) NULL,
    "prompt" text NULL,
    "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("character_id")
);
-- Create "chat_rooms" table
CREATE TABLE "public"."chat_rooms" (
    "room_id" serial NOT NULL,
    "name" character varying(1000) NULL,
    "created_by" integer NULL,
    "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
    "is_group" boolean NULL DEFAULT false,
    PRIMARY KEY ("room_id"),
    CONSTRAINT "chat_rooms_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create "chat_participants" table
CREATE TABLE "public"."chat_participants" (
    "room_id" integer NOT NULL,
    "user_id" integer NULL,
    "character_id" integer NULL,
    "joined_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "chat_participants_character_id_fkey" FOREIGN KEY ("character_id") REFERENCES "public"."ai_characters" ("character_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT "chat_participants_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "public"."chat_rooms" ("room_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT "chat_participants_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_chat_participants_room_id" to table: "chat_participants"
CREATE INDEX "idx_chat_participants_room_id" ON "public"."chat_participants" ("room_id");
-- Create "messages" table
CREATE TABLE "public"."messages" (
    "message_id" serial NOT NULL,
    "room_id" integer NULL,
    "sender_user_id" integer NULL,
    "sender_character_id" integer NULL,
    "content" text NOT NULL,
    "feedback" jsonb NULL,
    "sent_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("message_id"),
    CONSTRAINT "messages_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "public"."chat_rooms" ("room_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT "messages_sender_character_id_fkey" FOREIGN KEY ("sender_character_id") REFERENCES "public"."ai_characters" ("character_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT "messages_sender_user_id_fkey" FOREIGN KEY ("sender_user_id") REFERENCES "public"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_messages_room_id" to table: "messages"
CREATE INDEX "idx_messages_room_id" ON "public"."messages" ("room_id");
-- Create index "idx_messages_sent_at" to table: "messages"
CREATE INDEX "idx_messages_sent_at" ON "public"."messages" ("sent_at");
-- Create "user_characters" table
CREATE TABLE "public"."user_characters" (
    "user_id" integer NOT NULL,
    "character_id" integer NOT NULL,
    "hired_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("user_id", "character_id"),
    CONSTRAINT "user_characters_character_id_fkey" FOREIGN KEY ("character_id") REFERENCES "public"."ai_characters" ("character_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT "user_characters_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_user_characters_user_id" to table: "user_characters"
CREATE INDEX "idx_user_characters_user_id" ON "public"."user_characters" ("user_id");