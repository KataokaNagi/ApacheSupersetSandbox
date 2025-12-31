# Makefile for Apache Superset Podman/Docker Environment Management
# Apache Superset環境管理用Makefile

.PHONY: help production-up production-down development-up development-down sandbox-up sandbox-down \
        production-logs development-logs sandbox-logs production-clean development-clean sandbox-clean \
        build rebuild status

# デフォルトターゲット
help:
	@echo "Apache Superset環境管理コマンド"
	@echo "================================"
	@echo ""
	@echo "環境起動:"
	@echo "  make production-up    - 本番環境を起動（Azure PostgreSQL使用）"
	@echo "  make development-up   - 開発環境を起動"
	@echo "  make sandbox-up       - サンドボックス環境を起動"
	@echo ""
	@echo "環境停止:"
	@echo "  make production-down  - 本番環境を停止"
	@echo "  make development-down - 開発環境を停止"
	@echo "  make sandbox-down     - サンドボックス環境を停止"
	@echo ""
	@echo "ログ確認:"
	@echo "  make production-logs  - 本番環境のログを表示"
	@echo "  make development-logs - 開発環境のログを表示"
	@echo "  make sandbox-logs     - サンドボックス環境のログを表示"
	@echo ""
	@echo "環境クリーンアップ（データ削除）:"
	@echo "  make production-clean  - 本番環境のデータを削除"
	@echo "  make development-clean - 開発環境のデータを削除"
	@echo "  make sandbox-clean     - サンドボックス環境のデータを削除"
	@echo ""
	@echo "その他:"
	@echo "  make build            - Supersetイメージをビルド"
	@echo "  make rebuild          - Supersetイメージを再ビルド（キャッシュなし）"
	@echo "  make status           - 全コンテナの状態を表示"

# 本番環境（Azure PostgreSQL使用）
production-up:
	@echo "本番環境を起動しています..."
	docker-compose --env-file .env.production up -d superset redis

production-down:
	@echo "本番環境を停止しています..."
	docker-compose --env-file .env.production down

production-logs:
	docker-compose --env-file .env.production logs -f

production-clean:
	@echo "本番環境のデータを削除しています..."
	@read -p "本当に削除しますか？ (yes/no): " confirm && [ "$$confirm" = "yes" ]
	docker-compose --env-file .env.production down -v

# 開発環境
development-up:
	@echo "開発環境を起動しています..."
	docker-compose --env-file .env.development --profile with-local-db up -d

development-down:
	@echo "開発環境を停止しています..."
	docker-compose --env-file .env.development down

development-logs:
	docker-compose --env-file .env.development logs -f

development-clean:
	@echo "開発環境のデータを削除しています..."
	@read -p "本当に削除しますか？ (yes/no): " confirm && [ "$$confirm" = "yes" ]
	docker-compose --env-file .env.development down -v

# サンドボックス環境
sandbox-up:
	@echo "サンドボックス環境を起動しています..."
	docker-compose --env-file .env.sandbox --profile with-local-db up -d

sandbox-down:
	@echo "サンドボックス環境を停止しています..."
	docker-compose --env-file .env.sandbox down

sandbox-logs:
	docker-compose --env-file .env.sandbox logs -f

sandbox-clean:
	@echo "サンドボックス環境のデータを削除しています..."
	@read -p "本当に削除しますか？ (yes/no): " confirm && [ "$$confirm" = "yes" ]
	docker-compose --env-file .env.sandbox down -v

# ビルド関連
build:
	@echo "Supersetイメージをビルドしています..."
	docker-compose build superset

rebuild:
	@echo "Supersetイメージを再ビルドしています（キャッシュなし）..."
	docker-compose build --no-cache superset

# ステータス確認
status:
	@echo "=== 本番環境 ==="
	@docker ps -a --filter "name=superset-prod" --filter "name=redis-prod" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "起動していません"
	@echo ""
	@echo "=== 開発環境 ==="
	@docker ps -a --filter "name=superset-dev" --filter "name=redis-dev" --filter "name=postgres-dev" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "起動していません"
	@echo ""
	@echo "=== サンドボックス環境 ==="
	@docker ps -a --filter "name=superset-sandbox" --filter "name=redis-sandbox" --filter "name=postgres-sandbox" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "起動していません"
