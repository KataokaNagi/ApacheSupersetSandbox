# Apache Superset 6.0.0 Configuration
# ローカル開発環境とAzureクラウド環境対応

import os
from datetime import timedelta
from celery.schedules import crontab
from flask_caching.backends.rediscache import RedisCache

# =============================================================================
# Environment Helper
# =============================================================================
def get_env_variable(var_name, default=None):
    """環境変数を取得するヘルパー関数"""
    try:
        return os.environ[var_name]
    except KeyError:
        if default is not None:
            return default
        raise RuntimeError(f"環境変数 {var_name} が設定されていません")

# =============================================================================
# App Configuration
# =============================================================================
# Superset uses Flask-AppBuilder
APP_NAME = "Superset"
APP_ICON = "/static/assets/images/superset-logo-horiz.png"

# Secret key for signing cookies and JWT tokens
SECRET_KEY = get_env_variable("SUPERSET_SECRET_KEY")

# =============================================================================
# Database Configuration
# =============================================================================
DATABASE_DIALECT = get_env_variable("DATABASE_DIALECT", "postgresql")
DATABASE_USER = get_env_variable("DATABASE_USER", "superset")
DATABASE_PASSWORD = get_env_variable("DATABASE_PASSWORD", "superset")
DATABASE_HOST = get_env_variable("DATABASE_HOST", "postgres")
DATABASE_PORT = get_env_variable("DATABASE_PORT", "5432")
DATABASE_DB = get_env_variable("DATABASE_DB", "superset")

# SQLAlchemy connection string
SQLALCHEMY_DATABASE_URI = (
    f"{DATABASE_DIALECT}://{DATABASE_USER}:{DATABASE_PASSWORD}@"
    f"{DATABASE_HOST}:{DATABASE_PORT}/{DATABASE_DB}"
)

# SQLAlchemy settings
SQLALCHEMY_TRACK_MODIFICATIONS = False
SQLALCHEMY_ENGINE_OPTIONS = {
    "pool_pre_ping": True,
    "pool_recycle": 3600,
    "pool_size": 10,
    "max_overflow": 20,
}

# =============================================================================
# Redis Configuration
# =============================================================================
REDIS_HOST = get_env_variable("REDIS_HOST", "redis")
REDIS_PORT = get_env_variable("REDIS_PORT", "6379")
REDIS_CELERY_DB = get_env_variable("REDIS_CELERY_DB", "0")
REDIS_RESULTS_DB = get_env_variable("REDIS_RESULTS_DB", "1")
REDIS_CACHE_DB = get_env_variable("REDIS_CACHE_DB", "2")

REDIS_URL = f"redis://{REDIS_HOST}:{REDIS_PORT}"

# =============================================================================
# Cache Configuration
# =============================================================================
CACHE_CONFIG = {
    "CACHE_TYPE": "RedisCache",
    "CACHE_DEFAULT_TIMEOUT": 300,
    "CACHE_KEY_PREFIX": "superset_",
    "CACHE_REDIS_URL": f"{REDIS_URL}/{REDIS_CACHE_DB}",
}

DATA_CACHE_CONFIG = {
    "CACHE_TYPE": "RedisCache",
    "CACHE_DEFAULT_TIMEOUT": 86400,  # 24 hours
    "CACHE_KEY_PREFIX": "superset_data_",
    "CACHE_REDIS_URL": f"{REDIS_URL}/{REDIS_CACHE_DB}",
}

FILTER_STATE_CACHE_CONFIG = {
    "CACHE_TYPE": "RedisCache",
    "CACHE_DEFAULT_TIMEOUT": 86400,
    "CACHE_KEY_PREFIX": "superset_filter_",
    "CACHE_REDIS_URL": f"{REDIS_URL}/{REDIS_CACHE_DB}",
}

EXPLORE_FORM_DATA_CACHE_CONFIG = {
    "CACHE_TYPE": "RedisCache",
    "CACHE_DEFAULT_TIMEOUT": 86400,
    "CACHE_KEY_PREFIX": "superset_explore_",
    "CACHE_REDIS_URL": f"{REDIS_URL}/{REDIS_CACHE_DB}",
}

# =============================================================================
# Celery Configuration (for async queries and Alerts & Reports)
# =============================================================================
class CeleryConfig:
    broker_url = f"{REDIS_URL}/{REDIS_CELERY_DB}"
    result_backend = f"{REDIS_URL}/{REDIS_RESULTS_DB}"
    imports = (
        "superset.sql_lab",
        "superset.tasks.scheduler",
        "superset.tasks.thumbnails",
        "superset.tasks.cache",
    )
    worker_prefetch_multiplier = 1
    task_acks_late = False
    task_annotations = {
        "sql_lab.get_sql_results": {
            "rate_limit": "100/s",
        },
    }
    beat_schedule = {
        "reports.scheduler": {
            "task": "reports.scheduler",
            "schedule": crontab(minute="*", hour="*"),
        },
        "reports.prune_log": {
            "task": "reports.prune_log",
            "schedule": crontab(minute=10, hour=0),
        },
    }

CELERY_CONFIG = CeleryConfig

