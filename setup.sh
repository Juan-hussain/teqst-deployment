#!/bin/bash

# TEQST Setup Script
# This script automates the setup of both frontend and backend components
# Note: This is a production deployment setup

set -e  # Exit on any error

echo "🚀 TEQST Setup Script"
echo "======================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Python
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
        print_success "Python 3 found: $(python3 --version)"
    elif command -v python &> /dev/null; then
        PYTHON_VERSION=$(python --version 2>&1)
        if [[ $PYTHON_VERSION == Python\ 3* ]]; then
            PYTHON_CMD="python"
            print_success "Python 3 found: $PYTHON_VERSION"
        else
            print_error "Python 3 is required. Found: $PYTHON_VERSION"
            exit 1
        fi
    else
        print_error "Python 3 is not installed"
        exit 1
    fi
    
    # Check Node.js
    if command -v node &> /dev/null; then
        print_success "Node.js found: $(node --version)"
    else
        print_error "Node.js is not installed"
        exit 1
    fi
    
    # Check npm
    if command -v npm &> /dev/null; then
        print_success "npm found: $(npm --version)"
    else
        print_error "npm is not installed"
        exit 1
    fi
    
    echo ""
}

# Setup backend
setup_backend() {
    print_status "Setting up backend..."
    
    cd TEQST_Backend
    
    # Create virtual environment
    if [ ! -d "venv" ]; then
        print_status "Creating virtual environment..."
        $PYTHON_CMD -m venv venv
        print_success "Virtual environment created"
    else
        print_warning "Virtual environment already exists"
    fi
    
    # Activate virtual environment
    print_status "Activating virtual environment..."
    source venv/bin/activate
    
    # Install dependencies
    print_status "Installing Python dependencies..."
    pip install -r requirements.txt
    print_success "Dependencies installed"
    
    # Navigate to Django project
    cd TEQST
    
    # Copy local settings if it doesn't exist
    if [ ! -f "localsettings.py" ]; then
        print_status "Creating local settings file..."
        cp setup_templates/localsettings_template.py localsettings.py
        
        # Generate secret key
        print_status "Generating secret key..."
        SECRET_KEY=$($PYTHON_CMD manage.py newsecretkey)
        print_success "Secret key generated"
        
        # Update localsettings.py with the secret key
        sed -i "s/SECRET_KEY = 'YOUR_SECRET_KEY'/SECRET_KEY = '$SECRET_KEY'/" localsettings.py
        print_success "Local settings configured"
    else
        print_warning "Local settings file already exists"
    fi
    
    # Run migrations
    print_status "Running database migrations..."
    $PYTHON_CMD manage.py makemigrations usermgmt textmgmt recordingmgmt
    $PYTHON_CMD manage.py migrate
    print_success "Database migrations completed"
    
    # Setup initial data
    print_status "Setting up initial data..."
    echo "y" | $PYTHON_CMD manage.py setup
    print_success "Initial data setup completed"
    
    cd ../..
    print_success "Backend setup completed!"
    echo ""
}

# Setup frontend
setup_frontend() {
    print_status "Setting up frontend..."
    
    cd TEQST_Frontend
    
    # Install global dependencies
    print_status "Installing global dependencies..."
    npm install -g @ionic/cli
    npm install -g @angular/cli
    print_success "Global dependencies installed"
    
    # Install project dependencies
    print_status "Installing project dependencies..."
    npm install
    print_success "Project dependencies installed"
    
    # Check current configuration
    print_status "Checking frontend configuration..."
    if grep -q "116.202.96.11" src/app/constants.ts; then
        print_success "Frontend configured for production server (116.202.96.11:8000)"
        print_warning "This is a production deployment setup"
        echo ""
        echo "Configuration options:"
        echo "1. Keep production setup (current): Frontend connects to production server"
        echo "2. Switch to local development: Frontend connects to local backend"
        echo ""
        read -p "Do you want to switch to local development? (y/N): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Switching to local development configuration..."
            sed -i "s|http://116.202.96.11:8000|http://localhost:8000|" src/app/constants.ts
            print_success "Updated SERVER_URL to localhost for local development"
        else
            print_status "Keeping production configuration"
        fi
    else
        print_warning "SERVER_URL already configured for local development"
    fi
    
    cd ..
    print_success "Frontend setup completed!"
    echo ""
}

# Main setup function
main() {
    echo "This script will set up both the TEQST backend and frontend."
    echo ""
    echo "IMPORTANT: This is a production deployment setup!"
    echo "- Frontend is configured to connect to production server at 116.202.96.11:8000"
    echo "- You can optionally configure it for local development"
    echo ""
    echo "Make sure you have the following prerequisites installed:"
    echo "- Python 3.8+"
    echo "- Node.js 14+"
    echo "- npm"
    echo ""
    
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
    
    check_prerequisites
    setup_backend
    setup_frontend
    
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "Configuration Summary:"
    echo "======================"
    echo ""
    
    # Check final configuration
    if grep -q "116.202.96.11" TEQST_Frontend/src/app/constants.ts; then
        echo "✅ Frontend: Configured for PRODUCTION server (116.202.96.11:8000)"
        echo "   - Frontend will connect to production backend"
        echo "   - Good for testing against production data"
    else
        echo "✅ Frontend: Configured for LOCAL development (localhost:8000)"
        echo "   - Frontend will connect to local backend"
        echo "   - Good for development and testing"
    fi
    
    echo ""
    echo "Next steps:"
    echo "1. Start the backend (if using local development):"
    echo "   cd TEQST_Backend/TEQST"
    echo "   source ../venv/bin/activate"
    echo "   python manage.py runserver"
    echo ""
    echo "2. Start the frontend:"
    echo "   cd TEQST_Frontend"
    echo "   ionic serve"
    echo ""
    echo "3. Access the application:"
    echo "   Frontend: http://localhost:8100"
    if grep -q "116.202.96.11" TEQST_Frontend/src/app/constants.ts; then
        echo "   Backend:  http://116.202.96.11:8000 (production)"
    else
        echo "   Backend:  http://localhost:8000 (local)"
    fi
    echo "   Admin:    http://116.202.96.11:8000/admin (production)"
    echo ""
}

# Run main function
main "$@"
