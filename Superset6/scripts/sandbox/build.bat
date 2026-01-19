@echo off
REM Apache Superset 6.0.0 - Sandbox環境ビルド
REM Build for sandbox/testing environment

cd /d "%~dp0..\.."

echo ========================================
echo Superset 6.0.0 Sandbox Build
echo ========================================

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
