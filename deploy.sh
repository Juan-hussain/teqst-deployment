#!/bin/bash

# TEQST Server Deployment Script
# This script deploys both frontend and backend on the server

set -e  # Exit on any error

echo "🚀 TEQST Server Deployment Script"
echo "=================================="
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

# Configuration - Updated paths for new teqst directory structure
PROJECT_DIR="/opt/teqst"
BACKEND_DIR="$PROJECT_DIR/TEQST_Backend"
FRONTEND_DIR="$PROJECT_DIR/TEQST_Frontend"
NGINX_SITE="teqst"
SERVICE_NAME="teqst-backend"

# Check if running as root
# if [[ $EUID -eq 0 ]]; then
#    print_error "This script should not be run as root"
#    exit 1
# fi

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if required commands exist
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed"
        exit 1
    fi
    
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed"
        exit 1
    fi
    
    if ! command -v nginx &> /dev/null; then
        print_error "nginx is not installed"
        exit 1
    fi
    
    if ! command -v pm2 &> /dev/null; then
        print_warning "PM2 is not installed. Installing..."
        npm install -g pm2
    fi
    
    print_success "Prerequisites check passed"
    echo ""
}

# Setup backend
setup_backend() {
    print_status "Setting up backend..."
    
    cd "$BACKEND_DIR"
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        print_status "Creating virtual environment..."
        python3 -m venv venv
        print_success "Virtual environment created"
    fi
    
    # Activate virtual environment
    print_status "Activating virtual environment..."
    source venv/bin/activate
    
    # Install/update dependencies
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
        SECRET_KEY=$(python manage.py newsecretkey)
        print_success "Secret key generated"
        
        # Update localsettings.py with the secret key
        sed -i "s/SECRET_KEY = 'YOUR_SECRET_KEY'/SECRET_KEY = '$SECRET_KEY'/" localsettings.py
        
        # Update production settings
        sed -i "s/DEBUG = True/DEBUG = False/" localsettings.py
        sed -i "s/ALLOWED_HOSTS = \[\"localhost\", \"127.0.0.1\",\"116.202.96.11\"\]/ALLOWED_HOSTS = ['116.202.96.11', 'localhost', '127.0.0.1']/" localsettings.py
        
        print_success "Local settings configured for production"
    else
        print_warning "Local settings file already exists"
    fi
    
    # Run migrations
    print_status "Running database migrations..."
    python manage.py makemigrations usermgmt textmgmt recordingmgmt
    python manage.py migrate
    print_success "Database migrations completed"
    
    # Setup initial data if needed
    if [ ! -f "initial_setup_complete" ]; then
        print_status "Setting up initial data..."
        echo "y" | python manage.py setup
        touch initial_setup_complete
        print_success "Initial data setup completed"
    else
        print_warning "Initial setup already completed"
    fi
    
    # Collect static files
    print_status "Collecting static files..."
    python manage.py collectstatic --noinput
    print_success "Static files collected"
    
    cd "$PROJECT_DIR"
    print_success "Backend setup completed!"
    echo ""
}

# Setup frontend
setup_frontend() {
    print_status "Setting up frontend..."
    
    cd "$FRONTEND_DIR"
    
    # Install global dependencies
    print_status "Installing global dependencies..."
    npm install -g @ionic/cli @angular/cli
    print_success "Global dependencies installed"
    
    # Install project dependencies
    print_status "Installing project dependencies..."
    npm install
    print_success "Project dependencies installed"
    
    # Build for production
    print_status "Building frontend for production..."
    ionic build --prod
    print_success "Frontend built successfully"
    
    cd "$PROJECT_DIR"
    print_success "Frontend setup completed!"
    echo ""
}

