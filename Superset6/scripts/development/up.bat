@echo off
REM Apache Superset 6.0.0 - ローカル開発環境起動
REM Start local development environment
REM Supports both Docker Desktop and Podman Desktop

cd /d "%~dp0..\.."

echo ========================================
echo Starting Superset 6.0.0 Local Development
echo ========================================
echo.
echo Checking container runtime...

REM Check if Podman machine is running (for Podman Desktop)
podman machine inspect podman-machine-default >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Using Podman Desktop
    podman machine list | findstr "Running" >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Starting Podman machine...
        podman machine start
    )
) else (
    echo Using Docker Desktop
)

echo.
echo Services:
echo   - PostgreSQL (metadata database)
echo   - Redis (cache/message broker)
echo   - Superset (web application)
echo   - Celery Worker (async tasks)
echo   - Celery Beat (scheduler)
echo.
echo Access URL: http://localhost:8088
echo Default login: admin / admin
echo ========================================

docker compose --env-file env/.env.local --profile local up -d

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Containers started successfully!
    echo.
    echo Waiting for initialization (this may take a few minutes)...
    echo Check logs with: docker compose --env-file env/.env.local logs -f superset
    echo.
    echo Access Superset at: http://localhost:8088
) else (
    echo.
    echo Failed to start containers! Check the error messages above.
)

pause
