# scripts/backup/backup.sh  
#!/bin/bash
# Backup script for N8N data

set -e

BACKUP_DIR="./backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="n8n_backup_$TIMESTAMP"

echo "💾 Starting N8N backup..."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup N8N data
echo "📁 Backing up N8N data..."
tar -czf "$BACKUP_DIR/${BACKUP_NAME}_data.tar.gz" -C data .

# Backup database
echo "🗄️  Backing up database..."
docker exec postgres_n8n pg_dump -U n8n n8ndb > "$BACKUP_DIR/${BACKUP_NAME}_db.sql"

# Backup configuration
echo "⚙️  Backing up configuration..."
tar -czf "$BACKUP_DIR/${BACKUP_NAME}_config.tar.gz" .env

# Create backup manifest
cat > "$BACKUP_DIR/${BACKUP_NAME}_manifest.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "files": {
    "data": "${BACKUP_NAME}_data.tar.gz",
    "database": "${BACKUP_NAME}_db.sql", 
    "config": "${BACKUP_NAME}_config.tar.gz"
  },
  "version": "$(docker exec n8n_app n8n --version)"
}
EOF

echo "✅ Backup completed: $BACKUP_NAME"

# Clean old backups (keep last 7 days)
find "$BACKUP_DIR" -name "n8n_backup_*" -mtime +7 -delete