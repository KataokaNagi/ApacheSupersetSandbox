@echo off
chcp 65001 >nul
echo ======================================
echo Apache Superset 開発環境 起動
echo ======================================
echo.

powershell -Command "podman compose --env-file .env.development up -d"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ 開発環境が正常に起動しました
    echo.
    echo アクセスURL: http://localhost:8088
    echo コンテナ名プレフィックス: superset-dev
    echo.
    echo コンテナ状態確認:
    powershell -Command "podman ps --filter 'name=superset-dev'"
) else (
    echo.
    echo ✗ エラーが発生しました
)

echo.
pause
