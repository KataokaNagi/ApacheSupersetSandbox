# Changelog / 変更履歴

All notable changes to this project will be documented in this file.

このプロジェクトの全ての重要な変更はこのファイルに記録されます。

## [1.0.1] - 2026-01-03

### Fixed / 修正
- Windows環境でquickstart.batが正しく動作しない問題を修正
  - Docker Desktop / Podman Desktop の両方に対応
  - `docker compose` (スペース区切り) と `docker-compose` (ハイフン) の両方に対応
  - Podman Desktop使用時の `podman-compose` に対応
  - より詳細なエラーメッセージを追加
  - ビルドと起動の失敗時に適切なエラーハンドリングを追加

### Added / 追加
- `WINDOWS.md`: Windows ユーザー向けの詳細なセットアップガイドを追加
- FAQ.md に Windows環境でのトラブルシューティングセクションを追加
- README.md に Windows向けクイックスタート手順を追加

## [1.0.0] - 2024-12-31

### Added / 追加
- Apache Superset 5.0.0 対応
- Redis 8.2系 サポート
- PostgreSQL 16系 サポート
- 3つの独立した環境（本番/開発/サンドボックス）
- 日本語UI対応（デフォルト）
- 英語/日本語切り替え機能
- Azure PostgreSQL接続対応（本番環境）
- 環境ごとの独立したコンテナ名とボリューム
- サンドボックス環境のポート番号をデフォルト+1に設定
- Podman/Docker両対応

### Configuration Files / 設定ファイル
- `docker-compose.yml`: メインの構成ファイル
- `.env.production`: 本番環境設定（Azure PostgreSQL接続）
- `.env.development`: 開発環境設定（ローカルPostgreSQL）
- `.env.sandbox`: サンドボックス環境設定（ポート+1）
- `.env.example`: 環境設定テンプレート
- `superset/Dockerfile`: カスタムSupersetイメージ（日本語ロケール対応）
- `superset/superset_config.py`: Superset設定（日本語デフォルト）
- `superset/docker-init.sh`: 初期化スクリプト

### Documentation / ドキュメント
- `README.md`: プロジェクト概要とクイックスタート
- `SETUP.md`: 詳細なセットアップガイド（日本語）
- `ARCHITECTURE.md`: システムアーキテクチャドキュメント
- `TESTING.md`: テストガイド
- `FAQ.md`: よくある質問
- `CHANGELOG.md`: 変更履歴（このファイル）

### Scripts / スクリプト
- `Makefile`: 環境管理用コマンド集
- `quickstart.sh`: クイックスタートスクリプト（Linux/Mac）
- `quickstart.bat`: クイックスタートスクリプト（Windows）

### Features / 機能
- ヘルスチェック機能（全サービス）
- データ永続化（ボリューム管理）
- 環境分離（独立したネットワークとボリューム）
- サンプルデータ自動ロード（開発/サンドボックス環境）
- 管理者ユーザー自動作成
- データベース自動初期化
- SSL接続サポート（Azure PostgreSQL）
- Redis複数DB使用（キャッシュ/Celery/サムネイル/結果）

### Security / セキュリティ
- 環境変数による機密情報管理
- SECRET_KEY設定
- データベースパスワード保護
- Azure PostgreSQL SSL接続対応

### Technical Details / 技術詳細
- **Superset Version**: 5.0.0
- **Redis Version**: 8.2-alpine
- **PostgreSQL Version**: 16-alpine
- **Default Locale**: ja_JP.UTF-8
- **Supported Languages**: Japanese (ja), English (en)
- **Container Runtime**: Docker/Podman compatible

### Port Mappings / ポートマッピング

#### Production / 本番環境
- Superset: 8088
- Redis: 6379
- PostgreSQL: External (Azure)

#### Development / 開発環境
- Superset: 8088
- Redis: 6379
- PostgreSQL: 5432

#### Sandbox / サンドボックス環境
- Superset: 8089 (+1)
- Redis: 6380 (+1)
- PostgreSQL: 5433 (+1)

### Known Issues / 既知の問題
- なし（初回リリース）

### Migration Notes / 移行ノート
- 初回リリースのため移行は不要

---

## [Unreleased] / 未リリース

### Planned / 計画中
- Celeryワーカー構成の追加
- Nginx リバースプロキシ設定例
- Kubernetes (K8s) 対応
- 監視ツール統合（Prometheus/Grafana）
- バックアップ自動化スクリプト

---

## Release Notes Format / リリースノート形式

このCHANGELOGは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) 形式に従い、
[Semantic Versioning](https://semver.org/lang/ja/) を使用しています。

### Categories / カテゴリ
- **Added / 追加**: 新機能
- **Changed / 変更**: 既存機能の変更
- **Deprecated / 非推奨**: 将来削除される機能
- **Removed / 削除**: 削除された機能
- **Fixed / 修正**: バグ修正
- **Security / セキュリティ**: 脆弱性対応
