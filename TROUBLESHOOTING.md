# TEQST Troubleshooting Guide

This guide helps you resolve common issues when setting up and running TEQST.

## Table of Contents

- [Prerequisites Issues](#prerequisites-issues)
- [Backend Setup Issues](#backend-setup-issues)
- [Frontend Setup Issues](#frontend-setup-issues)
- [Runtime Issues](#runtime-issues)
- [Database Issues](#database-issues)
- [Network and Connection Issues](#network-and-connection-issues)
- [Performance Issues](#performance-issues)

## Prerequisites Issues

### Python Version Problems

**Issue**: `python3` command not found
```bash
# Solution 1: Use python instead
python --version

# Solution 2: Create alias
alias python3=python

# Solution 3: Install Python 3
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip python3-venv

# macOS
brew install python3

# Windows
# Download from https://python.org
```

**Issue**: Wrong Python version
```bash
# Check version
python --version

# Should show Python 3.8 or higher
# If not, install correct version
```

### Node.js Issues

**Issue**: `node` command not found
```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS
brew install node

# Windows
# Download from https://nodejs.org
```

**Issue**: Wrong Node.js version
```bash
# Check version
node --version

# Should show v14.0.0 or higher
# Use nvm to manage versions
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18
```

## Backend Setup Issues

### Virtual Environment Problems

**Issue**: `venv` command not found
```bash
# Install venv module
sudo apt install python3-venv  # Ubuntu/Debian
# or
pip install virtualenv
```

**Issue**: Permission denied when creating venv
```bash
# Check permissions
ls -la TEQST_Backend/

# Fix permissions if needed
chmod 755 TEQST_Backend/
```

**Issue**: Virtual environment activation fails
```bash
# Linux/Mac
source venv/bin/activate

# Windows
venv\Scripts\activate.bat

# If activation fails, recreate venv
rm -rf venv
python3 -m venv venv
```

### Dependency Installation Issues

**Issue**: `pip` command not found
```bash
# Install pip
sudo apt install python3-pip  # Ubuntu/Debian
# or
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
```

**Issue**: Permission errors during pip install
```bash
# Use --user flag
pip install --user -r requirements.txt

# Or activate virtual environment first
source venv/bin/activate
pip install -r requirements.txt
```

**Issue**: Package conflicts
```bash
# Upgrade pip
pip install --upgrade pip

# Clear pip cache
pip cache purge

# Reinstall in clean environment
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Django Configuration Issues

**Issue**: `localsettings.py` not found
```bash
# Navigate to correct directory
cd TEQST_Backend/TEQST

# Copy template
cp setup_templates/localsettings_template.py localsettings.py

# Edit the file with your settings
nano localsettings.py
```

**Issue**: Secret key generation fails
```bash
# Ensure you're in the right directory
cd TEQST_Backend/TEQST

# Generate key
python manage.py newsecretkey

# Copy the output and paste into localsettings.py
```

**Issue**: Database migration errors
```bash
# Check Django version compatibility
python manage.py check

# Reset migrations (WARNING: This will delete data)
python manage.py migrate --fake-initial

# Or start fresh
rm db.sqlite3
python manage.py makemigrations
python manage.py migrate
```

## Frontend Setup Issues

### Node.js and npm Issues

**Issue**: `npm` command not found
```bash
# Install npm
sudo apt install npm  # Ubuntu/Debian
# or
curl -qL https://www.npmjs.org/install.sh | sh
```

**Issue**: npm permission errors
```bash
# Use --unsafe-perm flag
npm install --unsafe-perm

# Or fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.profile
source ~/.profile
```

**Issue**: Package installation fails
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Ionic CLI Issues

**Issue**: `ionic` command not found
```bash
# Install Ionic CLI globally
npm install -g @ionic/cli

# If permission denied, use sudo
sudo npm install -g @ionic/cli
```

**Issue**: Ionic serve fails
```bash
# Check if port 8100 is in use
lsof -i :8100

# Use different port
ionic serve --port 8101

# Check for errors in output
ionic serve --verbose
```

### Angular CLI Issues

**Issue**: `ng` command not found
```bash
# Install Angular CLI
npm install -g @angular/cli

# Verify installation
ng version
```

**Issue**: Angular build errors
```bash
# Clear Angular cache
rm -rf .angular/cache

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Try building again
ng build
```

## Runtime Issues

### Backend Server Issues

**Issue**: Port 8000 already in use
```bash
# Find process using port 8000
lsof -i :8000

# Kill the process
kill -9 <PID>

# Or use different port
python manage.py runserver 8001
```

**Issue**: Django server won't start
```bash
# Check for syntax errors
python manage.py check

# Check settings
python manage.py diffsettings

# Run with verbose output
python manage.py runserver --verbosity 2
```

**Issue**: Import errors
```bash
# Ensure virtual environment is activated
source venv/bin/activate

# Check Python path
python -c "import sys; print(sys.path)"

# Reinstall Django
pip install --force-reinstall Django
```

### Frontend Runtime Issues

**Issue**: Frontend can't connect to backend
```bash
# Check backend is running
curl http://localhost:8000/api/

# Verify constants.ts SERVER_URL
cat src/app/constants.ts

# Check proxy configuration
cat src/proxy.config.json

# Test API endpoint
curl http://localhost:8000/api/users/
```

**Issue**: CORS errors
```bash
# Check Django CORS settings
# Ensure 'corsheaders.middleware.CorsMiddleware' is in MIDDLEWARE

# Add CORS settings to localsettings.py
CORS_ALLOW_ALL_ORIGINS = True  # For development only
CORS_ALLOWED_ORIGINS = [
    "http://localhost:8100",
    "http://127.0.0.1:8100",
]
```

**Issue**: Build errors in production
```bash
# Check Angular version compatibility
ng version

# Clear build cache
rm -rf www/ .angular/

# Build with verbose output
ionic build --prod --verbose
```

## Database Issues

### SQLite Issues

**Issue**: Database locked
```bash
# Check if multiple processes are accessing
ps aux | grep manage.py

# Restart Django server
# Ensure only one instance is running
```

**Issue**: Database corruption
```bash
# Backup current database
cp db.sqlite3 db.sqlite3.backup

# Try to repair
python manage.py dbshell
.repair
.quit

# If repair fails, restore from backup or recreate
```

### Migration Issues

**Issue**: Migration conflicts
```bash
# Show migration status
python manage.py showmigrations

# Fake migrations if needed
python manage.py migrate --fake

# Reset specific app
python manage.py migrate usermgmt zero
python manage.py migrate usermgmt
```

## Network and Connection Issues

### Local Network Issues

**Issue**: Can't access from other devices
```bash
# Use --external flag
ionic serve --external

# Check firewall settings
sudo ufw status

# Allow port 8100
sudo ufw allow 8100
```

**Issue**: Backend not accessible from frontend
```bash
# Check Django ALLOWED_HOSTS
# Add your IP to localsettings.py
ALLOWED_HOSTS = ['localhost', '127.0.0.1', 'YOUR_IP_ADDRESS']

# Restart Django server
```

### Proxy Issues

**Issue**: API requests not proxied
```bash
# Check proxy configuration
cat src/proxy.config.json

# Ensure proxy is enabled in angular.json
# Check "proxyConfig" in serve options

# Restart development server
ionic serve
```

## Performance Issues

### Slow Development Server

**Issue**: Frontend slow to load
```bash
# Use production build for testing
ionic build --prod
ionic serve --prod

# Check for large dependencies
npm ls --depth=0
```

**Issue**: Backend slow responses
```bash
# Check database queries
python manage.py shell
from django.db import connection
connection.queries

# Enable Django Debug Toolbar
pip install django-debug-toolbar
```

### Memory Issues

**Issue**: High memory usage
```bash
# Check memory usage
htop

# Restart services
# Clear caches
npm cache clean --force
pip cache purge
```

## Getting Help

### Debug Information

When reporting issues, include:

1. **Environment**:
   - Operating system and version
   - Python version: `python --version`
   - Node.js version: `node --version`
   - npm version: `npm --version`

2. **Error Messages**:
   - Full error output
   - Stack traces
   - Console logs

3. **Configuration**:
   - Relevant parts of settings files
   - Package versions
   - Environment variables

### Useful Commands

```bash
# Check system status
python manage.py check
python manage.py validate
ng version
ionic info

# Check logs
tail -f logfile.log
python manage.py runserver --verbosity 3

# Test connectivity
curl -v http://localhost:8000/api/
curl -v http://localhost:8100/
```

### Common Solutions

1. **Restart everything**: Stop all services and restart
2. **Clear caches**: Remove temporary files and caches
3. **Reinstall dependencies**: Delete and reinstall packages
4. **Check permissions**: Ensure proper file permissions
5. **Verify versions**: Check compatibility between components

Remember: Most issues can be resolved by following the setup instructions carefully and ensuring all prerequisites are properly installed.
