@echo off
setlocal enabledelayedexpansion
REM Quick Start Script for Apache Superset (Windows)
REM Apache Supersetクイックスタートスクリプト (Windows版)

echo =================================================
echo Apache Superset クイックスタート
echo =================================================
echo.

REM Detect available container runtime and compose command
set CONTAINER_CMD=
set COMPOSE_CMD=

REM Check for Docker
where docker >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set CONTAINER_CMD=docker
    REM Try docker compose (modern Docker Desktop)
    docker compose version >nul 2>nul
    if !ERRORLEVEL! EQU 0 (
        set COMPOSE_CMD=docker compose
    ) else (
        REM Try docker-compose (legacy)
        where docker-compose >nul 2>nul
        if !ERRORLEVEL! EQU 0 (
            set COMPOSE_CMD=docker-compose
        )
    )
)

REM Check for Podman if Docker not found
if "!CONTAINER_CMD!"=="" (
    where podman >nul 2>nul
    if !ERRORLEVEL! EQU 0 (
        set CONTAINER_CMD=podman
        REM Try podman compose
        podman compose version >nul 2>nul
        if !ERRORLEVEL! EQU 0 (
            set COMPOSE_CMD=podman compose
        ) else (
            REM Try podman-compose
            where podman-compose >nul 2>nul
            if !ERRORLEVEL! EQU 0 (
                set COMPOSE_CMD=podman-compose
            )
        )
    )
)

REM Verify we found something
if "!CONTAINER_CMD!"=="" (
    echo ❌ エラー: DockerまたはPodmanがインストールされていません
    echo Error: Docker or Podman is not installed
    echo.
    echo Docker Desktop: https://www.docker.com/products/docker-desktop
    echo Podman Desktop: https://podman-desktop.io/
    pause
    exit /b 1
)

if "!COMPOSE_CMD!"=="" (
    echo ❌ エラー: Compose コマンドが見つかりません
    echo Error: Compose command not found
    echo.
    echo Docker Desktop の場合は "docker compose" が含まれています
    echo Podman の場合は "pip install podman-compose" を実行してください
    pause
    exit /b 1
)

echo ✅ コンテナランタイム: !CONTAINER_CMD!
echo ✅ Compose コマンド: !COMPOSE_CMD!
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
!COMPOSE_CMD! --env-file "!ENV_FILE!" build
if !ERRORLEVEL! NEQ 0 (
    echo ❌ エラー: ビルドに失敗しました
    echo Error: Build failed
    pause
    exit /b 1
)

echo.
echo 🚀 コンテナを起動しています...
if "!PROFILE!"=="" (
    !COMPOSE_CMD! --env-file "!ENV_FILE!" up -d
) else (
    !COMPOSE_CMD! --env-file "!ENV_FILE!" !PROFILE! up -d
)
if !ERRORLEVEL! NEQ 0 (
    echo ❌ エラー: コンテナの起動に失敗しました
    echo Error: Failed to start containers
    echo.
    echo ログを確認してください:
    echo   !COMPOSE_CMD! --env-file !ENV_FILE! logs
    pause
    exit /b 1
)

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
echo   !COMPOSE_CMD! --env-file !ENV_FILE! logs -f
echo.
echo 停止方法:
echo   !COMPOSE_CMD! --env-file !ENV_FILE! down
echo.
echo 完全削除（データも削除）:
echo   !COMPOSE_CMD! --env-file !ENV_FILE! down -v
echo =================================================
pause
