@echo off
REM Apache Superset 6.0.0 - Sandbox環境ビルド（ボリュームなし）
REM Build without volumes for clean start
REM Supports both Docker Desktop and Podman Desktop

cd /d "%~dp0..\.."

echo ========================================
echo Superset 6.0.0 Sandbox Clean Build
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
echo WARNING: This will remove all volumes (data will be lost)!
echo.
set /p confirm="Are you sure? (y/N): "
if /i not "%confirm%"=="y" (
    echo Cancelled.
    pause
    exit /b 0
)

echo Stopping containers...
docker compose --env-file env/.env.local --profile local down -v

echo Building images...
docker compose --env-file env/.env.local --profile local build

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build completed successfully!
    echo Volumes have been removed. Run 'up.bat' to start fresh.
) else (
    echo.
    echo Build failed! Check the error messages above.
)

pause
