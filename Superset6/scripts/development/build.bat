@echo off
REM Apache Superset 6.0.0 - ローカル開発環境ビルド（キャッシュあり）
REM Build with cache for local development
REM Supports both Docker Desktop and Podman Desktop

cd /d "%~dp0..\.."

echo ========================================
echo Superset 6.0.0 Local Development Build
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
docker compose --env-file env/.env.local --profile local build

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build completed successfully!
    echo Run 'up.bat' to start the containers.
) else (
    echo.
    echo Build failed! Check the error messages above.
)

pause
