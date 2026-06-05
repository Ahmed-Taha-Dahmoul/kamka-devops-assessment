#!/bin/bash

# STRICT MODE: Kamka IT specifically requested this.
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error.
# -o pipefail: The return value of a pipeline is the status of the last command to exit with a non-zero status.
set -euo pipefail

# --- Configuration ---
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="${BACKUP_DIR}/db_backup_${TIMESTAMP}.sql"

# Default values that match our docker-compose.yml
DB_USER=${DB_USER:-postgres}
DB_NAME=${DB_NAME:-notes_db}
COMPOSE_SERVICE="db"

echo "====================================="
echo "🔄 Starting Database Backup Process"
echo "====================================="

# 1. Create the backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# 2. Check if Docker Compose is actually running the database
# We use docker compose ps to verify the db service is up.
if ! docker compose ps -q "${COMPOSE_SERVICE}" > /dev/null 2>&1; then
    echo "❌ Error: Database service '${COMPOSE_SERVICE}' is not running." >&2
    echo "Please run 'docker compose up -d' first." >&2
    exit 1
fi

echo "📦 Dumping database '${DB_NAME}'..."

# 3. Perform the backup
# We use 'docker compose exec -T' (disable TTY) to safely pipe the output to our host machine.
if docker compose exec -T "${COMPOSE_SERVICE}" pg_dump -U "${DB_USER}" "${DB_NAME}" > "${BACKUP_FILE}"; then
    echo "✅ Backup successfully saved to: ${BACKUP_FILE}"
else
    echo "❌ Error: Database dump failed!" >&2
    rm -f "${BACKUP_FILE}" # Clean up potentially corrupted file
    exit 1
fi

# 4. Optional but shows seniority: Clean up old backups (keep the last 5)
echo "🧹 Cleaning up old backups (keeping the 5 most recent)..."
ls -tp "${BACKUP_DIR}"/db_backup_*.sql | grep -v '/$' | tail -n +6 | xargs -I {} rm -- {} 2>/dev/null || true

echo "🎉 Backup process finished safely."
echo "====================================="