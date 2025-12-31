# Superset Configuration File
# This file configures Apache Superset with Japanese language support

import os
from flask_appbuilder.security.manager import AUTH_DB

# Database Configuration
SQLALCHEMY_DATABASE_URI = os.getenv(
    'SQLALCHEMY_DATABASE_URI',
    f"{os.getenv('DATABASE_DIALECT', 'postgresql')}://"
    f"{os.getenv('DATABASE_USER', 'superset')}:"
    f"{os.getenv('DATABASE_PASSWORD', 'superset')}@"
    f"{os.getenv('DATABASE_HOST', 'postgres')}:"
    f"{os.getenv('DATABASE_PORT', '5432')}/"
    f"{os.getenv('DATABASE_DB', 'superset')}"
)

# Redis Configuration
REDIS_HOST = os.getenv('REDIS_HOST', 'redis')
REDIS_PORT = os.getenv('REDIS_PORT_INTERNAL', '6379')

# Redis for caching
CACHE_CONFIG = {
    'CACHE_TYPE': 'RedisCache',
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_KEY_PREFIX': 'superset_',
    'CACHE_REDIS_HOST': REDIS_HOST,
    'CACHE_REDIS_PORT': REDIS_PORT,
    'CACHE_REDIS_DB': 1,
}

# Redis for Celery
class CeleryConfig:
    broker_url = f'redis://{REDIS_HOST}:{REDIS_PORT}/0'
    result_backend = f'redis://{REDIS_HOST}:{REDIS_PORT}/0'
    imports = ('superset.sql_lab',)
    worker_prefetch_multiplier = 1
    task_acks_late = False
    beat_schedule = {
        'cache-warmup-hourly': {
            'task': 'cache-warmup',
            'schedule': 3600.0,  # hourly
            'kwargs': {
                'strategy_name': 'top_n_dashboards',
                'top_n': 10,
            },
        },
    }

CELERY_CONFIG = CeleryConfig

# Secret Key
# WARNING: In production, you MUST set a strong SECRET_KEY via environment variable
# Never use the default value in production!
if os.getenv('SUPERSET_ENV') == 'production' and os.getenv('SUPERSET_SECRET_KEY') == 'CHANGE_THIS_TO_A_COMPLEX_RANDOM_SECRET_KEY':
    raise ValueError("SUPERSET_SECRET_KEY must be set to a secure value in production environment!")

SECRET_KEY = os.getenv('SUPERSET_SECRET_KEY', 'CHANGE_THIS_TO_A_COMPLEX_RANDOM_SECRET_KEY')

# Language Configuration
# Japanese as default with English support
BABEL_DEFAULT_LOCALE = os.getenv('BABEL_DEFAULT_LOCALE', 'ja')

# Available languages
LANGUAGES = {
    'ja': {'flag': 'jp', 'name': '日本語'},
    'en': {'flag': 'us', 'name': 'English'},
}

# Feature flags
FEATURE_FLAGS = {
    'ALERT_REPORTS': True,
    'DASHBOARD_NATIVE_FILTERS': True,
    'DASHBOARD_CROSS_FILTERS': True,
    'DASHBOARD_RBAC': True,
    'EMBEDDABLE_CHARTS': True,
    'ENABLE_TEMPLATE_PROCESSING': True,
    'SCHEDULED_QUERIES': True,
}

# Authentication Configuration
AUTH_TYPE = AUTH_DB

# Allow users to register
AUTH_USER_REGISTRATION = True
AUTH_USER_REGISTRATION_ROLE = 'Public'

# CORS Configuration (adjust as needed for production)
# For production, set CORS_ORIGINS environment variable to specific domains
ENABLE_CORS = True
CORS_OPTIONS = {
    'supports_credentials': True,
    'allow_headers': ['*'],
    'resources': ['*'],
    'origins': os.getenv('CORS_ORIGINS', '*').split(',') if os.getenv('CORS_ORIGINS') else ['*']
}

# Webserver Configuration
ROW_LIMIT = 5000
VIZ_ROW_LIMIT = 10000
SUPERSET_WEBSERVER_TIMEOUT = 300

# SQL Lab Configuration
SQLLAB_TIMEOUT = 300
SUPERSET_WEBSERVER_PORT = 8088

# Additional security settings
WTF_CSRF_ENABLED = True
WTF_CSRF_EXEMPT_LIST = []
WTF_CSRF_TIME_LIMIT = None

# Session Configuration
PERMANENT_SESSION_LIFETIME = 86400  # 24 hours

# Enable SQL Lab
SUPERSET_WEBSERVER_DOMAINS = None

# Async query configuration
GLOBAL_ASYNC_QUERIES_TRANSPORT = "polling"
GLOBAL_ASYNC_QUERIES_POLLING_DELAY = 500

# Thumbnail Configuration
THUMBNAIL_SELENIUM_USER = 'admin'
THUMBNAIL_CACHE_CONFIG = {
    'CACHE_TYPE': 'RedisCache',
    'CACHE_DEFAULT_TIMEOUT': 86400,
    'CACHE_KEY_PREFIX': 'thumbnail_',
    'CACHE_REDIS_HOST': REDIS_HOST,
    'CACHE_REDIS_PORT': REDIS_PORT,
    'CACHE_REDIS_DB': 2,
}

# Results Backend Configuration
RESULTS_BACKEND = {
    'BACKEND': 'redis',
    'CACHE_CONFIG': {
        'CACHE_TYPE': 'RedisCache',
        'CACHE_DEFAULT_TIMEOUT': 86400,
        'CACHE_KEY_PREFIX': 'superset_results_',
        'CACHE_REDIS_HOST': REDIS_HOST,
        'CACHE_REDIS_PORT': REDIS_PORT,
        'CACHE_REDIS_DB': 3,
    }
}

# Azure PostgreSQL specific configurations
# If using Azure PostgreSQL with SSL
if 'azure' in os.getenv('DATABASE_HOST', '').lower():
    SQLALCHEMY_DATABASE_URI += '?sslmode=require'
    
# Database engine specifications
DATABASE_DIALECT_MAP = {
    'postgresql': 'postgres',
}
