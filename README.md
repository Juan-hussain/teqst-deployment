# TEQST - Text-to-Speech and Speech-to-Text Platform

TEQST is a comprehensive platform for managing text content, recording audio versions, and providing access to speech data. The system consists of two main components: a Django REST API backend and an Angular/Ionic frontend.

**Note**: This is a full server deployment setup. Both frontend and backend run on the production server at `116.202.96.11`.

## Project Structure

```
TEQST/
├── TEQST_Frontend/          # Angular/Ionic frontend application
├── TEQST_Backend/           # Django REST API backend
└── README.md                # This file
```

## Server Deployment

### Prerequisites

- **Server Access**: SSH access to your server at `116.202.96.11`
- **Python**: Python 3.8+ on the server
- **Node.js**: Node.js 14+ on the server
- **Web Server**: nginx or Apache for serving the frontend
- **Process Manager**: PM2 or systemd for managing services

### 1. Server Setup

#### Connect to Your Server
```bash
ssh user@116.202.96.11
```

#### Install System Dependencies
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip python3-venv nodejs npm nginx

# CentOS/RHEL
sudo yum install python3 python3-pip nodejs npm nginx
```

### 2. Clone and Setup Backend

```bash
# Clone the repository
git clone <repository-url>
cd TEQST

# Navigate to backend
cd TEQST_Backend

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Navigate to Django project
cd TEQST

# Copy and configure local settings
cp setup_templates/localsettings_template.py localsettings.py

# Generate secret key
python manage.py newsecretkey

# Edit localsettings.py with production settings
nano localsettings.py
```

#### Production Settings (localsettings.py)
```python
SECRET_KEY = 'your-generated-secret-key'
DEBUG = False
ALLOWED_HOSTS = ['116.202.96.11', 'your-domain.com']

# Database (use PostgreSQL for production)
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'teqst_db',
        'USER': 'teqst_user',
        'PASSWORD': 'your_password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}

# Static files
STATIC_ROOT = '/var/www/teqst/static/'
MEDIA_ROOT = '/var/www/teqst/media/'
```

#### Setup Database
```bash
# Run migrations
python manage.py makemigrations usermgmt textmgmt recordingmgmt
python manage.py migrate

# Setup initial data
python manage.py setup

# Collect static files
python manage.py collectstatic
```

### 3. Setup Frontend

```bash
# Navigate to frontend
cd ../../TEQST_Frontend

# Install global dependencies
npm install -g @ionic/cli
npm install -g @angular/cli

# Install project dependencies
npm install

# Build for production
ionic build --prod
```

### 4. Configure Web Server (nginx)

#### Create nginx Configuration
```bash
sudo nano /etc/nginx/sites-available/teqst
```

#### nginx Configuration
```nginx
server {
    listen 80;
    server_name 116.202.96.11 your-domain.com;

    # Frontend
    location / {
        root /path/to/TEQST/TEQST_Frontend/www;
        try_files $uri $uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Django Admin
    location /admin/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
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
```

#### Enable Site
```bash
sudo ln -s /etc/nginx/sites-available/teqst /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 5. Setup Process Management

#### Option A: PM2 (Recommended)
```bash
# Install PM2
npm install -g pm2

# Create ecosystem file
nano ecosystem.config.js
```

#### PM2 Configuration (ecosystem.config.js)
```javascript
module.exports = {
  apps: [{
    name: 'teqst-backend',
    script: 'manage.py',
    cwd: '/path/to/TEQST/TEQST_Backend/TEQST',
    interpreter: '/path/to/TEQST/TEQST_Backend/venv/bin/python',
    args: 'runserver 127.0.0.1:8000',
    env: {
      DJANGO_SETTINGS_MODULE: 'TEQST.localsettings'
    }
  }]
}
```

#### Start Services
```bash
# Start backend
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save
pm2 startup
```

#### Option B: systemd
```bash
# Create service file
sudo nano /etc/systemd/system/teqst-backend.service
```

#### systemd Service File
```ini
[Unit]
Description=TEQST Backend
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/path/to/TEQST/TEQST_Backend/TEQST
Environment=PATH=/path/to/TEQST/TEQST_Backend/venv/bin
ExecStart=/path/to/TEQST/TEQST_Backend/venv/bin/python manage.py runserver 127.0.0.1:8000
Restart=always

[Install]
WantedBy=multi-user.target
```

#### Enable and Start Service
```bash
sudo systemctl enable teqst-backend
sudo systemctl start teqst-backend
sudo systemctl status teqst-backend
```

### 6. Final Configuration

#### Update Frontend Constants
Ensure `TEQST_Frontend/src/app/constants.ts` points to the server:
```typescript
export class Constants {
  public static SERVER_URL = 'http://116.202.96.11';  // Server URL (no port needed with nginx)
  public static REQUEST_TIMEOUT = 30000;
  public static DISABLE_NO_INTERNET_ALERT = false;
}
```

#### Rebuild Frontend
```bash
cd TEQST_Frontend
ionic build --prod
```

## Access Points

Once deployed, your application will be accessible at:

- **Frontend**: `http://116.202.96.11/`
- **Backend API**: `http://116.202.96.11/api/`
- **Admin Interface**: `http://116.202.96.11/admin/`

## Maintenance

### Update Application
```bash
# Pull latest changes
git pull origin main

# Backend updates
cd TEQST_Backend/TEQST
source ../venv/bin/activate
pip install -r ../requirements.txt
python manage.py migrate
python manage.py collectstatic

# Frontend updates
cd ../../TEQST_Frontend
npm install
ionic build --prod

# Restart services
pm2 restart teqst-backend
# or
sudo systemctl restart teqst-backend
```

### Monitor Services
```bash
# Check PM2 status
pm2 status
pm2 logs teqst-backend

# Check systemd status
sudo systemctl status teqst-backend
sudo journalctl -u teqst-backend -f

# Check nginx status
sudo systemctl status nginx
sudo nginx -t
```

### Backup Database
```bash
# PostgreSQL backup
pg_dump teqst_db > teqst_backup_$(date +%Y%m%d_%H%M%S).sql

# SQLite backup (if using SQLite)
cp db.sqlite3 db.sqlite3.backup
```

## Security Considerations

1. **HTTPS**: Set up SSL certificates with Let's Encrypt
2. **Firewall**: Configure firewall to only allow necessary ports
3. **Database**: Use strong passwords and limit access
4. **Updates**: Keep system packages updated
5. **Monitoring**: Set up log monitoring and alerts

## Troubleshooting

### Common Issues

1. **Port 8000 not accessible**
   - Check if backend is running: `pm2 status` or `sudo systemctl status teqst-backend`
   - Verify nginx configuration: `sudo nginx -t`

2. **Frontend not loading**
   - Check nginx error logs: `sudo tail -f /var/log/nginx/error.log`
   - Verify frontend build exists: `ls -la /path/to/TEQST/TEQST_Frontend/www/`

3. **Database connection errors**
   - Check database service: `sudo systemctl status postgresql`
   - Verify database credentials in `localsettings.py`

4. **Permission errors**
   - Check file permissions: `ls -la /var/www/teqst/`
   - Ensure nginx user has access: `sudo chown -R www-data:www-data /var/www/teqst/`

## Support

For deployment support and questions:
- Check the individual README files in each directory
- Review nginx and PM2/systemd documentation
- Check server logs for detailed error information
- Open an issue on the respective repository
