# Makefile for N8N Professional Base Repository

.PHONY: help setup start stop restart logs backup health clean deploy

# Default target
help: ## Show this help message
	@echo "N8N Professional Base Repository Commands"
	@echo "========================================"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Setup and initialization
setup: ## Setup project structure and environment
	@echo "🚀 Setting up N8N project..."
	@chmod +x setup.sh
	@./setup.sh

init: setup ## Alias for setup

# Docker operations
start: ## Start N8N services
	@echo "▶️  Starting N8N services..."
	@docker compose up -d
	@echo "✅ N8N started at http://localhost:5678"

stop: ## Stop N8N services
	@echo "⏹️  Stopping N8N services..."
	@docker compose down

restart: ## Restart N8N services
	@echo "🔄 Restarting N8N services..."
	@docker compose restart

# Logs and monitoring
logs: ## Show N8N logs
	@docker compose logs -f n8n

logs-all: ## Show all services logs
	@docker compose logs -f

health: ## Check services health
	@echo "🔍 Checking services health..."
	@chmod +x scripts/monitoring/health-check.sh
	@./scripts/monitoring/health-check.sh

status: ## Show services status
	@docker compose ps

# Backup and restore
backup: ## Create backup of N8N data
	@echo "💾 Creating backup..."
	@chmod +x scripts/backup/backup.sh
	@./scripts/backup/backup.sh

restore: ## Restore from backup (usage: make restore BACKUP=backup_name)
	@echo "🔄 Restoring from backup..."
	@chmod +x scripts/backup/restore.sh
	@./scripts/backup/restore.sh $(BACKUP)

# Development
dev: ## Start in development mode
	@echo "🛠️  Starting in development mode..."
	@export NODE_ENV=development && docker compose up -d
	@docker compose logs -f n8n

# Production
deploy: ## Deploy to production
	@echo "🚀 Deploying to production..."
	@chmod +x scripts/deployment/deploy.sh
	@./scripts/deployment/deploy.sh

# Maintenance
update: ## Update N8N to latest version
	@echo "📦 Updating N8N..."
	@docker compose pull n8n
	@docker compose up -d n8n

clean: ## Clean up unused Docker resources
	@echo "🧹 Cleaning up..."
	@docker system prune -f
	@docker volume prune -f

clean-all: ## Clean up everything (including volumes)
	@echo "🧹 Cleaning up everything..."
	@docker compose down -v
	@docker system prune -a -f
	@docker volume prune -f

# Configuration
config: ## Show current configuration
	@echo "⚙️  Current configuration:"
	@docker compose config

env: ## Show environment variables
	@echo "🔧 Environment variables:"
	@cat .env | grep -v '^#' | grep -v '^$$'

# Database operations
db-shell: ## Access database shell
	@echo "🗄️  Accessing database..."
	@docker exec -it postgres_n8n psql -U n8n -d n8ndb

db-backup: ## Backup database only
	@echo "💾 Backing up database..."
	@mkdir -p backup
	@docker exec postgres_n8n pg_dump -U n8n n8ndb > backup/db_backup_$(shell date +%Y%m%d_%H%M%S).sql

# Security
generate-keys: ## Generate new security keys
	@echo "🔐 Generating security keys..."
	@echo "N8N_ENCRYPTION_KEY=$$(openssl rand -base64 32)"
	@echo "N8N_USER_MANAGEMENT_JWT_SECRET=$$(openssl rand -base64 64)"

# Network operations
network-create: ## Create Docker network
	@echo "🌐 Creating Docker network..."
	@docker network create n8n_network || true

network-remove: ## Remove Docker network
	@echo "🌐 Removing Docker network..."
	@docker network rm n8n_network || true

# Workflow operations
workflows-list: ## List all workflows
	@echo "📋 Listing workflows..."
	@ls -la data/workflows/ 2>/dev/null || echo "No workflows found"

workflows-backup: ## Backup workflows only
	@echo "💾 Backing up workflows..."
	@mkdir -p backup
	@if [ -d "data/workflows" ] && [ "$(ls -A data/workflows 2>/dev/null)" ]; then \
		tar -czf backup/workflows_backup_$(shell date +%Y%m%d_%H%M%S).tar.gz -C data/workflows .; \
		echo "✅ Workflows backed up"; \
	else \
		echo "ℹ️  No workflows to backup"; \
	fi

# Installation verification
verify: ## Verify installation
	@echo "✅ Verifying installation..."
	@make health
	@echo "🌐 N8N URL: http://localhost:5678"
	@echo "🔑 Check credentials in .env file"

# Quick start
quick-start: setup start ## Quick start (setup + start)
	@echo "🎉 N8N is ready!"
	@echo "📍 Access: http://localhost:5678"
	@echo "🔑 Credentials: Check .env file"

# Default environment variables
NODE_ENV ?= development
BACKUP ?= latest