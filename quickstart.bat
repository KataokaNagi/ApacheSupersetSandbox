@echo off
REM Quick Start Script for Apache Superset (Windows)
REM Apache Supersetクイックスタートスクリプト (Windows版)

echo =================================================
echo Apache Superset クイックスタート
echo =================================================
echo.

REM Check if docker is available
where docker >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ エラー: Dockerがインストールされていません
    echo Error: Docker is not installed
    pause
    exit /b 1
)

echo ✅ コンテナランタイム: Docker
echo.

REM Select environment
echo 環境を選択してください / Select environment:
echo 1^) 開発環境 (Development) - ポート 8088
echo 2^) サンドボックス環境 (Sandbox) - ポート 8089
echo 3^) 本番環境 (Production) - ポート 8088 (Azure PostgreSQL)
echo.
set /p choice="選択 (1-3): "

if "%choice%"=="1" (
    set ENV_FILE=.env.development
    set PROFILE=--profile with-local-db
    set ENV_NAME=開発環境 (Development)
    set PORT=8088
) else if "%choice%"=="2" (
    set ENV_FILE=.env.sandbox
    set PROFILE=--profile with-local-db
    set ENV_NAME=サンドボックス環境 (Sandbox)
    set PORT=8089
) else if "%choice%"=="3" (
    set ENV_FILE=.env.production
    set PROFILE=
    set ENV_NAME=本番環境 (Production)
    set PORT=8088
    echo.
    echo ⚠️  本番環境を選択しました
    echo ⚠️  Azure PostgreSQLの設定が必要です
    echo ⚠️  .env.production ファイルを編集してください
    echo.
    set /p confirmed="設定は完了していますか？ (yes/no): "
    if not "!confirmed!"=="yes" (
        echo 設定を完了してから再度実行してください
        pause
        exit /b 0
    )
) else (
    echo 無効な選択です
    pause
    exit /b 1
)

echo.
echo 選択された環境: %ENV_NAME%
echo ポート番号: %PORT%
echo.

REM Copy environment file
if not exist .env (
    echo 📝 環境ファイルをコピーしています...
    copy "%ENV_FILE%" .env >nul
    echo ✅ .env ファイルを作成しました
) else (
    echo ⚠️  .env ファイルが既に存在します
    set /p overwrite="上書きしますか？ (yes/no): "
    if "!overwrite!"=="yes" (
        copy /Y "%ENV_FILE%" .env >nul
        echo ✅ .env ファイルを更新しました
    )
)

echo.
echo 🔨 コンテナをビルドしています...
docker-compose --env-file "%ENV_FILE%" build

echo.
echo 🚀 コンテナを起動しています...
docker-compose --env-file "%ENV_FILE%" %PROFILE% up -d

echo.
echo ⏳ サービスの起動を待っています...
timeout /t 5 /nobreak >nul

echo.
echo =================================================
echo ✅ セットアップ完了！
echo =================================================
echo.
echo アクセス先: http://localhost:%PORT%
echo ユーザー名: admin
if "%choice%"=="3" (
    echo パスワード: (.env.production で設定)
) else (
    echo パスワード: admin
)
echo.
echo ログの確認:
echo   docker-compose --env-file %ENV_FILE% logs -f
echo.
echo 停止方法:
echo   docker-compose --env-file %ENV_FILE% down
echo.
echo 完全削除（データも削除）:
echo   docker-compose --env-file %ENV_FILE% down -v
echo =================================================
pause
