#!/bin/bash

DB_URL="postgres://postgres:P9xAEGBKj2mLnR5asdB7@fye-rds.cuhaqptbxij7.ap-northeast-2.rds.amazonaws.com:5432/postgres?sslmode=require"
MIGRATIONS_DIR="./db/migrations"
SCHEMA_FILE="schema.sql"

inspect_schema() {
    echo "Inspecting current database schema..."
    
    atlas schema inspect --url "$DB_URL" --format '{{ sql . }}' > "$SCHEMA_FILE"
    echo "Schema inspection complete. SQL output saved to $SCHEMA_FILE"
}

apply_schema() {
    echo "Applying schema changes to the database..."
    
    atlas schema apply \
        --url "$DB_URL" \
        --dev-url "docker://postgres" \
        --to "file://$SCHEMA_FILE"
    echo "Schema changes have been applied successfully."
}

migrate_apply() {
    echo "Performing a dry run of migration application..."
    
    atlas migrate apply \
        --url "$DB_URL" \
        --dir "file://$MIGRATIONS_DIR" \
        --dry-run
    echo "Dry run of migration application completed. No changes were made to the database."
}

migrate_hash() {
    echo "Generating a hash of the current migration state..."
    
    atlas migrate hash \
        --dir "file://$MIGRATIONS_DIR"
    echo "Migration hash generation completed. This hash can be used to verify the migration state."
}

migrate_up() {
    echo "Migrating up..."
    
    atlas migrate apply \
        --url "$DB_URL" \
        --dir "file://$MIGRATIONS_DIR" \
        --allow-dirty
    echo "Migration up completed."
}

migrate_create() {
    echo "Creating a new migration..."
    
    atlas migrate diff migration \
        --dir "file://$MIGRATIONS_DIR" \
        --to "file://$SCHEMA_FILE" \
        --dev-url "docker://postgres/15"
    echo "Migration creation completed. Please check the generated migration file in $MIGRATIONS_DIR."
}

generate_migrate_apply() {
    echo "Generating migration, hash, and applying schema to RDS..."
    
    atlas migrate diff migration \
        --dir "file://$MIGRATIONS_DIR" \
        --to "file://$SCHEMA_FILE" \
        --dev-url "docker://postgres/15"
    
    atlas migrate hash --dir "file://$MIGRATIONS_DIR"
    
    atlas schema apply \
        --url "$DB_URL" \
        --to "file://$SCHEMA_FILE" \
        --dev-url "docker://postgres"
    
    echo "Migration generated, hash created, and schema applied to RDS."
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    generate_migrate_apply
fi

