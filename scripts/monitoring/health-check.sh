# scripts/monitoring/health-check.sh
#!/bin/bash
# Health monitoring script

check_service() {
    local service=$1
    local url=$2
    
    if curl -f "$url" > /dev/null 2>&1; then
        echo "✅ $service is healthy"
        return 0
    else
        echo "❌ $service is down"
        return 1
    fi
}

check_database() {
    if docker exec postgres_n8n pg_isready -U n8n > /dev/null 2>&1; then
        echo "✅ Database is healthy"
        return 0
    else
        echo "❌ Database is down"
        return 1
    fi
}

main() {
    echo "🔍 Checking N8N health..."
    
    local all_healthy=true
    
    check_service "N8N" "http://localhost:5678/healthz" || all_healthy=false
    check_database || all_healthy=false
    
    if [ "$all_healthy" = true ]; then
        echo "🎉 All services are healthy"
        exit 0
    else
        echo "⚠️  Some services are unhealthy"
        exit 1
    fi
}

main