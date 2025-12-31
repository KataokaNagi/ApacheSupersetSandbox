# Testing Guide / テストガイド

このドキュメントでは、Apache Superset環境のテスト方法について説明します。

## 🧪 基本的な動作確認

### 1. 設定ファイルの検証

```bash
# docker-compose.ymlの検証
docker compose --env-file .env.development config

# 特定の環境の設定を確認
docker compose --env-file .env.production config
docker compose --env-file .env.sandbox config
```

### 2. 開発環境のテスト

```bash
# 環境を起動
docker compose --env-file .env.development --profile with-local-db up -d

# ログを確認
docker compose --env-file .env.development logs -f

# ヘルスチェック
curl http://localhost:8088/health

# ログイン画面にアクセス
curl -I http://localhost:8088/login/

# コンテナの状態確認
docker ps | grep superset-dev

# 停止
docker compose --env-file .env.development down
```

### 3. サンドボックス環境のテスト

```bash
# 環境を起動
docker compose --env-file .env.sandbox --profile with-local-db up -d

# ヘルスチェック（ポート8089）
curl http://localhost:8089/health

# コンテナの状態確認
docker ps | grep superset-sandbox

# 停止
docker compose --env-file .env.sandbox down
```

### 4. 複数環境の同時実行テスト

```bash
# 開発環境とサンドボックス環境を同時に起動
docker compose --env-file .env.development --profile with-local-db up -d
docker compose --env-file .env.sandbox --profile with-local-db up -d

# 両方の環境が起動していることを確認
docker ps | grep superset

# 開発環境にアクセス
curl -I http://localhost:8088/login/

# サンドボックス環境にアクセス
curl -I http://localhost:8089/login/

# 停止
docker compose --env-file .env.development down
docker compose --env-file .env.sandbox down
```

## 🔍 詳細なテスト項目

### データベース接続テスト

```bash
# PostgreSQL接続確認（開発環境）
docker exec superset-postgres-dev psql -U superset -d superset -c "SELECT version();"

# Redis接続確認
docker exec superset-redis-dev redis-cli ping
```

### 日本語化の確認

1. ブラウザで http://localhost:8088 にアクセス
2. ログイン画面が日本語で表示されることを確認
3. ログイン後、UIが日本語で表示されることを確認
4. ユーザー設定から英語に切り替えられることを確認

### サンプルデータの確認（開発/サンドボックス環境）

1. ログイン後、「チャート」メニューを確認
2. サンプルチャートが表示されることを確認
3. 「ダッシュボード」メニューを確認
4. サンプルダッシュボードが表示されることを確認

### パフォーマンステスト

```bash
# Supersetの起動時間を計測
time docker compose --env-file .env.development --profile with-local-db up -d

# ログから起動完了までの時間を確認
docker compose --env-file .env.development logs superset | grep "Starting Superset"
```

## 🔒 セキュリティテスト

### 1. 環境変数の確認

```bash
# 機密情報がハードコードされていないことを確認
grep -r "password.*=" --include="*.py" --include="*.yml" superset/

# SECRET_KEYが適切に設定されていることを確認（本番環境）
grep SUPERSET_SECRET_KEY .env.production
```

### 2. ポート公開の確認

```bash
# 必要なポートのみが公開されていることを確認
docker compose --env-file .env.production config | grep -A 2 "ports:"
```

## 🧹 クリーンアップテスト

```bash
# データを保持しない停止
docker compose --env-file .env.development down

# 再起動してデータが保持されていることを確認
docker compose --env-file .env.development --profile with-local-db up -d

# データの完全削除
docker compose --env-file .env.development down -v

# ボリュームが削除されたことを確認
docker volume ls | grep superset-dev
```

## 📊 期待される結果

### 正常な起動

```
✓ Redis: running, healthy
✓ PostgreSQL: running, healthy (開発/サンドボックス環境のみ)
✓ Superset: running, healthy
✓ http://localhost:8088/health returns 200 OK
✓ http://localhost:8088/login/ returns 200 OK
```

### コンテナ一覧（開発環境）

```bash
$ docker ps --filter "name=superset-dev"
CONTAINER ID   IMAGE                    STATUS                    PORTS                    NAMES
xxxxx          apachesuperset-superset  Up x minutes (healthy)    0.0.0.0:8088->8088/tcp  superset-dev
xxxxx          redis:8.2-alpine         Up x minutes (healthy)    0.0.0.0:6379->6379/tcp  superset-redis-dev
xxxxx          postgres:16-alpine       Up x minutes (healthy)    0.0.0.0:5432->5432/tcp  superset-postgres-dev
```

## 🐛 トラブルシューティング用コマンド

```bash
# コンテナのログを詳細に確認
docker compose --env-file .env.development logs --tail=100 superset

# コンテナ内でシェルを起動
docker exec -it superset-dev /bin/bash

# データベースのテーブル一覧を確認
docker exec superset-postgres-dev psql -U superset -d superset -c "\dt"

# Redisのキー一覧を確認
docker exec superset-redis-dev redis-cli KEYS "*"

# ネットワークの確認
docker network inspect superset-network-dev

# リソース使用状況の確認
docker stats --no-stream | grep superset
```

## 🔄 継続的テスト

### 自動化されたヘルスチェック

```bash
#!/bin/bash
# health-check.sh

echo "Checking Superset health..."

# 最大5分間待機
for i in {1..60}; do
    if curl -sf http://localhost:8088/health > /dev/null; then
        echo "✓ Superset is healthy"
        exit 0
    fi
    echo "Waiting for Superset... ($i/60)"
    sleep 5
done

echo "✗ Superset health check failed"
exit 1
```

## 📝 テストチェックリスト

実装後、以下の項目をチェックしてください：

- [ ] 開発環境が正常に起動する
- [ ] サンドボックス環境が正常に起動する
- [ ] 本番環境設定が正しく読み込まれる
- [ ] 開発環境とサンドボックス環境が同時に実行できる
- [ ] UIが日本語で表示される
- [ ] 英語に切り替えられる
- [ ] サンプルデータがロードされる（開発/サンドボックス）
- [ ] ヘルスチェックが正常に動作する
- [ ] データが永続化される
- [ ] クリーンアップが正常に動作する
- [ ] ログが適切に出力される
- [ ] 環境変数が正しく適用される
