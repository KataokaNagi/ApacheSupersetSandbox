@echo off
REM Apache Superset 6.0.0 - Sandbox環境ビルド（キャッシュなし）
REM Build without cache for sandbox

cd /d "%~dp0..\.."

echo ========================================
echo Superset 6.0.0 Sandbox Build (No Cache)
echo ========================================

docker compose --env-file env/.env.local --profile local build --no-cache

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build completed successfully!
    echo Run 'up.bat' to start the containers.
) else (
    echo.
    echo Build failed! Check the error messages above.
)

pause
