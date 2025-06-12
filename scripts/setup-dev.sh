#!/bin/bash

# Internal Tools Platform - Development Setup Script
# This script sets up the complete development environment

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command_exists node; then
        log_error "Node.js is not installed. Please install Node.js 18+ and try again."
        exit 1
    fi
    
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        log_error "Node.js version must be 18 or higher. Current version: $(node --version)"
        exit 1
    fi
    
    if ! command_exists npm; then
        log_error "npm is not installed. Please install npm and try again."
        exit 1
    fi
    
    if ! command_exists docker; then
        log_error "Docker is not installed. Please install Docker and try again."
        exit 1
    fi
    
    if ! command_exists docker-compose; then
        log_error "Docker Compose is not installed. Please install Docker Compose and try again."
        exit 1
    fi
    
    log_success "All prerequisites are installed"
}

# Setup environment
setup_environment() {
    log_info "Setting up environment..."
    
    if [ ! -f .env ]; then
        log_info "Creating .env file from template..."
        cp .env.example .env
        log_success "Created .env file. Please review and update as needed."
    else
        log_info ".env file already exists"
    fi
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    npm install
    log_success "Dependencies installed successfully"
}

# Start Docker services
start_services() {
    log_info "Starting Docker services..."
    docker-compose up -d postgres redis pgadmin redisinsight
    
    log_info "Waiting for services to be ready..."
    sleep 10
    
    # Wait for PostgreSQL to be ready
    until docker-compose exec -T postgres pg_isready -U dev -d internal_tools; do
        log_info "Waiting for PostgreSQL..."
        sleep 2
    done
    
    # Wait for Redis to be ready
    until docker-compose exec -T redis redis-cli ping; do
        log_info "Waiting for Redis..."
        sleep 2
    done
    
    log_success "All services are running"
}

# Setup database
setup_database() {
    log_info "Setting up database..."
    
    if [ -d "services/shared-services" ]; then
        cd services/shared-services
        
        # Install dependencies if not already installed
        if [ ! -d "node_modules" ]; then
            npm install
        fi
        
        # Run migrations
        if [ -f "package.json" ] && grep -q "db:migrate" package.json; then
            npm run db:migrate
            log_success "Database migrations completed"
        fi
        
        # Seed database
        if [ -f "package.json" ] && grep -q "db:seed" package.json; then
            npm run db:seed
            log_success "Database seeded with sample data"
        fi
        
        cd ../..
    else
        log_warning "Shared services not found. Skipping database setup."
    fi
}

# Start development servers
start_development_servers() {
    log_info "Starting development servers..."
    
    # Start services in background
    if [ -f "package.json" ] && grep -q "dev" package.json; then
        npm run dev &
        DEV_PID=$!
        
        log_info "Development servers are starting..."
        log_info "This may take a few moments..."
        sleep 5
        
        log_success "Development environment is ready!"
        echo ""
        log_info "Available services:"
        log_info "- Shared Services API: http://localhost:3001"
        log_info "- Resource Management App: http://localhost:3002"
        log_info "- API Documentation: http://localhost:3001/api"
        log_info "- Database Admin (pgAdmin): http://localhost:5050"
        log_info "- Redis Admin (RedisInsight): http://localhost:8081"
        echo ""
        log_info "To stop all services, run: npm run docker:down"
        log_info "To view logs, run: npm run logs"
        echo ""
        log_warning "Press Ctrl+C to stop the development servers"
        
        # Wait for the development process
        wait $DEV_PID
    else
        log_warning "No development script found. Please start services manually."
    fi
}

# Main function
main() {
    echo "🚀 Internal Tools Platform - Development Setup"
    echo "=============================================="
    echo ""
    
    check_prerequisites
    setup_environment
    install_dependencies
    start_services
    setup_database
    start_development_servers
}

# Handle script interruption
trap 'log_warning "Setup interrupted. Run docker-compose down to stop services."; exit 1' INT

main "$@"