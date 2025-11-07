@echo off
echo Converting Windows path to WSL path...
set "WIN_PATH=E:\kanishk data\projects\UNICRO"
set "WSL_PATH=/mnt/e/kanishk data/projects/UNICRO"

echo Running deploy_v3.sh in WSL...
wsl bash -c "cd '%WSL_PATH%' && bash deploy_v3.sh"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Deployment failed!
    pause
    exit /b 1
)

echo.
echo Deployment completed successfully!
pause