# Setup nginx
setup_nginx() {
    print_status "Setting up nginx..."
    
    # Create nginx configuration
    sudo tee /etc/nginx/sites-available/$NGINX_SITE > /dev/null <<EOF
server {
    listen 80;
    server_name 116.202.96.11;

    # Frontend
    location / {
        root $FRONTEND_DIR/www;
        try_files \$uri \$uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Django Admin
    location /admin/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Static files
    location /static/ {
        alias /var/www/teqst/static/;
    }

    # Media files
    location /media/ {
        alias /var/www/teqst/media/;
    }
}
EOF
    
    # Enable site
    if [ ! -L "/etc/nginx/sites-enabled/$NGINX_SITE" ]; then
        sudo ln -s /etc/nginx/sites-available/$NGINX_SITE /etc/nginx/sites-enabled/
    fi
    
    # Test nginx configuration
    sudo nginx -t
    print_success "nginx configuration is valid"
    
    # Reload nginx
    sudo systemctl reload nginx
    print_success "nginx reloaded"
    
    echo ""
}

# Setup PM2 process management
setup_pm2() {
    print_status "Setting up PM2 process management..."
    
    cd "$PROJECT_DIR"
    
    # Create PM2 ecosystem file
    cat > ecosystem.config.js <<EOF
module.exports = {
  apps: [{
    name: '$SERVICE_NAME',
    script: 'manage.py',
    cwd: '$BACKEND_DIR/TEQST',
    interpreter: '$BACKEND_DIR/venv/bin/python',
    args: 'runserver 127.0.0.1:8000',
    env: {
      DJANGO_SETTINGS_MODULE: 'TEQST.localsettings'
    },
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
}
EOF
    
    # Create logs directory
    mkdir -p logs
    
    # Start the service
    print_status "Starting backend service..."
    pm2 start ecosystem.config.js
    
    # Save PM2 configuration
    pm2 save
    pm2 startup
    print_success "PM2 configuration saved"
    
    echo ""
}

# Setup systemd service (alternative to PM2)
setup_systemd() {
    print_status "Setting up systemd service..."
    
    sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null <<EOF
[Unit]
Description=TEQST Backend
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$BACKEND_DIR/TEQST
Environment=PATH=$BACKEND_DIR/venv/bin
ExecStart=$BACKEND_DIR/venv/bin/python manage.py runserver 127.0.0.1:8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    # Reload systemd and enable service
    sudo systemctl daemon-reload
    sudo systemctl enable $SERVICE_NAME
    print_success "systemd service configured"
    
    echo ""
}

# Create directories and set permissions
setup_directories() {
    print_status "Setting up directories and permissions..."
    
    # Create web directories
    sudo mkdir -p /var/www/teqst/{static,media}
    
    # Set ownership
    sudo chown -R $USER:$USER /var/www/teqst
    
    # Set permissions
    sudo chmod -R 755 /var/www/teqst
    
    print_success "Directories and permissions set"
    echo ""
}

# Main deployment function
main() {
    echo "This script will deploy TEQST on the server."
    echo "Make sure you have:"
    echo "- SSH access to the server"
    echo "- sudo privileges"
    echo "- Python 3.8+, Node.js 14+, nginx installed"
    echo ""
    
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled."
        exit 0
    fi
    
    check_prerequisites
    setup_directories
    setup_backend
    setup_frontend
    setup_nginx
    
    echo "Choose process management:"
    echo "1. PM2 (recommended)"
    echo "2. systemd"
    echo ""
    read -p "Enter your choice (1 or 2): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[1]$ ]]; then
        setup_pm2
    elif [[ $REPLY =~ ^[2]$ ]]; then
        setup_systemd
    else
        print_warning "Invalid choice, using PM2"
        setup_pm2
    fi
    
    echo "🎉 Deployment completed successfully!"
    echo ""
    
    # Run deployment tests
    print_status "Running deployment tests..."
    if command -v python3 &> /dev/null; then
        cd "$PROJECT_DIR"
        if python3 deployment_tests.py; then
            print_success "All deployment tests passed!"
        else
            print_warning "Some deployment tests failed. Please check the application manually."
        fi
    else
        print_warning "Python3 not available for automated testing"
    fi
    
    echo ""
    echo "Your application is now accessible at:"
    echo "✅ Frontend: http://116.202.96.11/"
    echo "✅ Backend API: http://116.202.96.11/api/"
    echo "✅ Admin Interface: http://116.202.96.11/admin/"
    echo ""
    echo "Next steps:"
    echo "1. Test the application in your browser"
    echo "2. Set up SSL certificates with Let's Encrypt"
    echo "3. Configure firewall rules"
    echo "4. Set up monitoring and backups"
    echo ""
    echo "Useful commands:"
    echo "- Check PM2 status: pm2 status"
    echo "- Check nginx status: sudo systemctl status nginx"
    echo "- View logs: pm2 logs $SERVICE_NAME"
    echo "- Restart services: pm2 restart $SERVICE_NAME"
    echo "- Run deployment tests: python3 deployment_tests.py"
}

# Run main function
main "$@"
