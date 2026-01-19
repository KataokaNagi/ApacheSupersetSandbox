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
echo.

REM Check if Podman is available
podman --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Podman Desktop detected
    
    REM Check if Podman machine exists
    podman machine inspect podman-machine-default >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        REM Check if Podman machine is running
        podman machine list | findstr "Running" >nul 2>&1
        if %ERRORLEVEL% NEQ 0 (
            echo [INFO] Starting Podman machine...
            podman machine start
            if %ERRORLEVEL% NEQ 0 (
                echo [ERROR] Failed to start Podman machine!
                echo Please run: podman machine start
                pause
                exit /b 1
            )
        ) else (
            echo [OK] Podman machine is running
        )
    ) else (
        echo [WARNING] Podman machine not found. Creating...
        podman machine init
        podman machine start
    )
    
    set CONTAINER_RUNTIME=podman
    echo [INFO] Using Podman
) else (
    REM Check if Docker is available
    docker --version >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo [OK] Docker Desktop detected
        
        REM Check if Docker daemon is running
        docker ps >nul 2>&1
        if %ERRORLEVEL% NEQ 0 (
            echo [ERROR] Docker Desktop is not running!
            echo Please start Docker Desktop and try again.
            pause
            exit /b 1
        )
        
        set CONTAINER_RUNTIME=docker
        echo [INFO] Using Docker
    ) else (
        echo [ERROR] Neither Docker nor Podman found!
        echo Please install Docker Desktop or Podman Desktop.
        pause
        exit /b 1
    )
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
echo.

%CONTAINER_RUNTIME% compose --env-file env/.env.local --profile local up -d

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
