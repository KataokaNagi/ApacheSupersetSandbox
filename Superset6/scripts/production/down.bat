@echo off
REM Apache Superset 6.0.0 - Azure本番環境停止
REM Stop Azure production environment

cd /d "%~dp0..\.."

echo ========================================
echo Stopping Superset 6.0.0 Azure Production
echo ========================================

docker compose --env-file env/.env.azure down

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Containers stopped successfully!
) else (
    echo.
    echo Failed to stop containers! Check the error messages above.
)

pause
