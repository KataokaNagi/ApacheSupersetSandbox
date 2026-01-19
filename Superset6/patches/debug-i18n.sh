#!/bin/bash
# =============================================================================
# i18n Debug Script - コンテナ内で実行して問題を調査
# =============================================================================
# 使用方法:
#   docker exec -it <container_name> /app/patches/debug-i18n.sh
# =============================================================================

echo "============================================================"
echo "i18n Debug Information"
echo "============================================================"
echo ""

echo "=== Environment Variables ==="
echo "BABEL_DEFAULT_LOCALE: ${BABEL_DEFAULT_LOCALE:-not set}"
echo "SUPERSET_HOME: ${SUPERSET_HOME:-not set}"
echo ""

echo "=== Translation Files ==="
echo ""
echo "--- Available locales ---"
ls -la /app/superset/translations/ 2>&1
echo ""

echo "--- Japanese locale files ---"
if [ -d "/app/superset/translations/ja" ]; then
    find /app/superset/translations/ja -type f -exec ls -la {} \;
else
    echo "Japanese locale directory not found!"
fi
echo ""

echo "--- Check for messages.json ---"
if [ -f "/app/superset/translations/ja/LC_MESSAGES/messages.json" ]; then
    echo "messages.json exists"
    echo "Size: $(stat -c%s /app/superset/translations/ja/LC_MESSAGES/messages.json 2>/dev/null || stat -f%z /app/superset/translations/ja/LC_MESSAGES/messages.json 2>/dev/null) bytes"
    echo "First 10 entries:"
    python3 -c "
import json
with open('/app/superset/translations/ja/LC_MESSAGES/messages.json', 'r') as f:
    d = json.load(f)
    for i, (k, v) in enumerate(d.items()):
        if i >= 10: break
        print(f'  {repr(k)}: {repr(v)}')
    print(f'  ... total {len(d)} entries')
"
else
    echo "messages.json NOT FOUND"
fi
echo ""

echo "--- Check for messages.po ---"
if [ -f "/app/superset/translations/ja/LC_MESSAGES/messages.po" ]; then
    echo "messages.po exists"
    echo "Size: $(stat -c%s /app/superset/translations/ja/LC_MESSAGES/messages.po 2>/dev/null || stat -f%z /app/superset/translations/ja/LC_MESSAGES/messages.po 2>/dev/null) bytes"
    echo "Line count: $(wc -l < /app/superset/translations/ja/LC_MESSAGES/messages.po)"
    echo ""
    echo "Sample translations from PO file:"
    grep -A1 'msgid "Query mode"' /app/superset/translations/ja/LC_MESSAGES/messages.po 2>/dev/null || echo "  'Query mode' not found"
    grep -A1 'msgid "Columns"' /app/superset/translations/ja/LC_MESSAGES/messages.po 2>/dev/null || echo "  'Columns' not found"
    grep -A1 'msgid "Metrics"' /app/superset/translations/ja/LC_MESSAGES/messages.po 2>/dev/null || echo "  'Metrics' not found"
else
    echo "messages.po NOT FOUND"
fi
echo ""

echo "--- Check for messages.mo ---"
if [ -f "/app/superset/translations/ja/LC_MESSAGES/messages.mo" ]; then
    echo "messages.mo exists"
    echo "Size: $(stat -c%s /app/superset/translations/ja/LC_MESSAGES/messages.mo 2>/dev/null || stat -f%z /app/superset/translations/ja/LC_MESSAGES/messages.mo 2>/dev/null) bytes"
else
    echo "messages.mo NOT FOUND"
fi
echo ""

echo "=== Static Assets ==="
echo ""
echo "--- i18n-runtime-fix.js ---"
if [ -f "/app/superset/static/assets/i18n-runtime-fix.js" ]; then
    echo "i18n-runtime-fix.js exists"
    echo "Size: $(stat -c%s /app/superset/static/assets/i18n-runtime-fix.js 2>/dev/null || stat -f%z /app/superset/static/assets/i18n-runtime-fix.js 2>/dev/null) bytes"
    echo "First 20 lines:"
    head -20 /app/superset/static/assets/i18n-runtime-fix.js
else
    echo "i18n-runtime-fix.js NOT FOUND"
fi
echo ""

echo "--- Check template files ---"
echo "Looking for base.html..."
find /app/superset/templates -name "base.html" -exec ls -la {} \; 2>/dev/null
find /app/superset/templates -name "basic.html" -exec ls -la {} \; 2>/dev/null
echo ""

echo "--- Check if i18n-runtime-fix.js is referenced in templates ---"
grep -r "i18n-runtime-fix" /app/superset/templates/ 2>/dev/null || echo "Not found in templates"
echo ""

echo "=== Frontend Translation Check ==="
echo ""
echo "--- Looking for locale JSON in frontend assets ---"
find /app/superset/static/assets -name "*locale*" -o -name "*translation*" -o -name "*i18n*" 2>/dev/null | head -20
echo ""

echo "--- Check for ja.json in frontend ---"
find /app/superset/static -name "ja*.json" 2>/dev/null
echo ""

echo "=== Superset Config Check ==="
echo ""
if [ -f "/app/pythonpath/superset_config.py" ]; then
    echo "--- superset_config.py (locale settings) ---"
    grep -E "(BABEL|LANGUAGE|LOCALE)" /app/pythonpath/superset_config.py 2>/dev/null
else
    echo "superset_config.py not found at /app/pythonpath/"
fi
echo ""

echo "=== Patch Log ==="
if [ -f "/app/patches/i18n-fix.log" ]; then
    echo "--- Last 50 lines of i18n-fix.log ---"
    tail -50 /app/patches/i18n-fix.log
else
    echo "No patch log found"
fi
echo ""

echo "============================================================"
echo "Debug complete"
echo "============================================================"
