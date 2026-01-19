# -*- coding: utf-8 -*-
import os
from flask_babel import lazy_gettext as _

# セキュリティキー
SECRET_KEY = os.getenv('SUPERSET_SECRET_KEY', 'change_this_secret_key')

# データベース接続設定
SQLALCHEMY_DATABASE_URI = (
    f"{os.getenv('DATABASE_DIALECT', 'postgresql+psycopg2')}://"
    f"{os.getenv('DATABASE_USER', 'superset')}:"
    f"{os.getenv('DATABASE_PASSWORD', 'superset')}@"
    f"{os.getenv('DATABASE_HOST', 'postgres')}:"
    f"{os.getenv('DATABASE_PORT', '5432')}/"
    f"{os.getenv('DATABASE_DB', 'superset')}"
)

# Redis設定
REDIS_HOST = os.getenv('REDIS_HOST', 'redis')
REDIS_PORT = int(os.getenv('REDIS_PORT', 6379))

# Celery設定
class CeleryConfig:
    broker_url = f'redis://{REDIS_HOST}:{REDIS_PORT}/0'
    result_backend = f'redis://{REDIS_HOST}:{REDIS_PORT}/1'
    worker_prefetch_multiplier = 1
    task_acks_late = True

CELERY_CONFIG = CeleryConfig

# キャッシュ設定
CACHE_CONFIG = {
    'CACHE_TYPE': 'redis',
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_KEY_PREFIX': 'superset_',
    'CACHE_REDIS_HOST': REDIS_HOST,
    'CACHE_REDIS_PORT': REDIS_PORT,
    'CACHE_REDIS_DB': 2,
}

DATA_CACHE_CONFIG = {
    'CACHE_TYPE': 'redis',
    'CACHE_DEFAULT_TIMEOUT': 86400,
    'CACHE_KEY_PREFIX': 'superset_data_',
    'CACHE_REDIS_HOST': REDIS_HOST,
    'CACHE_REDIS_PORT': REDIS_PORT,
    'CACHE_REDIS_DB': 3,
}

# レート制限設定（Redisバックエンド使用）
from flask_limiter.util import get_remote_address

RATELIMIT_ENABLED = True
RATELIMIT_STORAGE_URI = f'redis://{REDIS_HOST}:{REDIS_PORT}/4'

# 言語設定
BABEL_DEFAULT_LOCALE = os.getenv('BABEL_DEFAULT_LOCALE', 'ja')
BABEL_DEFAULT_FOLDER = 'superset/translations'

# 利用可能な言語（日本語を最初に配置することで優先度を上げる）
LANGUAGES = {
    'ja': {'flag': 'jp', 'name': '日本語'},
    'en': {'flag': 'us', 'name': 'English'},
}

# ブラウザの言語設定を無視してデフォルトロケールを強制する
# これにより、ブラウザの設定に関係なく日本語が適用される
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SECURE = False  # 本番環境ではTrueに設定
SESSION_COOKIE_SAMESITE = 'Lax'

# タイムゾーン
DEFAULT_TIME_ZONE = 'Asia/Tokyo'

# 機能フラグ
FEATURE_FLAGS = {
    'ENABLE_TEMPLATE_PROCESSING': True,
    'ALERT_REPORTS': False,
    'DASHBOARD_NATIVE_FILTERS': True,
    'DASHBOARD_CROSS_FILTERS': True,
    'DASHBOARD_RBAC': True,
    'EMBEDDABLE_CHARTS': True,
    'SCHEDULED_QUERIES': False,
    'ESTIMATE_QUERY_COST': False,
    'ENABLE_EXPLORE_JSON_CSRF_PROTECTION': True,
    'ESCAPE_MARKDOWN_HTML': True,
}

# ログ設定
# Environment: development, staging, production
ENV = os.getenv('ENV', 'development')

# ログレベルを環境に応じて設定
if ENV == 'production':
    LOG_LEVEL = 'INFO'
else:
    LOG_LEVEL = 'DEBUG'

ENABLE_PROXY_FIX = True

# セキュリティ設定
WTF_CSRF_ENABLED = True
WTF_CSRF_TIME_LIMIT = None

# 最大行数
ROW_LIMIT = 50000
SQL_MAX_ROW = 100000

# タイムアウト設定
SUPERSET_WEBSERVER_TIMEOUT = 300
SQLLAB_TIMEOUT = 300
SQLLAB_ASYNC_TIME_LIMIT_SEC = 300

# CSVエクスポート設定
CSV_EXPORT = {
    'encoding': 'utf-8-sig',
}
