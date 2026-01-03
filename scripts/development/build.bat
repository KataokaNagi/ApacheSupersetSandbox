@echo off
chcp 65001 >nul
echo ======================================
echo Apache Superset 開発環境 ビルド＆起動
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
    powershell -Command "podman machine start"
    if %ERRORLEVEL% NEQ 0 (
        echo ✗ Podman マシンの起動に失敗しました
        pause
        exit /b 1
    )
    echo ✓ Podman マシンが起動しました
    timeout /t 3 /nobreak >nul
) else (
    echo ✓ Podman マシンは既に起動しています
)
echo.

echo イメージをビルドしています...
powershell -Command "podman compose --env-file ..\..\env\.env.development build"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ✗ ビルドに失敗しました
    pause
    exit /b 1
)
echo.

echo コンテナを起動しています...
powershell -Command "podman compose --env-file ..\..\env\.env.development up -d"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ 開発環境が正常にビルド＆起動しました
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
