FROM apache/superset:5.0.0

# Switch to root to install packages
USER root

# Install Japanese locale and required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        locales \
        gettext \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Generate Japanese locale
RUN sed -i -e 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen ja_JP.UTF-8

# Set environment variables for locale
ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8

# Install PostgreSQL client for Azure PostgreSQL connection
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy custom superset config
COPY superset_config.py /app/pythonpath/superset_config.py

# Copy initialization script
COPY docker-init.sh /app/docker-init.sh
RUN chmod +x /app/docker-init.sh

# Switch back to superset user
USER superset

# Set the initialization script as entrypoint
ENTRYPOINT ["/app/docker-init.sh"]
