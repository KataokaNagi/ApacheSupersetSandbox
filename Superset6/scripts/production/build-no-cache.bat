@echo off
REM Apache Superset 6.0.0 - Azure本番環境ビルド（キャッシュなし）
REM Build without cache for Azure production
REM Supports both Docker Desktop and Podman Desktop

cd /d "%~dp0..\.."

echo ========================================
echo Superset 6.0.0 Azure Production Build (No Cache)
echo ========================================
echo.
echo Checking container runtime...
echo.

REM Check if Podman is available
podman --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Podman Desktop detected
    
    podman machine inspect podman-machine-default >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        podman machine list | findstr "Running" >nul 2>&1
        if %ERRORLEVEL% NEQ 0 (
            echo [INFO] Starting Podman machine...
            podman machine start
            if %ERRORLEVEL% NEQ 0 (
                echo [ERROR] Failed to start Podman machine!
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
    docker --version >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo [OK] Docker Desktop detected
        docker ps >nul 2>&1
        if %ERRORLEVEL% NEQ 0 (
            echo [ERROR] Docker Desktop is not running!
            pause
            exit /b 1
        )
        set CONTAINER_RUNTIME=docker
        echo [INFO] Using Docker
    ) else (
        echo [ERROR] Neither Docker nor Podman found!
        pause
        exit /b 1
    )
)

echo.
%CONTAINER_RUNTIME% compose --env-file env/.env.azure build --no-cache

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build completed successfully!
    echo.
    echo Starting containers...
    %CONTAINER_RUNTIME% compose --env-file env/.env.azure up -d
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo ========================================
        echo Superset is starting!
        echo ========================================
        echo.
        echo Web UI will be available at:
        echo   http://localhost:8088
        echo.
        echo Default credentials:
        echo   Username: admin
        echo   Password: admin
        echo.
        echo To view logs: %CONTAINER_RUNTIME% compose --env-file env/.env.azure logs -f
        echo To stop:     %CONTAINER_RUNTIME% compose --env-file env/.env.azure down
        echo.
    ) else (
        echo.
        echo Failed to start containers! Check the error messages above.
    )
) else (
    echo.
    echo Build failed! Check the error messages above.
)

pause
