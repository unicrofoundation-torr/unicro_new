@echo off
echo =====================================================
echo 🚀 Frontend-Only Deployment started
echo =====================================================

REM --- Configuration ---
set "PROJECT_ROOT=%~dp0"
set "CLIENT_DIR=%PROJECT_ROOT%client"
set "LOG_DIR=%PROJECT_ROOT%logs"
set "PRIVATE_KEY=%USERPROFILE%\.ssh\key_private"
set "CPANEL_USER=theomkiq"
set "CPANEL_HOST=server357.web-hosting.com"
set "CPANEL_PORT=21098"
set "REMOTE_DIR=~/public_html"

REM --- Create necessary folders ---
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM --- Create log file ---
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
set "mytime=%mytime: =0%"
set "LOG_FILE=%LOG_DIR%\deploy_frontend_%mydate%_%mytime%.log"

REM --- Step 1: Build React Frontend ---
echo 🏗️ Building React project...
cd /d "%CLIENT_DIR%"

REM Install dependencies if needed
if not exist "node_modules" (
    echo    Installing dependencies...
    call npm install --legacy-peer-deps
)

REM Build the React app
set NODE_ENV=production
set GENERATE_SOURCEMAP=false
call npm run build

if %errorlevel% neq 0 (
    echo ❌ React build failed.
    exit /b 1
)

echo ✅ React build successful

REM --- Step 2: Upload build to cPanel ---
echo 🌐 Uploading build folder to cPanel...
echo    Source: %CLIENT_DIR%\build\
echo    Destination: %CPANEL_USER%@%CPANEL_HOST%:%REMOTE_DIR%

REM Use WSL bash for rsync
where bash >nul 2>&1
if %errorlevel% equ 0 (
    echo    Using WSL bash for rsync...
    bash -c "rsync -avz --progress --delete --exclude='node_modules/' --exclude='.git/' --exclude='.env' --exclude='*.map' --include='.htaccess' -e 'ssh -i %PRIVATE_KEY% -p %CPANEL_PORT%' '%CLIENT_DIR%/build/' %CPANEL_USER%@%CPANEL_HOST%:%REMOTE_DIR%"
) else (
    echo    ⚠️ bash/rsync not found - please deploy frontend manually
    echo    Or install WSL and rsync
    echo    You can manually upload the contents of: %CLIENT_DIR%\build\
    exit /b 1
)

if %errorlevel% neq 0 (
    echo ❌ Deployment failed during upload.
    echo Check the logs
    exit /b 1
)

echo ✅ Frontend deployment completed successfully!
echo.
echo =====================================================
echo 🎉 Frontend Deployed Successfully!
echo =====================================================
echo Logs saved at: %LOG_FILE%
echo.
echo Your frontend is now live at your website URL

