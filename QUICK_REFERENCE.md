# TEQST Quick Reference

## Essential Commands

### Backend (Django)

```bash
# Navigate to backend
cd TEQST_Backend

# Activate virtual environment
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate.bat # Windows

# Navigate to Django project
cd TEQST

# Run server
python manage.py runserver

# Run server on different port
python manage.py runserver 8001

# Check Django status
python manage.py check

# Database operations
python manage.py makemigrations
python manage.py migrate
python manage.py showmigrations

# Create superuser
python manage.py setup

# Generate secret key
python manage.py newsecretkey

# Run tests
python manage.py test
python manage.py test usermgmt
```

### Frontend (Angular/Ionic)

```bash
# Navigate to frontend
cd TEQST_Frontend

# Install dependencies
npm install

# Start development server
ionic serve

# Start with external access
ionic serve --external

# Start on different port
ionic serve --port 8101

# Build for production
ionic build --prod

# Run tests
npm test

# Lint code
npm run lint

# Check Angular version
ng version

# Check Ionic info
ionic info
```

## File Locations

### Configuration Files

| File | Location | Purpose |
|------|----------|---------|
| `localsettings.py` | `TEQST_Backend/TEQST/` | Django local settings |
| `constants.ts` | `TEQST_Frontend/src/app/` | Frontend configuration |
| `proxy.config.json` | `TEQST_Frontend/src/` | API proxy configuration |
| `requirements.txt` | `TEQST_Backend/` | Python dependencies |
| `package.json` | `TEQST_Frontend/` | Node.js dependencies |

### Key Directories

| Directory | Purpose |
|-----------|---------|
| `TEQST_Backend/TEQST/usermgmt/` | User management app |
| `TEQST_Backend/TEQST/textmgmt/` | Text content management |
| `TEQST_Backend/TEQST/recordingmgmt/` | Audio recording management |
| `TEQST_Frontend/src/app/services/` | Frontend services |
| `TEQST_Frontend/src/app/tabs/` | Main navigation |
| `TEQST_Frontend/src/app/speak/` | Recording functionality |
| `TEQST_Frontend/src/app/listen/` | Audio playback |

## Development URLs

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | `http://localhost:8100` | Main application |
| Backend API | `http://localhost:8000/api/` | REST API endpoints |
| Django Admin | `http://localhost:8000/admin/` | Admin interface |
| API Docs | `http://localhost:8000/api/` | API documentation |

## Common API Endpoints

### Authentication
- `POST /api/auth/login/` - User login
- `POST /api/auth/logout/` - User logout

### User Management
- `GET /api/users/` - List users
- `GET /api/users/<id>/` - User details

### Content Management
- `GET /api/pub/folders/` - Publisher folders
- `POST /api/pub/texts/` - Upload text
- `GET /api/spk/texts/` - Speaker access
- `GET /api/lstn/texts/` - Listener access

## Environment Variables

### Backend (localsettings.py)
```python
SECRET_KEY = 'your-secret-key'
DEBUG = True
DATABASES = {...}
ALLOWED_HOSTS = ['localhost', '127.0.0.1']
```

### Frontend (constants.ts)
```typescript
export class Constants {
  public static SERVER_URL = 'http://localhost:8000';
  public static REQUEST_TIMEOUT = 30000;
  public static DISABLE_NO_INTERNET_ALERT = false;
}
```

## Troubleshooting Commands

### Check Services
```bash
# Check if ports are in use
lsof -i :8000  # Backend
lsof -i :8100  # Frontend

# Check processes
ps aux | grep manage.py
ps aux | grep ionic

# Check network
curl http://localhost:8000/api/
curl http://localhost:8100/
```

### Reset Services
```bash
# Backend
cd TEQST_Backend/TEQST
source ../venv/bin/activate
python manage.py runserver

# Frontend
cd TEQST_Frontend
ionic serve
```

### Clear Caches
```bash
# Frontend
rm -rf .angular/cache
rm -rf node_modules
npm install

# Backend
pip cache purge
rm -rf venv
python3 -m venv venv
```

## Database Operations

### SQLite Commands
```bash
# Access database shell
python manage.py dbshell

# Backup database
cp db.sqlite3 db.sqlite3.backup

# Check database integrity
python manage.py dbshell
.integrity_check
.quit
```

### Migration Commands
```bash
# Show migration status
python manage.py showmigrations

# Fake migrations
python manage.py migrate --fake

# Reset specific app
python manage.py migrate usermgmt zero
python manage.py migrate usermgmt
```

## Testing

### Backend Testing
```bash
# Run all tests
python manage.py test

# Run specific app tests
python manage.py test usermgmt
python manage.py test textmgmt
python manage.py test recordingmgmt

# Run with coverage
pip install coverage
coverage run manage.py test
coverage report
```

### Frontend Testing
```bash
# Run unit tests
npm test

# Run e2e tests
npm run e2e

# Run linting
npm run lint

# Check build
ionic build --prod
```

## Deployment Commands

### Backend Deployment
```bash
# Collect static files
python manage.py collectstatic

# Check production settings
python manage.py check --deploy

# Run with production server
gunicorn TEQST.wsgi:application
```

### Frontend Deployment
```bash
# Build production version
ionic build --prod

# Deploy to web server
# Copy www/ directory to web server
```

## Useful Aliases

Add these to your shell profile (`.bashrc`, `.zshrc`):

```bash
# Backend shortcuts
alias teqst-backend='cd TEQST_Backend/TEQST && source ../venv/bin/activate'
alias teqst-run='cd TEQST_Backend/TEQST && source ../venv/bin/activate && python manage.py runserver'

# Frontend shortcuts
alias teqst-frontend='cd TEQST_Frontend'
alias teqst-serve='cd TEQST_Frontend && ionic serve'

# Quick navigation
alias teqst='cd /path/to/TEQST'
alias teqst-back='cd TEQST_Backend'
alias teqst-front='cd TEQST_Frontend'
```

## Version Information

### Check Versions
```bash
# Python
python --version
pip list | grep Django

# Node.js
node --version
npm --version

# Angular/Ionic
ng version
ionic info

# Django
python manage.py --version
```

### Compatible Versions
- **Python**: 3.8+
- **Node.js**: 14+
- **Django**: 3.2+
- **Angular**: 13.1.3
- **Ionic**: 6.2

## Quick Setup Commands

### One-liner Backend Setup
```bash
cd TEQST_Backend && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt && cd TEQST && cp setup_templates/localsettings_template.py localsettings.py && python manage.py newsecretkey && python manage.py makemigrations && python manage.py migrate && python manage.py setup
```

### One-liner Frontend Setup
```bash
cd TEQST_Frontend && npm install -g @ionic/cli @angular/cli && npm install
```

Remember: Always activate the virtual environment before working with the backend, and ensure both services are running for full functionality.
