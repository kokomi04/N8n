# scripts/deployment/deploy.sh
#!/bin/bash
# Production deployment script

set -e

echo "🚀 Deploying N8N to production..."

# Load environment variables
source .env

# Validate required environment variables
validate_env() {
    local required_vars=("N8N_ENCRYPTION_KEY" "N8N_USER_MANAGEMENT_JWT_SECRET" "DB_POSTGRESDB_PASSWORD")
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo "❌ Error: $var is not set"
            exit 1
        fi
    done
}

# Backup current data
backup_data() {
    echo "💾 Creating backup..."
    ./scripts/backup/backup.sh
}

# Deploy function
deploy() {
    echo "📦 Pulling latest images..."
    docker composepull
    
    echo "🔄 Restarting services..."
    docker composedown
    docker composeup -d
    
    echo "⏳ Waiting for services to be ready..."
    sleep 30
    
    # Health check
    if curl -f http://localhost:5678/healthz > /dev/null 2>&1; then
        echo "✅ Deployment successful!"
    else
        echo "❌ Deployment failed - service not responding"
        exit 1
    fi
}

main() {
    validate_env
    backup_data
    deploy
}

main
