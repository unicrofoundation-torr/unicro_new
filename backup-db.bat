@echo off
setlocal ENABLEDELAYEDEXPANSION

:: ============================================
:: MySQL Backup Script (no recursion!)
:: ============================================

set "DB_NAME=charity_website"
set "DB_USER=root"
set "DB_PASS=root123"
set "BACKUP_DIR=E:\kanishk data\projects\UNICRO\backups"

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

for /f "tokens=1-4 delims=/ " %%a in ("%date%") do set today=%%a-%%b-%%c
for /f "tokens=1-2 delims=: " %%a in ("%time%") do set now=%%a-%%b
set "BACKUP_FILE=%BACKUP_DIR%\%DB_NAME%_%today%_%now%.sql"

echo Creating MySQL backup file: %BACKUP_FILE%
mysqldump -u %DB_USER% -p%DB_PASS% %DB_NAME% > "%BACKUP_FILE%"

if %errorlevel% neq 0 (
    echo ❌ MySQL backup failed!
    exit /b 1
)

echo ✅ MySQL backup successful!
exit /b 0
