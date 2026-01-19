@echo off
REM Apache Superset 6.0.0 - Sandbox環境停止
REM Stop sandbox/testing environment
REM Supports both Docker Desktop and Podman Desktop

cd /d "%~dp0..\.."

echo ========================================
echo Stopping Superset 6.0.0 Sandbox
echo ========================================

docker compose --env-file env/.env.local --profile local down

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Containers stopped successfully!
) else (
    echo.
    echo Failed to stop containers! Check the error messages above.
)

pause
