@echo off
chcp 65001 >nul
echo ======================================
echo Apache Superset サンドボックス環境 起動
echo ======================================
echo.

echo Podman マシンの状態を確認中...
powershell -Command "podman machine list" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Podman マシンが見つかりません。初期化しています...
    powershell -Command "podman machine init"
    if %ERRORLEVEL% NEQ 0 (
        echo ✗ Podman マシンの初期化に失敗しました
        pause
        exit /b 1
    )
)

echo Podman マシンの接続を確認中...
powershell -Command "podman ps" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Podman マシンが起動していません。起動しています...
    set "PODMAN_IGNORE_CGROUPSV1_WARNING=1"
    powershell -Command "$env:PODMAN_IGNORE_CGROUPSV1_WARNING='1'; podman machine start 2>&1 | Out-String"
    
    echo 起動後の接続を確認中...
    timeout /t 5 /nobreak >nul
    powershell -Command "podman ps" >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo ✗ Podman マシンの起動に失敗しました
        pause
        exit /b 1
    )
    echo ✓ Podman マシンが起動しました
) else (
    echo ✓ Podman マシンは既に起動しています
)
echo.

powershell -Command "podman compose --env-file env\.env.sandbox up -d"

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
