@echo off
chcp 65001 >nul
echo ======================================
echo Apache Superset サンドボックス環境 起動
echo ======================================
echo.

powershell -Command "podman compose --env-file .env.sandbox up -d"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ サンドボックス環境が正常に起動しました
    echo.
    echo アクセスURL: http://localhost:8089
    echo コンテナ名プレフィックス: superset-sandbox
    echo.
    echo コンテナ状態確認:
    powershell -Command "podman ps --filter 'name=superset-sandbox'"
) else (
    echo.
    echo ✗ エラーが発生しました
)

echo.
pause