# =============================================================================
# Feature Flags
# =============================================================================
FEATURE_FLAGS = {
    # Alerts & Reports
    "ALERT_REPORTS": True,
    "ALERT_REPORT_TABS": True,
    # Playwright for screenshots (default True in 6.0.0)
    "PLAYWRIGHT_REPORTS_AND_THUMBNAILS": True,
    # Dashboard features
    "DASHBOARD_NATIVE_FILTERS": True,
    "DASHBOARD_CROSS_FILTERS": True,
    "DASHBOARD_NATIVE_FILTERS_SET": True,
    # Chart features
    "ENABLE_EXPLORE_DRAG_AND_DROP": True,
    "ENABLE_DND_WITH_CLICK_UX": True,
    # SQL Lab features
    "ENABLE_TEMPLATE_PROCESSING": True,
    # Embedded features
    "EMBEDDED_SUPERSET": True,
    # API
    "ENABLE_JAVASCRIPT_CONTROLS": False,
}

# =============================================================================
# Localization (日本語対応)
# =============================================================================
BABEL_DEFAULT_LOCALE = get_env_variable("BABEL_DEFAULT_LOCALE", "ja")
BABEL_DEFAULT_FOLDER = "superset/translations"
LANGUAGES = {
    "ja": {"flag": "jp", "name": "Japanese"},
    "en": {"flag": "us", "name": "English"},
}

# =============================================================================
# Web Server Configuration
# =============================================================================
SUPERSET_WEBSERVER_PORT = 8088
SUPERSET_WEBSERVER_TIMEOUT = 60
ENABLE_PROXY_FIX = True  # Required when behind a reverse proxy (Azure, nginx)

# =============================================================================
# Logging Configuration
# =============================================================================
# Environment: development, staging, production
ENV = get_env_variable("ENV", "development")

# ログレベルを環境に応じて設定
if ENV == "production":
    LOG_LEVEL = "INFO"
else:
    LOG_LEVEL = "DEBUG"

LOG_FORMAT = "%(asctime)s:%(levelname)s:%(name)s:%(message)s"
LOG_FILE = None  # Set to a path to enable file logging

# =============================================================================
# Security Configuration
# =============================================================================
# Content Security Policy
TALISMAN_ENABLED = True
TALISMAN_CONFIG = {
    "content_security_policy": None,  # Disable CSP for development; enable for production
    "force_https": False,  # Set True for production with HTTPS
}

# CORS Configuration (Azureデプロイ時に必要な場合)
ENABLE_CORS = True
CORS_OPTIONS = {
    "supports_credentials": True,
    "allow_headers": ["*"],
    "resources": ["*"],
    "origins": ["*"],  # 本番環境では具体的なドメインに制限してください
}

# =============================================================================
# Session Configuration
# =============================================================================
SESSION_COOKIE_SAMESITE = "Lax"
SESSION_COOKIE_SECURE = False  # Set True for production with HTTPS
SESSION_COOKIE_HTTPONLY = True

# =============================================================================
# Alerts & Reports Configuration
# =============================================================================
WEBDRIVER_TYPE = "chrome"  # Playwright uses Chrome
WEBDRIVER_BASEURL = "http://superset:8088"
WEBDRIVER_BASEURL_USER_FRIENDLY = get_env_variable(
    "WEBDRIVER_BASEURL_USER_FRIENDLY",
    "http://localhost:8088"
)

# Screenshot configuration
SCREENSHOT_LOCATE_WAIT = 100
SCREENSHOT_LOAD_WAIT = 600

# Email configuration (SMTP)
SMTP_HOST = get_env_variable("SMTP_HOST", "localhost")
SMTP_PORT = int(get_env_variable("SMTP_PORT", "25"))
SMTP_STARTTLS = get_env_variable("SMTP_STARTTLS", "True").lower() == "true"
SMTP_SSL = get_env_variable("SMTP_SSL", "False").lower() == "true"
SMTP_USER = get_env_variable("SMTP_USER", "")
SMTP_PASSWORD = get_env_variable("SMTP_PASSWORD", "")
SMTP_MAIL_FROM = get_env_variable("SMTP_MAIL_FROM", "superset@example.com")

# =============================================================================
# Logging Configuration
# =============================================================================
LOG_FORMAT = "%(asctime)s:%(levelname)s:%(name)s:%(message)s"
LOG_LEVEL = get_env_variable("LOG_LEVEL", "INFO")

# Enable SQL query logging (for debugging)
SQL_MAX_ROW = 100000
DISPLAY_MAX_ROW = 10000

# =============================================================================
# Additional Configuration
# =============================================================================
# Row limit for queries
ROW_LIMIT = 50000
VIZ_ROW_LIMIT = 10000
SAMPLES_ROW_LIMIT = 1000

# SQL Lab settings
SQLLAB_TIMEOUT = 300
SQLLAB_ASYNC_TIME_LIMIT_SEC = 600

# Upload folder for CSV/Excel imports
UPLOAD_FOLDER = "/app/superset_home/uploads/"
IMG_UPLOAD_FOLDER = "/app/superset_home/img/"

# Custom CSS template
# CUSTOM_SECURITY_MANAGER = None
