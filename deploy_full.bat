@echo off
echo =====================================================
echo 🚀 Full Stack Deployment to cPanel
echo 🚀 Deployment started at %date% %time%
echo =====================================================
echo.

REM --- Configuration ---
REM Local Database (for backup)
set LOCAL_DB_USER=root
set LOCAL_DB_PASS=root123
set LOCAL_DB_NAME=charity_website

REM Remote Database (cPanel - UPDATE THESE!)
set REMOTE_DB_USER=theomkiq_charity
set REMOTE_DB_PASS=Unicro@001
set REMOTE_DB_NAME=theomkiq_charity_website
set REMOTE_DB_HOST=localhost

REM Project paths (Windows format)
set PROJECT_ROOT=E:\kanishk data\projects\UNICRO
set CLIENT_DIR=%PROJECT_ROOT%\client
set BUILD_DIR=%CLIENT_DIR%\build
set BACKUP_DIR=%PROJECT_ROOT%\backups
set LOG_DIR=%PROJECT_ROOT%\logs

REM SSH Configuration
set PRIVATE_KEY=%USERPROFILE%\.ssh\key_private
set CPANEL_USER=theomkiq
set CPANEL_HOST=server357.web-hosting.com
set CPANEL_PORT=21098

REM Remote directories
set FRONTEND_DIR=~/public_html
set BACKEND_DIR=~/nodejs

REM TinyMCE API Key
set TINYMCE_API_KEY=umr1eq61a2537s4649w0i6dru4y7cypj6clshpyrkmsti4k7

REM --- Create necessary folders ---
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM --- Create log file ---
set LOG_FILE=%LOG_DIR%\deploy_full_%date:~-4,4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%.log
echo Deployment started at %date% %time% > "%LOG_FILE%"

REM --- Step 1: MySQL Backup (Local) ---
echo 💾 Taking MySQL Backup (Local)...
set BACKUP_FILE=%BACKUP_DIR%\%LOCAL_DB_NAME%_%date:~-4,4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%.sql
if exist "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe" (
  "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe" -u%LOCAL_DB_USER% -p%LOCAL_DB_PASS% %LOCAL_DB_NAME% > "%BACKUP_FILE%" 2>nul
  if %errorlevel% equ 0 (
    echo ✅ MySQL backup successful: %BACKUP_FILE%
  ) else (
    echo ⚠️ MySQL backup failed (continuing anyway)
  )
) else (
  echo ⚠️ MySQL not found, skipping backup
)

REM --- Step 2: Push to GitHub (Optional) ---
echo 📦 Pushing latest code to GitHub...
cd /d "%PROJECT_ROOT%"
git add . 2>nul
git commit -m "Auto-deploy: %date% %time%" 2>nul
git push origin main 2>nul || echo ⚠️ Git push failed or no changes to push

REM --- Step 3: Install Client Dependencies ---
echo 📦 Installing client dependencies...
cd /d "%CLIENT_DIR%"
if not exist "node_modules" (
  echo    Installing dependencies...
  call npm install --legacy-peer-deps
  if %errorlevel% neq 0 (
    echo ❌ Client dependencies installation failed
    exit /b 1
  )
) else (
  echo    Dependencies already installed
)

REM --- Step 4: Build React Frontend ---
echo 🏗️ Building React frontend...
cd /d "%CLIENT_DIR%"

REM Set environment variables for build
set NODE_ENV=production
set GENERATE_SOURCEMAP=false
set REACT_APP_TINYMCE_API_KEY=%TINYMCE_API_KEY%

REM Build React app
call npm run build
if %errorlevel% neq 0 (
  echo ❌ React build failed
  exit /b 1
)

echo ✅ React build successful

REM --- Step 5: Deploy Frontend to cPanel ---
echo 📤 Deploying frontend to cPanel...
if not exist "%BUILD_DIR%" (
  echo ❌ Build directory not found: %BUILD_DIR%
  exit /b 1
)

