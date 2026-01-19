# Apache Superset 6.0.0 Production Dockerfile
# Based on official Superset 6.0.0 image with PostgreSQL driver

FROM apache/superset:6.0.0

USER root

# Set environment variable for Playwright (Alerts & Reports)
ENV PLAYWRIGHT_BROWSERS_PATH=/usr/local/share/playwright-browsers

# =============================================================================
# i18n Fix Patch for Superset 6.0.0
# See: https://github.com/apache/superset/issues/34751
# TODO: Remove this section when official fix is released
# =============================================================================
# Set locale environment variable for the patch
ENV BABEL_DEFAULT_LOCALE=ja

# Copy patch files
COPY patches/ /app/patches/
RUN chmod +x /app/patches/*.sh

# Download Japanese translation files from Superset GitHub repository
# The official Docker image has empty LC_MESSAGES directories
# Note: GitHub only has messages.po, we need to generate messages.json
RUN echo "=== Downloading Japanese translation files from GitHub ===" && \
    curl -fsSL -o /app/superset/translations/ja/LC_MESSAGES/messages.po \
        "https://raw.githubusercontent.com/apache/superset/master/superset/translations/ja/LC_MESSAGES/messages.po" && \
    echo "[SUCCESS] Downloaded messages.po" && \
    ls -la /app/superset/translations/ja/LC_MESSAGES/

# Generate messages.json from messages.po
# IMPORTANT: Superset expects a specific JSON structure with "domain" and "locale_data" wrapper
RUN echo "=== Generating messages.json from messages.po ===" && \
    python3 << 'PYTHON_SCRIPT'
import json

po_file = '/app/superset/translations/ja/LC_MESSAGES/messages.po'
json_file = '/app/superset/translations/ja/LC_MESSAGES/messages.json'

with open(po_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

translations = {}
current_msgid = None
current_msgstr = None
in_msgid = False
in_msgstr = False

for line in lines:
    line = line.rstrip('\n')
    
    if line.startswith('msgid "'):
        in_msgid = True
        in_msgstr = False
        current_msgid = line[7:-1]  # Remove 'msgid "' and trailing '"'
    elif line.startswith('msgstr "'):
        in_msgstr = True
        in_msgid = False
        current_msgstr = line[8:-1]  # Remove 'msgstr "' and trailing '"'
    elif line.startswith('"') and line.endswith('"'):
        # Continuation line
        content = line[1:-1]
        if in_msgid and current_msgid is not None:
            current_msgid += content
        elif in_msgstr and current_msgstr is not None:
            current_msgstr += content
    elif line == '' or line.startswith('#'):
        # End of entry or comment
        if current_msgid and current_msgstr:
            # Unescape
            msgid = current_msgid.replace('\\n', '\n').replace('\\"', '"').replace('\\\\', '\\')
            msgstr = current_msgstr.replace('\\n', '\n').replace('\\"', '"').replace('\\\\', '\\')
            # Only add non-empty translations (skip empty msgid which is header)
            if msgid:
                translations[msgid] = msgstr
        current_msgid = None
        current_msgstr = None
        in_msgid = False
        in_msgstr = False

# Don't forget the last entry
if current_msgid and current_msgstr:
    msgid = current_msgid.replace('\\n', '\n').replace('\\"', '"').replace('\\\\', '\\')
    msgstr = current_msgstr.replace('\\n', '\n').replace('\\"', '"').replace('\\\\', '\\')
    if msgid:
        translations[msgid] = msgstr

print(f'[INFO] Parsed {len(translations)} translations')

# Build the language pack structure that Superset expects
# See: superset/views/base.py and superset-frontend for expected format
language_pack = {
    "domain": "superset",
    "locale_data": {
        "superset": {
            "": {
                "domain": "superset",
                "plural_forms": "nplurals=1; plural=0",
                "lang": "ja"
            }
        }
    }
}

# Add all translations to the locale_data.superset object
for msgid, msgstr in translations.items():
    language_pack["locale_data"]["superset"][msgid] = [msgstr]

with open(json_file, 'w', encoding='utf-8') as f:
    json.dump(language_pack, f, ensure_ascii=False, indent=2)

print(f'[SUCCESS] Generated {json_file} with locale_data structure')
PYTHON_SCRIPT

# Verify Japanese messages.json was created
RUN echo "=== Verifying messages.json ===" && \
    head -20 /app/superset/translations/ja/LC_MESSAGES/messages.json
# =============================================================================
# End of i18n Fix Patch
# =============================================================================

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

