#!/bin/bash
# setup.sh - Project Setup Script

echo "🚀 Setting up N8N Professional Base Repository"

# Create project structure
create_project_structure() {
    echo "📁 Creating project structure..."
    
    # Core directories
    mkdir -p {data/workflows,scripts,backup}
    
    # Scripts directories
    mkdir -p scripts/{deployment,backup,monitoring}
    
    # Create .gitkeep for empty directories
    touch data/.gitkeep backup/.gitkeep
    
    echo "✅ Project structure created"
}

# Set proper permissions
set_permissions() {
    echo "🔒 Setting permissions..."
    
    # N8N data directory (1000:1000 is n8n user in container)
    sudo chown -R 1000:1000 data/
    chmod -R 755 data/
    
    # Scripts executable
    find scripts/ -name "*.sh" -exec chmod +x {} \;
    
    echo "✅ Permissions set"
}

# Create environment file
setup_environment() {
    echo "⚙️  Setting up environment..."
    
    if [ ! -f .env ]; then
        cp .env.template .env
        echo "📝 Created .env file from template"
        echo "⚠️  Please update the security keys in .env file!"
    else
        echo "ℹ️  .env file already exists"
    fi
}

# Create docker network
create_network() {
    echo "🌐 Creating Docker network..."
    
    if ! docker network ls | grep -q "n8n_network"; then
        docker network create n8n_network
        echo "✅ Docker network 'n8n_network' created"
    else
        echo "ℹ️  Docker network 'n8n_network' already exists"
    fi
}

# Generate security keys
generate_keys() {
    echo "🔐 Generating security keys..."
    
    ENCRYPTION_KEY=$(openssl rand -base64 32)
    JWT_SECRET=$(openssl rand -base64 64)
    
    echo "Generated keys (add these to your .env file):"
    echo "N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY"
    echo "N8N_USER_MANAGEMENT_JWT_SECRET=$JWT_SECRET"
}

# Main setup function
main() {
    echo "Starting N8N setup..."
    
    create_project_structure
    set_permissions
    setup_environment
    create_network
    generate_keys
    
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Update security keys in .env file"
    echo "2. Run: docker composeup -d"
    echo "3. Access N8N at: http://localhost:5678"
    echo "4. Login with credentials from .env file"
}

# Run main function
main