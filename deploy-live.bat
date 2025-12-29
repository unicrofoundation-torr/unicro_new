@echo off
echo =====================================================
echo 🚀 Starting Live Deployment (via WSL)
echo =====================================================
echo.

REM Convert Windows path to WSL path
REM E:\kanishk data\projects\UNICRO -> /mnt/e/kanishk data/projects/UNICRO
set "WSL_PATH=/mnt/e/kanishk data/projects/UNICRO"

echo 📁 Project Path: %WSL_PATH%
echo.

REM Run the deployment script in WSL
wsl bash -c "cd '%WSL_PATH%' && chmod +x deploy-live.sh && ./deploy-live.sh"

if %errorlevel% neq 0 (
    echo.
    echo ❌ Deployment failed!
    pause
    exit /b 1
)

echo.
echo ✅ Deployment completed!
pause






