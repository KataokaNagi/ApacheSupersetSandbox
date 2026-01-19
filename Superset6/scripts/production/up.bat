@echo off
REM Apache Superset 6.0.0 - Azure本番環境起動
REM Start Azure production environment

cd /d "%~dp0..\.."

echo ========================================
echo Starting Superset 6.0.0 Azure Production
echo ========================================
echo.
echo NOTE: Azure production mode uses external PostgreSQL.
echo       Make sure .env.azure is configured correctly.
echo.
echo Services:
echo   - Redis (cache/message broker)
echo   - Superset (web application)
echo   - Celery Worker (async tasks)
echo   - Celery Beat (scheduler)
echo ========================================

docker compose --env-file env/.env.azure up -d

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Containers started successfully!
    echo.
    echo Check logs with: docker compose --env-file env/.env.azure logs -f superset
) else (
    echo.
    echo Failed to start containers! Check the error messages above.
)

pause
