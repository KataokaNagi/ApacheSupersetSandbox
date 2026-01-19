@echo off
REM Apache Superset 6.0.0 - Azure本番環境ビルド（ボリュームなし）
REM Build without volumes for clean start

cd /d "%~dp0..\.."

echo ========================================
echo Superset 6.0.0 Azure Production Clean Build
echo ========================================
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
docker compose --env-file env/.env.azure down -v

echo Building images...
docker compose --env-file env/.env.azure build

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build completed successfully!
    echo Volumes have been removed. Run 'up.bat' to start fresh.
) else (
    echo.
    echo Build failed! Check the error messages above.
)

pause
