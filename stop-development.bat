@echo off
chcp 65001 >nul
echo ======================================
echo Apache Superset 開発環境 停止
echo ======================================
echo.

powershell -Command "podman compose --env-file env\.env.development down"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ 開発環境が正常に停止しました
) else (
    echo.
    echo ✗ エラーが発生しました
)

echo.
pause
