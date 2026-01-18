FROM apache/superset:5.0.0

USER root

# Install system dependencies for PostgreSQL and MySQL
RUN apt-get update && apt-get install -y \
    python3-dev \
    default-libmysqlclient-dev \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages using uv (Superset 5.0 package manager)
RUN uv pip install psycopg2-binary authlib mysqlclient pillow

USER superset