REM Use WSL bash for rsync (if available)
where bash >nul 2>&1
if %errorlevel% equ 0 (
  echo    Using WSL bash for rsync...
  bash -c "rsync -avz --progress --delete --exclude='node_modules/' --exclude='.git/' --exclude='.env' --exclude='*.map' --exclude='.DS_Store' --include='.htaccess' -e 'ssh -i %PRIVATE_KEY% -p %CPANEL_PORT%' '%BUILD_DIR%/' %CPANEL_USER%@%CPANEL_HOST%:%FRONTEND_DIR%/"
) else (
  echo    ⚠️ bash/rsync not found - please deploy frontend manually
  echo    Or install WSL and rsync
)

if %errorlevel% neq 0 (
  echo ❌ Frontend deployment failed
  exit /b 1
)

echo ✅ Frontend deployed successfully

REM --- Step 6: Deploy Backend to cPanel ---
echo 📤 Deploying backend to cPanel...
cd /d "%PROJECT_ROOT%"

REM Use WSL bash for rsync
where bash >nul 2>&1
if %errorlevel% equ 0 (
  echo    Using WSL bash for rsync...
  bash -c "rsync -avz --progress --exclude='client/' --exclude='node_modules/' --exclude='.git/' --exclude='backups/' --exclude='logs/' --exclude='*.log' --exclude='.env' --exclude='*.md' --exclude='*.sh' --exclude='*.bat' --exclude='git-filter-repo/' --exclude='database/schema.sql' --include='server.js' --include='server-demo.js' --include='setup.js' --include='package.json' --include='package-lock.json' --include='config/' --include='config/**' --include='routes/' --include='routes/**' --include='database/' --include='database/schema.sql' --exclude='*' -e 'ssh -i %PRIVATE_KEY% -p %CPANEL_PORT%' '%PROJECT_ROOT%/' %CPANEL_USER%@%CPANEL_HOST%:%BACKEND_DIR%"
) else (
  echo    ⚠️ bash/rsync not found - please deploy backend manually
  echo    Or install WSL and rsync
)

if %errorlevel% neq 0 (
  echo ❌ Backend deployment failed
  exit /b 1
)

echo ✅ Backend files deployed successfully

REM --- Step 7: Install Backend Dependencies on Server ---
echo 📦 Installing backend dependencies on server...
echo    ⚠️ Please install dependencies manually in cPanel:
echo    Go to: cPanel → Setup Node.js App → Your App → NPM Install
echo    Or use SSH: cd ~/nodejs && npm install --production

REM --- Step 8: Display Summary ---
echo.
echo =====================================================
echo 🎉 Full Stack Deployment Complete!
echo =====================================================
echo.
echo 📊 Deployment Summary:
echo    ✅ Frontend deployed to: %FRONTEND_DIR%
echo    ✅ Backend deployed to: %BACKEND_DIR%
echo    ✅ Logs saved at: %LOG_FILE%
echo.
echo 📋 Next Steps:
echo.
echo 1. ⚙️  Configure Environment Variables in cPanel:
echo    - Go to: cPanel → Setup Node.js App → Your App
echo    - Add these environment variables:
echo      NODE_ENV=production
echo      PORT=5000
echo      DB_HOST=%REMOTE_DB_HOST%
echo      DB_USER=%REMOTE_DB_USER%
echo      DB_PASSWORD=%REMOTE_DB_PASS%
echo      DB_NAME=%REMOTE_DB_NAME%
echo      JWT_SECRET=your-secret-key-here
echo.
echo 2. 🔄 Restart Node.js App in cPanel:
echo    - Go to: cPanel → Setup Node.js App
echo    - Click: 'Restart App' button
echo.
echo 3. ✅ Test API Endpoints:
echo    - https://theonerupeerevolution.org/api/settings
echo    - https://theonerupeerevolution.org/api/slider
echo    - https://theonerupeerevolution.org/api/gallery
echo.
echo 4. 🧪 Verify Frontend:
echo    - https://theonerupeerevolution.org
echo    - Check browser console (F12) for errors
echo.
echo =====================================================
echo 🚀 Deployment finished at %date% %time%
echo =====================================================
pause

