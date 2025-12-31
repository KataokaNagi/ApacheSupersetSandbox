# Architecture Documentation / アーキテクチャドキュメント

## システム構成図

```
┌─────────────────────────────────────────────────────────────┐
│                     Host Machine / ホストマシン                 │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Environment: Production / 本番環境                      │  │
│  │  Port: 8088 (Superset), 6379 (Redis)                 │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │  ┌──────────────┐    ┌──────────────┐               │  │
│  │  │  Superset    │───▶│   Redis      │               │  │
│  │  │  superset-   │    │  superset-   │               │  │
│  │  │  prod        │    │  redis-prod  │               │  │
│  │  └──────┬───────┘    └──────────────┘               │  │
│  │         │                                            │  │
│  │         │ (External Connection)                      │  │
│  │         ▼                                            │  │
│  │  ┌──────────────────────────────┐                   │  │
│  │  │  Azure PostgreSQL            │                   │  │
│  │  │  (External Cloud Service)    │                   │  │
│  │  └──────────────────────────────┘                   │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Environment: Development / 開発環境                    │  │
│  │  Port: 8088 (Superset), 6379 (Redis), 5432 (PG)     │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │  ┌──────────────┐    ┌──────────────┐               │  │
│  │  │  Superset    │───▶│   Redis      │               │  │
│  │  │  superset-   │    │  superset-   │               │  │
│  │  │  dev         │    │  redis-dev   │               │  │
│  │  └──────┬───────┘    └──────────────┘               │  │
│  │         │                                            │  │
│  │         ▼                                            │  │
│  │  ┌──────────────┐                                   │  │
│  │  │  PostgreSQL  │                                   │  │
│  │  │  superset-   │                                   │  │
│  │  │  postgres-   │                                   │  │
│  │  │  dev         │                                   │  │
│  │  └──────────────┘                                   │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Environment: Sandbox / サンドボックス環境              │  │
│  │  Port: 8089 (Superset), 6380 (Redis), 5433 (PG)     │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │  ┌──────────────┐    ┌──────────────┐               │  │
│  │  │  Superset    │───▶│   Redis      │               │  │
│  │  │  superset-   │    │  superset-   │               │  │
│  │  │  sandbox     │    │  redis-      │               │  │
│  │  └──────┬───────┘    │  sandbox     │               │  │
│  │         │            └──────────────┘               │  │
│  │         ▼                                            │  │
│  │  ┌──────────────┐                                   │  │
│  │  │  PostgreSQL  │                                   │  │
│  │  │  superset-   │                                   │  │
│  │  │  postgres-   │                                   │  │
│  │  │  sandbox     │                                   │  │
│  │  └──────────────┘                                   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## コンポーネント詳細

### 1. Apache Superset
- **バージョン**: 5.0.0
- **役割**: BIツール / データビジュアライゼーション
- **言語設定**: 日本語デフォルト、英語切り替え可能
- **ポート**: 8088 (本番/開発), 8089 (サンドボックス)

#### 主な機能
- ダッシュボード作成
- チャート作成
- SQL Lab
- データベース接続管理
- ユーザー管理

### 2. Redis
- **バージョン**: 8.2系 (Alpine)
- **役割**: キャッシュサーバー、セッションストア、Celeryブローカー
- **ポート**: 6379 (本番/開発), 6380 (サンドボックス)

#### 使用用途
- ページキャッシュ (DB: 1)
- Celeryタスクキュー (DB: 0)
- サムネイルキャッシュ (DB: 2)
- クエリ結果キャッシュ (DB: 3)

### 3. PostgreSQL
- **バージョン**: 16系 (Alpine)
- **役割**: Supersetメタデータストア
- **ポート**: 5432 (開発), 5433 (サンドボックス)
- **注意**: 本番環境では外部Azure PostgreSQLを使用

#### データベース内容
- Supersetの設定情報
- ユーザー情報
- ダッシュボード定義
- チャート定義
- データソース接続情報

## ネットワーク構成

### ネットワーク名
- 本番環境: `superset-network-prod`
- 開発環境: `superset-network-dev`
- サンドボックス: `superset-network-sandbox`

### コンテナ間通信
```
Superset Container
  ├─▶ Redis Container (redis:6379)
  └─▶ PostgreSQL Container (postgres:5432) または Azure PostgreSQL
