@echo off
setlocal ENABLEDELAYEDEXPANSION

:: ============================================
:: CONFIGURATION
:: ============================================
set "PROJECT_DIR=E:\kanishk data\projects\UNICRO"
set "LOG_DIR=%PROJECT_DIR%\logs"
set "PEM_PATH=C:\Users\KanishkRajSinghDodiy\Downloads\key_private"
set "CPANEL_USER=theomkiq"
set "SERVER=server357.web-hosting.com"
set "PORT=21098"

:: ============================================
:: CREATE LOG FILE
:: ============================================
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
for /f "tokens=1-4 delims=/ " %%a in ("%date%") do set today=%%a-%%b-%%c
for /f "tokens=1-2 delims=: " %%a in ("%time%") do set now=%%a-%%b
set "LOG_FILE=%LOG_DIR%\deploy_%today%_%now%.log"

echo ===================================================== >> "%LOG_FILE%"
echo 🚀 Deployment started at %date% %time% >> "%LOG_FILE%"
echo ===================================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo ===============================
echo 🚀 Starting Deployment Process
echo ===============================
echo.

:: ============================================
:: STEP 1: MYSQL BACKUP
:: ============================================
echo 💾 Taking MySQL Backup...
echo 💾 Taking MySQL Backup... >> "%LOG_FILE%"
call "%PROJECT_DIR%\backup-db.bat" >> "%LOG_FILE%" 2>&1
if %errorlevel% neq 0 (
    echo ❌ Backup failed! Aborting.
    echo ❌ Backup failed! Aborting. >> "%LOG_FILE%"
    pause
    exit /b 1
)
echo ✅ Backup successful!
echo ✅ Backup successful! >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

:: ============================================
:: STEP 2: PUSH CODE TO GITHUB
:: ============================================
echo 📦 Pushing latest code to GitHub...
echo 📦 Pushing latest code to GitHub... >> "%LOG_FILE%"
cd /d "%PROJECT_DIR%"
git add . >> "%LOG_FILE%" 2>&1
git commit -m "Auto-deploy: %date% %time%" >> "%LOG_FILE%" 2>&1
git push origin main >> "%LOG_FILE%" 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git push failed! Aborting.
    echo ❌ Git push failed! Aborting. >> "%LOG_FILE%"
    pause
    exit /b 1
)
echo ✅ GitHub push successful!
echo ✅ GitHub push successful! >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

:: ============================================
:: STEP 3: DEPLOY TO CPANEL USING RSYNC
:: ============================================
echo 🌐 Uploading to cPanel using rsync...
echo 🌐 Uploading to cPanel using rsync... >> "%LOG_FILE%"

rsync -avz -e "ssh -p %PORT% -i \"%PEM_PATH%\"" "%PROJECT_DIR%\src/" %CPANEL_USER%@%SERVER%:~/public_html/ >> "%LOG_FILE%" 2>&1

if %errorlevel% neq 0 (
    echo ❌ Deployment failed!
    echo ❌ Deployment failed! >> "%LOG_FILE%"
    pause
    exit /b 1
)
echo ✅ Deployment successful!
echo ✅ Deployment successful! >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

:: ============================================
:: FINISH
:: ============================================
echo ===================================================== >> "%LOG_FILE%"
echo ✅ Deployment completed successfully at %date% %time% >> "%LOG_FILE%"
echo ===================================================== >> "%LOG_FILE%"
echo Log saved at: "%LOG_FILE%"
echo 🎉 All done! Backup + Deployment completed.
pause
exit /b
