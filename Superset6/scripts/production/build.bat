@echo off
REM Apache Superset 6.0.0 - Azure本番環境ビルド
REM Build for Azure production environment

cd /d "%~dp0..\.."

echo ========================================
echo Superset 6.0.0 Azure Production Build
echo ========================================

docker compose --env-file env/.env.azure build

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build completed successfully!
    echo Run 'up.bat' to start the containers.
) else (
    echo.
    echo Build failed! Check the error messages above.
)

pause
