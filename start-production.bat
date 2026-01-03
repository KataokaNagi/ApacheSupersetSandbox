@echo off
chcp 65001 >nul
echo ======================================
echo Apache Superset 本番環境 起動
echo ======================================
echo.

powershell -Command "podman compose --env-file .env.production up -d"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ 本番環境が正常に起動しました
    echo.
    echo アクセスURL: http://localhost:8088
    echo コンテナ名プレフィックス: superset-prod
    echo.
    echo コンテナ状態確認:
    powershell -Command "podman ps --filter 'name=superset-prod'"
) else (
    echo.
    echo ✗ エラーが発生しました
)

echo.
pause
