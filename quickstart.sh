#!/bin/bash
# Quick Start Script for Apache Superset
# Apache Supersetクイックスタートスクリプト

set -e

echo "================================================="
echo "Apache Superset クイックスタート"
echo "================================================="
echo ""

# Check if docker or podman is available
if command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
    COMPOSE_CMD="docker-compose"
elif command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
    COMPOSE_CMD="podman-compose"
else
    echo "❌ エラー: DockerまたはPodmanがインストールされていません"
    echo "Error: Docker or Podman is not installed"
    exit 1
fi

echo "✅ コンテナランタイム: $CONTAINER_CMD"
echo ""

# Select environment
echo "環境を選択してください / Select environment:"
echo "1) 開発環境 (Development) - ポート 8088"
echo "2) サンドボックス環境 (Sandbox) - ポート 8089"
echo "3) 本番環境 (Production) - ポート 8088 (Azure PostgreSQL)"
echo ""
read -p "選択 (1-3): " choice

case $choice in
    1)
        ENV_FILE=".env.development"
        PROFILE="--profile with-local-db"
        ENV_NAME="開発環境 (Development)"
        PORT="8088"
        ;;
    2)
        ENV_FILE=".env.sandbox"
        PROFILE="--profile with-local-db"
        ENV_NAME="サンドボックス環境 (Sandbox)"
        PORT="8089"
        ;;
    3)
        ENV_FILE=".env.production"
        PROFILE=""
        ENV_NAME="本番環境 (Production)"
        PORT="8088"
        echo ""
        echo "⚠️  本番環境を選択しました"
        echo "⚠️  Azure PostgreSQLの設定が必要です"
        echo "⚠️  .env.production ファイルを編集してください"
        echo ""
        read -p "設定は完了していますか？ (yes/no): " confirmed
        if [ "$confirmed" != "yes" ]; then
            echo "設定を完了してから再度実行してください"
            exit 0
        fi
        ;;
    *)
        echo "無効な選択です"
        exit 1
        ;;
esac

echo ""
echo "選択された環境: $ENV_NAME"
echo "ポート番号: $PORT"
echo ""

# Copy environment file
if [ ! -f ".env" ]; then
    echo "📝 環境ファイルをコピーしています..."
    cp "$ENV_FILE" .env
    echo "✅ .env ファイルを作成しました"
else
    echo "⚠️  .env ファイルが既に存在します"
    read -p "上書きしますか？ (yes/no): " overwrite
    if [ "$overwrite" = "yes" ]; then
        cp "$ENV_FILE" .env
        echo "✅ .env ファイルを更新しました"
    fi
fi

echo ""
echo "🔨 コンテナをビルドしています..."
$COMPOSE_CMD --env-file "$ENV_FILE" build

echo ""
echo "🚀 コンテナを起動しています..."
$COMPOSE_CMD --env-file "$ENV_FILE" $PROFILE up -d

echo ""
echo "⏳ サービスの起動を待っています..."
sleep 5

echo ""
echo "================================================="
echo "✅ セットアップ完了！"
echo "================================================="
echo ""
echo "アクセス先: http://localhost:$PORT"
echo "ユーザー名: admin"
if [ "$choice" = "3" ]; then
    echo "パスワード: (.env.production で設定)"
else
    echo "パスワード: admin"
fi
echo ""
echo "ログの確認:"
echo "  $COMPOSE_CMD --env-file $ENV_FILE logs -f"
echo ""
echo "停止方法:"
echo "  $COMPOSE_CMD --env-file $ENV_FILE down"
echo ""
echo "完全削除（データも削除）:"
echo "  $COMPOSE_CMD --env-file $ENV_FILE down -v"
echo "================================================="
