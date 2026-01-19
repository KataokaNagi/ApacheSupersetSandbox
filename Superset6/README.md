# Apache Superset 6.0.0 Docker Compose Environment

Apache Superset 6.0.0 の Docker Compose 環境構築です。ローカル開発環境と Azure クラウド環境の両方に対応しています。

## 📋 概要

### 使用技術バージョン（Superset 6.0.0公式準拠）

| コンポーネント | バージョン | 説明 |
|--------------|----------|------|
| Apache Superset | 6.0.0 | BI ダッシュボードツール |
| Python | 3.11.x | Superset ランタイム |
| PostgreSQL | 16-alpine | メタデータデータベース |
| Redis | 7.4-alpine | キャッシュ & メッセージブローカー |
| Celery | 5.x (内蔵) | 非同期タスク処理 |

### サービス構成

```
┌─────────────────────────────────────────────────────────────────┐
│                    Docker Compose Network                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │   Superset   │    │    Redis     │    │  PostgreSQL  │      │
│  │  (Web App)   │◄──►│   (Cache)    │    │  (Metadata)  │      │
│  │   :8088      │    │   :6379      │    │   :5432      │      │
│  └──────┬───────┘    └──────────────┘    └──────────────┘      │
│         │                   ▲                   ▲               │
│         │                   │                   │               │
│  ┌──────▼───────┐    ┌──────┴───────┐          │               │
│  │Celery Worker │◄──►│ Celery Beat  │──────────┘               │
│  │ (Async Task) │    │ (Scheduler)  │                          │
│  └──────────────┘    └──────────────┘                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 クイックスタート

### 前提条件

- Docker Desktop (Windows/Mac) または Docker Engine (Linux)
- Docker Compose v2.x 以上
- 最低 4GB RAM（推奨 8GB 以上）

### ローカル開発環境の起動

```powershell
# 1. 環境変数ファイルのシークレットキーを生成（初回のみ）
openssl rand -base64 42

# 2. env/.env.local の SUPERSET_SECRET_KEY を生成した値で置き換え

# 3. ビルドと起動
cd Superset6\scripts\development
.\build.bat
.\up.bat
```

または PowerShell で直接実行:

```powershell
cd Superset6
docker compose --env-file env/.env.local --profile local up -d --build
```

### アクセス

- **URL**: http://localhost:8088
- **ユーザー名**: admin
- **パスワード**: admin

## 📁 ディレクトリ構造

```
Superset6/
├── compose.yml              # Docker Compose 設定
├── Dockerfile              # カスタム Superset イメージ
├── superset_config.py      # Superset 設定ファイル
├── README.md               # このファイル
├── env/
│   ├── .env.example        # 環境変数テンプレート
│   ├── .env.local          # ローカル開発用設定
│   └── .env.azure          # Azure 本番用設定
└── scripts/
    ├── development/        # 開発環境用スクリプト
    │   ├── build.bat
    │   ├── build-no-cache.bat
    │   ├── build-no-volume.bat
    │   ├── up.bat
    │   └── down.bat
    ├── production/         # 本番環境用スクリプト
    │   └── ...
    └── sandbox/            # サンドボックス用スクリプト
        └── ...
```

## 🔧 環境設定

### ローカル開発環境 (.env.local)

ローカル環境では、PostgreSQL コンテナを `--profile local` オプションで起動します。

主要な設定:
- PostgreSQL: ローカルコンテナ
- Redis: ローカルコンテナ
- サンプルデータ: 読み込みあり
- ログレベル: DEBUG

### Azure 本番環境 (.env.azure)

Azure 環境では、Azure Database for PostgreSQL や Azure Cache for Redis を使用します。

主要な設定:
- PostgreSQL: Azure Database for PostgreSQL
- Redis: ローカルコンテナ または Azure Cache for Redis
- サンプルデータ: 読み込みなし
- ログレベル: INFO

#### Azure Database for PostgreSQL の設定例

```env
DATABASE_USER=superset@your-server
DATABASE_PASSWORD=YourSecurePassword
DATABASE_HOST=your-server.postgres.database.azure.com
DATABASE_PORT=5432
DATABASE_DB=superset
```

## 🔐 セキュリティ設定

### シークレットキーの生成

```bash
# OpenSSL を使用
openssl rand -base64 42

# または Python を使用
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

### 本番環境での推奨設定

1. **強力なシークレットキー**: 42文字以上のランダム文字列
2. **強力な管理者パスワード**: 12文字以上、大小文字・数字・記号を含む
3. **HTTPS の有効化**: `superset_config.py` で `SESSION_COOKIE_SECURE = True`
4. **CORS の制限**: 特定のドメインのみ許可

## 🎯 機能

### Alerts & Reports

Superset 6.0.0 では Playwright がデフォルトで有効になっています。

```python
FEATURE_FLAGS = {
    "ALERT_REPORTS": True,
    "PLAYWRIGHT_REPORTS_AND_THUMBNAILS": True,
}
```

### 日本語対応

デフォルトで日本語が設定されています:

```python
BABEL_DEFAULT_LOCALE = "ja"
LANGUAGES = {
    "ja": {"flag": "jp", "name": "Japanese"},
    "en": {"flag": "us", "name": "English"},
}
```

## 📝 よく使うコマンド

### コンテナ操作

```powershell
# ログ確認
docker compose --env-file env/.env.local logs -f superset

# コンテナ状態確認
docker compose --env-file env/.env.local ps

# コンテナに入る
docker compose --env-file env/.env.local exec superset bash

# Superset CLI の実行
docker compose --env-file env/.env.local exec superset superset --help
```

### データベース操作

```powershell
# データベースマイグレーション
docker compose --env-file env/.env.local exec superset superset db upgrade

# 管理者ユーザー作成
docker compose --env-file env/.env.local exec superset superset fab create-admin

# サンプルデータ読み込み
docker compose --env-file env/.env.local exec superset superset load_examples
```

### トラブルシューティング

```powershell
# すべてのコンテナとボリュームを削除して再構築
docker compose --env-file env/.env.local --profile local down -v
docker compose --env-file env/.env.local --profile local build --no-cache
docker compose --env-file env/.env.local --profile local up -d
```

## 🌐 Azure デプロイ

### Azure Container Instances へのデプロイ

1. Azure Container Registry にイメージをプッシュ
2. Azure Database for PostgreSQL を作成
3. 環境変数を設定
4. Container Instances を作成

### Azure App Service (Container) へのデプロイ

1. Azure Container Registry にイメージをプッシュ
2. App Service Plan を作成
3. Web App for Containers を作成
4. 環境変数を設定

## 📚 参考リンク

- [Apache Superset 公式ドキュメント](https://superset.apache.org/docs/)
- [Superset Docker Compose ガイド](https://superset.apache.org/docs/installation/docker-compose/)
- [Superset Docker ビルドガイド](https://superset.apache.org/docs/installation/docker-builds/)
- [Superset GitHub リポジトリ](https://github.com/apache/superset)

## ⚠️ 注意事項

- この Docker Compose 構成は**開発・テスト目的**で設計されています
- 本番環境では Kubernetes (AKS) の使用を推奨します
- PostgreSQL のデータは Docker ボリュームに保存されます。本番環境では適切なバックアップを設定してください
- シークレットキーは必ず変更してください

## 📄 ライセンス

Apache License 2.0
