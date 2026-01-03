# Apache Superset Sandbox

Apache Superset 5.0をPodman/Dockerで簡単にセットアップするための環境設定ファイル集です。

## 🚀 クイックスタート

### Linux/Mac の場合

```bash
# 環境ファイルをコピー
cp .env.development .env

# コンテナを起動
docker compose --profile with-local-db up -d

# または Podman を使用する場合
podman-compose --profile with-local-db up -d
```

### Windows の場合

```cmd
# quickstart.bat をダブルクリック、または
quickstart.bat
```

**Windows環境の詳細は [WINDOWS.md](WINDOWS.md) をご覧ください**

ブラウザで http://localhost:8088 にアクセス
- ユーザー名: `admin`
- パスワード: `admin`

## 📚 詳細なドキュメント

- **[SETUP.md](SETUP.md)** - 完全なセットアップガイド
- **[WINDOWS.md](WINDOWS.md)** - Windows ユーザー向けガイド
- **[FAQ.md](FAQ.md)** - よくある質問とトラブルシューティング
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - システムアーキテクチャ

## 🌟 機能

- ✅ **Apache Superset 5.0.0** - 最新のBIツール
- ✅ **Redis 8.2系** - 高速キャッシュサーバー
- ✅ **PostgreSQL 16系** - 堅牢なデータベース
- ✅ **日本語対応** - デフォルトで日本語UI
- ✅ **マルチ環境** - 本番/開発/サンドボックス環境に対応
- ✅ **Azure PostgreSQL対応** - 本番環境で外部DB接続可能

## 📦 環境

本リポジトリには3つの環境設定が含まれています：

| 環境 | ポート | 用途 | 環境ファイル |
|------|--------|------|-------------|
| 本番環境 | 8088 | 本番運用（Azure PostgreSQL接続） | `.env.production` |
| 開発環境 | 8088 | 開発作業 | `.env.development` |
| サンドボックス | 8089 | 実験・検証 | `.env.sandbox` |

## 📄 ライセンス

DB, cache DB, and so on are subject to their respective licenses.

- Apache Superset: Apache License 2.0
- Redis: BSD 3-Clause License
- PostgreSQL: PostgreSQL License
