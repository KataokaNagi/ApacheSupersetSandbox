# Apache Superset Podman環境

Apache Superset 5.0系、Redis 8.2系、PostgreSQL 16系を利用したPodman環境です。

## 環境構成

### 本番環境 (Production)
- **コンテナプレフィックス**: `superset-prod`
- **Supersetポート**: 8088
- **データベース**: 外部Azure PostgreSQL
- **起動コマンド**: `scripts\production\start.bat`
- **停止コマンド**: `scripts\production\stop.bat`

### 開発環境 (Development)
- **コンテナプレフィックス**: `superset-dev`
- **Supersetポート**: 8088
- **データベース**: ローカルPostgreSQL (コンテナ)
- **起動コマンド**: `scripts\development\start.bat`
- **停止コマンド**: `scripts\development\stop.bat`

### 開発サンドボックス環境 (Sandbox)
- **コンテナプレフィックス**: `superset-sandbox`
- **Supersetポート**: 8089
- **データベース**: ローカルPostgreSQL (コンテナ)
- **起動コマンド**: `scripts\sandbox\start.bat`
- **停止コマンド**: `scripts\sandbox\stop.bat`

## 前提条件

- Windows環境
- Podman Desktop インストール済み
- PowerShellが利用可能

## セットアップ手順

### 1. 本番環境の設定

`env\.env.production`ファイルを編集し、以下の項目を変更してください：

```env
# Azure PostgreSQL接続情報
DB_USER=your_postgres_user
DB_PASSWORD=your_postgres_password
DB_HOST=your-azure-postgres.postgres.database.azure.com
DB_PORT=5432
DB_NAME=superset

# 管理者パスワード
ADMIN_PASSWORD=your_secure_admin_password

# セキュリティキー（ランダムな文字列を生成）
SUPERSET_SECRET_KEY=your_random_secret_key_here
```

### 2. 起動方法

各環境の起動用batファイルをダブルクリックで実行：

```cmd
# 本番環境
scripts\production\start.bat

# 開発環境
scripts\development\start.bat

# サンドボックス環境
scripts\sandbox\start.bat
```

### 3. アクセス

起動後、以下のURLでアクセス可能：

- 本番環境: http://localhost:8088
- 開発環境: http://localhost:8088
- サンドボックス環境: http://localhost:8089

### 4. ログイン情報

各環境の`env\.env.*`ファイルで設定した以下の情報でログイン：

- ユーザー名: `admin` (デフォルト)
- パスワード: `env\.env.*`の`ADMIN_PASSWORD`で設定した値

## 言語設定

Supersetは日本語がデフォルト言語として設定されています。

画面右上のユーザーメニューから「日本語」↔「English」を切り替え可能です。

## ファイル構成

```
.
├── compose.yml                 # Podman Compose設定ファイル
├── superset_config.py         # Superset設定ファイル
├── env/                       # 環境変数ディレクトリ
│   ├── .env.production        # 本番環境変数
│   ├── .env.development       # 開発環境変数
│   └── .env.sandbox           # サンドボックス環境変数
└── scripts/                   # 起動・停止スクリプト
    ├── production/
    │   ├── start.bat          # 本番環境起動
    │   └── stop.bat           # 本番環境停止
    ├── development/
    │   ├── start.bat          # 開発環境起動
    │   └── stop.bat           # 開発環境停止
    └── sandbox/
        ├── start.bat          # サンドボックス環境起動
        └── stop.bat           # サンドボックス環境停止
```

## トラブルシューティング

### コンテナが起動しない

```powershell
# コンテナログを確認
podman logs superset-prod-superset
podman logs superset-dev-superset
podman logs superset-sandbox-superset
```

### データベース接続エラー

1. Azure PostgreSQLのファイアウォール設定を確認
2. 接続情報（ホスト名、ユーザー名、パスワード）が正しいか確認
3. PostgreSQLがSSL接続を要求する場合、接続文字列に`?sslmode=require`を追加

### ポートが既に使用されている

他のアプリケーションがポートを使用している場合、`env\.env.*`ファイルの`SUPERSET_PORT`を変更してください。

## メンテナンスコマンド

```powershell
# 全コンテナ確認
podman ps -a

# 特定環境のコンテナのみ確認
podman ps --filter "name=superset-prod"
podman ps --filter "name=superset-dev"
podman ps --filter "name=superset-sandbox"

# ボリューム確認
podman volume ls

# ボリューム削除（データが完全に削除されます）
podman volume rm superset-prod-redis-data
podman volume rm superset-dev-postgres-data
# など
```

## セキュリティ注意事項

⚠️ **本番環境では必ず以下を変更してください:**

1. `env\.env.production`の`SUPERSET_SECRET_KEY`をランダムな文字列に変更
2. `ADMIN_PASSWORD`を強力なパスワードに変更
3. Azure PostgreSQLのパスワードを安全に管理
4. `env\.env.*`ファイルをGitにコミットしない（`.gitignore`に追加済み）

## ライセンス

DB, cache DB, and so on are subject to their respective licenses.