```

## データ永続化

### ボリューム構成

#### 本番環境
```
superset-redis-data-prod     → Redis データ
superset-home-prod           → Superset ホームディレクトリ
```

#### 開発環境
```
superset-redis-data-dev      → Redis データ
superset-postgres-data-dev   → PostgreSQL データ
superset-home-dev            → Superset ホームディレクトリ
```

#### サンドボックス環境
```
superset-redis-data-sandbox    → Redis データ
superset-postgres-data-sandbox → PostgreSQL データ
superset-home-sandbox          → Superset ホームディレクトリ
```

### データ保存内容

#### Redis Data
- キャッシュされたクエリ結果
- セッション情報
- Celeryタスク情報

#### PostgreSQL Data
- 全てのSupersetメタデータ
- ユーザーアカウント情報
- ダッシュボード/チャート設定

#### Superset Home
- ログファイル
- 一時ファイル
- アップロードされたファイル

## セキュリティ構成

### 認証
- デフォルト: データベース認証 (AUTH_DB)
- 拡張可能: LDAP, OAuth, OpenIDなど

### ネットワークセキュリティ
- 各環境は独立したDockerネットワーク内で動作
- コンテナ間通信はネットワーク内でのみ許可
- ホストマシンからは指定ポートでのみアクセス可能

### データセキュリティ
- SECRET_KEY: 環境変数で管理
- データベースパスワード: 環境変数で管理
- 本番環境: 必ず強力なパスワードを設定

## 環境分離戦略

### 完全分離の実現

各環境は以下の要素で完全に分離されています：

1. **コンテナ名**: 異なるコンテナ名で識別
2. **ネットワーク**: 独立したDockerネットワーク
3. **ボリューム**: 独立したデータボリューム
4. **ポート**: 異なるホストポート番号

### 同時実行

開発環境とサンドボックス環境は、異なるポート番号を使用するため同時に実行可能です。

```bash
# 両方を同時に起動
docker compose --env-file .env.development --profile with-local-db up -d
docker compose --env-file .env.sandbox --profile with-local-db up -d

# 開発環境: http://localhost:8088
# サンドボックス: http://localhost:8089
```

## 起動シーケンス

### 1. Redis起動
```
Redis Container Start
  → Health Check (redis-cli ping)
  → Ready
```

### 2. PostgreSQL起動（開発/サンドボックスのみ）
```
PostgreSQL Container Start
  → Initialize Database
  → Health Check (pg_isready)
  → Ready
```

### 3. Superset起動
```
Superset Container Start
  → Wait for Database Connection
  → Database Migration (superset db upgrade)
  → Create Admin User
  → Initialize Superset (superset init)
  → Load Examples (開発/サンドボックスのみ)
  → Start Web Server
  → Health Check (/health endpoint)
  → Ready
```

## 設定ファイル構成

```
ApacheSupersetSandbox/
├── docker-compose.yml          # メインの構成ファイル
├── .env.production            # 本番環境設定
├── .env.development           # 開発環境設定
├── .env.sandbox               # サンドボックス環境設定
├── .env.example               # テンプレート
├── superset/
│   ├── Dockerfile             # カスタムSupersetイメージ
│   ├── superset_config.py     # Superset設定
│   └── docker-init.sh         # 初期化スクリプト
├── Makefile                   # 便利なコマンド集
├── quickstart.sh              # クイックスタート（Linux/Mac）
└── quickstart.bat             # クイックスタート（Windows）
```

## 拡張性

### 水平スケーリング

複数のSupersetインスタンスを起動してロードバランサーを配置可能：

```yaml
superset-1:
  # 設定...
superset-2:
  # 設定...
load-balancer:
  # Nginx等
```

### 追加サービス

Celeryワーカーやビートを追加してバックグラウンドジョブを実行可能：

```yaml
superset-worker:
  # Celeryワーカー設定
superset-beat:
  # Celeryビート設定
```

## モニタリング

### ヘルスチェック

各コンテナには適切なヘルスチェックが設定されています：

- **Redis**: `redis-cli ping`
- **PostgreSQL**: `pg_isready -U superset`
- **Superset**: `curl -f http://localhost:8088/health`

### ログ

```bash
# リアルタイムログ表示
docker compose --env-file .env.development logs -f

# 特定サービスのログ
docker compose --env-file .env.development logs -f superset
```

## トラブルシューティング

### ポート競合

複数環境を同時実行する場合、ポート番号の重複に注意：

- 本番と開発は同じポート（8088）を使用
- サンドボックスは異なるポート（8089）を使用

### データベース接続

本番環境でAzure PostgreSQLに接続する場合：

1. ファイアウォール設定の確認
2. SSL接続が有効であることの確認
3. 接続文字列の正確性確認

### リソース不足

各環境は独立したコンテナとボリュームを使用するため、ディスク容量とメモリに注意：

```bash
# ディスク使用量確認
docker system df

# 不要なリソースのクリーンアップ
docker system prune -a
```

## ベストプラクティス

1. **本番環境では必ず強力なSECRET_KEYを設定**
2. **定期的なバックアップの実施**
3. **ログの定期的な確認**
4. **不要な環境は停止してリソース節約**
5. **セキュリティアップデートの適用**

## 参考リンク

- [Apache Superset Documentation](https://superset.apache.org/docs/intro)
- [Redis Documentation](https://redis.io/documentation)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
