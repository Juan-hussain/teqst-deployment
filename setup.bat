@echo off
REM TEQST Setup Script for Windows
REM This script automates the setup of both frontend and backend components
REM Note: This is a production deployment setup

echo 🚀 TEQST Setup Script
echo ======================
echo.

echo This script will set up both the TEQST backend and frontend.
echo.
echo IMPORTANT: This is a production deployment setup!
echo - Frontend is configured to connect to production server at 116.202.96.11:8000
echo - You can optionally configure it for local development
echo.
echo Make sure you have the following prerequisites installed:
echo - Python 3.8+
echo - Node.js 14+
echo - npm
echo.

set /p CONTINUE="Do you want to continue? (y/N): "
if /i not "%CONTINUE%"=="y" (
    echo Setup cancelled.
    pause
    exit /b 0
)

echo.
echo [INFO] Checking prerequisites...

REM Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH
    pause
    exit /b 1
)
echo [SUCCESS] Python found: 
python --version

REM Check Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed or not in PATH
    pause
    exit /b 1
)
echo [SUCCESS] Node.js found:
node --version

REM Check npm
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] npm is not installed or not in PATH
    pause
    exit /b 1
)
echo [SUCCESS] npm found:
npm --version

echo.
echo [INFO] Setting up backend...

cd TEQST_Backend

REM Create virtual environment
if not exist "venv" (
    echo [INFO] Creating virtual environment...
    python -m venv venv
    echo [SUCCESS] Virtual environment created
) else (
    echo [WARNING] Virtual environment already exists
)

REM Activate virtual environment
echo [INFO] Activating virtual environment...
call venv\Scripts\activate.bat

REM Install dependencies
echo [INFO] Installing Python dependencies...
pip install -r requirements.txt
echo [SUCCESS] Dependencies installed

REM Navigate to Django project
cd TEQST

REM Copy local settings if it doesn't exist
if not exist "localsettings.py" (
    echo [INFO] Creating local settings file...
    copy setup_templates\localsettings_template.py localsettings.py
    
    REM Generate secret key
    echo [INFO] Generating secret key...
    for /f "tokens=*" %%i in ('python manage.py newsecretkey') do set SECRET_KEY=%%i
    echo [SUCCESS] Secret key generated
    
    REM Update localsettings.py with the secret key
    powershell -Command "(Get-Content localsettings.py) -replace 'SECRET_KEY = ''YOUR_SECRET_KEY''', 'SECRET_KEY = ''%SECRET_KEY%''' | Set-Content localsettings.py"
    echo [SUCCESS] Local settings configured
) else (
    echo [WARNING] Local settings file already exists
)

REM Run migrations
echo [INFO] Running database migrations...
python manage.py makemigrations usermgmt textmgmt recordingmgmt
python manage.py migrate
echo [SUCCESS] Database migrations completed

REM Setup initial data
echo [INFO] Setting up initial data...
echo y | python manage.py setup
echo [SUCCESS] Initial data setup completed

cd ..\..

echo [SUCCESS] Backend setup completed!
echo.

echo [INFO] Setting up frontend...

cd TEQST_Frontend

REM Install global dependencies
echo [INFO] Installing global dependencies...
npm install -g @ionic/cli
npm install -g @angular/cli
echo [SUCCESS] Global dependencies installed

REM Install project dependencies
echo [INFO] Installing project dependencies...
npm install
echo [SUCCESS] Project dependencies installed

REM Check current configuration
echo [INFO] Checking frontend configuration...
findstr "116.202.96.11" src\app\constants.ts >nul
if %errorlevel% equ 0 (
    echo [SUCCESS] Frontend configured for production server (116.202.96.11:8000)
    echo [WARNING] This is a production deployment setup
    echo.
    echo Configuration options:
    echo 1. Keep production setup (current): Frontend connects to production server
    echo 2. Switch to local development: Frontend connects to local backend
    echo.
    set /p SWITCH_DEV="Do you want to switch to local development? (y/N): "
    if /i "%SWITCH_DEV%"=="y" (
        echo [INFO] Switching to local development configuration...
        powershell -Command "(Get-Content src\app\constants.ts) -replace 'http://116.202.96.11:8000', 'http://localhost:8000' | Set-Content src\app\constants.ts"
        echo [SUCCESS] Updated SERVER_URL to localhost for local development
    ) else (
        echo [INFO] Keeping production configuration
    )
) else (
    echo [WARNING] SERVER_URL already configured for local development
)

cd ..

echo [SUCCESS] Frontend setup completed!
echo.

echo 🎉 Setup completed successfully!
echo.
echo Configuration Summary:
echo ======================
echo.

REM Check final configuration
findstr "116.202.96.11" TEQST_Frontend\src\app\constants.ts >nul
if %errorlevel% equ 0 (
    echo ✅ Frontend: Configured for PRODUCTION server (116.202.96.11:8000)
    echo    - Frontend will connect to production backend
    echo    - Good for testing against production data
) else (
    echo ✅ Frontend: Configured for LOCAL development (localhost:8000)
    echo    - Frontend will connect to local backend
    echo    - Good for development and testing
)

echo.
echo Next steps:
echo 1. Start the backend (if using local development):
echo    cd TEQST_Backend\TEQST
echo    venv\Scripts\activate.bat
echo    python manage.py runserver
echo.
echo 2. Start the frontend:
echo    cd TEQST_Frontend
echo    ionic serve
echo.
echo 3. Access the application:
echo    Frontend: http://localhost:8100

REM Check final configuration for backend URL
findstr "116.202.96.11" TEQST_Frontend\src\app\constants.ts >nul
if %errorlevel% equ 0 (
    echo    Backend:  http://116.202.96.11:8000 (production)
) else (
    echo    Backend:  http://localhost:8000 (local)
)

echo    Admin:    http://116.202.96.11:8000/admin (production)
echo.

pause
