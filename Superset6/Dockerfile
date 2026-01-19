# Apache Superset 6.0.0 Production Dockerfile
# Based on official Superset 6.0.0 image with PostgreSQL driver

FROM apache/superset:6.0.0

USER root

# Set environment variable for Playwright (Alerts & Reports)
ENV PLAYWRIGHT_BROWSERS_PATH=/usr/local/share/playwright-browsers

# Install packages using uv into the virtual environment
RUN . /app/.venv/bin/activate && \
    uv pip install \
    # PostgreSQL driver for metadata database
    psycopg2-binary \
    # Redis for caching and Celery
    redis \
    # Pillow for Alerts & Reports PDF generation
    Pillow \
    # openpyxl for Excel file upload support
    openpyxl \
    # Authlib for SSO authentication (optional)
    Authlib \
    # Playwright for Alerts & Reports screenshots
    playwright && \
    # Install Playwright browser dependencies
    playwright install-deps && \
    PLAYWRIGHT_BROWSERS_PATH=/usr/local/share/playwright-browsers playwright install chromium

# Switch back to the superset user
USER superset

CMD ["/app/docker/entrypoints/run-server.sh"]
