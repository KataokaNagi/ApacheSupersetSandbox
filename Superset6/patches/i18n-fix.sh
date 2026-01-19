#!/bin/bash
# =============================================================================
# Superset 6.0.0 i18n Fix - Shell Script Version
# =============================================================================
# 
# This script applies the i18n fix for Superset 6.0.0 frontend.
# See: https://github.com/apache/superset/issues/34751
#
# TODO: Remove this patch when official fix is released.
#       Check these PRs/issues for updates:
#       - https://github.com/apache/superset/issues/34751
#       - https://github.com/apache/superset/issues/35569
#
# @version 1.2.0
# @date 2026-01-19
# =============================================================================

echo ""
echo "============================================================"
echo "Superset 6.0.0 i18n Fix Patch"
echo "Started at: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"

LOCALE="${BABEL_DEFAULT_LOCALE:-ja}"
TRANSLATIONS_DIR="/app/superset/translations"
STATIC_ASSETS_DIR="/app/superset/static/assets"
MESSAGES_JSON="${TRANSLATIONS_DIR}/${LOCALE}/LC_MESSAGES/messages.json"
MESSAGES_PO="${TRANSLATIONS_DIR}/${LOCALE}/LC_MESSAGES/messages.po"
MESSAGES_MO="${TRANSLATIONS_DIR}/${LOCALE}/LC_MESSAGES/messages.mo"

echo ""
echo "[INFO] Configuration:"
echo "  - Target Locale: ${LOCALE}"
echo "  - TRANSLATIONS_DIR: ${TRANSLATIONS_DIR}"
echo ""

# ディレクトリ構造の確認
echo "[DEBUG] Checking directory structure..."
echo ""
echo "[DEBUG] Contents of /app/superset/translations/:"
ls -la "${TRANSLATIONS_DIR}/" 2>&1 || echo "[ERROR] Directory not found: ${TRANSLATIONS_DIR}"
echo ""

echo "[DEBUG] Available locale directories:"
for dir in "${TRANSLATIONS_DIR}"/*/; do
    if [ -d "$dir" ]; then
        locale_name=$(basename "$dir")
        echo "  - $locale_name"
        ls -la "$dir/LC_MESSAGES/" 2>/dev/null | head -5
    fi
done
echo ""

# Check if ja locale exists
if [ -d "${TRANSLATIONS_DIR}/${LOCALE}" ]; then
    echo "[INFO] Locale directory exists: ${TRANSLATIONS_DIR}/${LOCALE}"
    
    if [ -d "${TRANSLATIONS_DIR}/${LOCALE}/LC_MESSAGES" ]; then
        echo "[DEBUG] LC_MESSAGES contents:"
        ls -la "${TRANSLATIONS_DIR}/${LOCALE}/LC_MESSAGES/" 2>&1
    else
        echo "[ERROR] LC_MESSAGES directory not found!"
    fi
else
    echo "[ERROR] Locale directory not found: ${TRANSLATIONS_DIR}/${LOCALE}"
fi

echo ""
echo "[DEBUG] Static assets directory:"
ls -la "${STATIC_ASSETS_DIR}/" 2>/dev/null | head -10 || echo "[ERROR] Static assets not found"
echo ""

# Check if translations exist
if [ ! -f "${MESSAGES_JSON}" ]; then
    echo "[WARN] Translation JSON file not found: ${MESSAGES_JSON}"
    echo "[INFO] Attempting to generate from .po file..."
    
    if [ -f "${MESSAGES_PO}" ]; then
        echo "[INFO] Found PO file: ${MESSAGES_PO}"
        echo "[DEBUG] PO file size: $(stat -c%s "${MESSAGES_PO}" 2>/dev/null || stat -f%z "${MESSAGES_PO}" 2>/dev/null) bytes"
        echo "[DEBUG] First 20 lines of PO file:"
        head -20 "${MESSAGES_PO}"
        echo ""
        
        # Generate JSON from PO file using Python
        python3 << 'PYTHON_SCRIPT'
import json
import re
import os
import sys

print("[INFO] Running Python script to generate JSON from PO file...")

locale = os.environ.get('BABEL_DEFAULT_LOCALE', 'ja')
po_file = f"/app/superset/translations/{locale}/LC_MESSAGES/messages.po"
json_file = f"/app/superset/translations/{locale}/LC_MESSAGES/messages.json"

print(f"[DEBUG] PO file: {po_file}")
print(f"[DEBUG] JSON file: {json_file}")

translations = {}

if os.path.exists(po_file):
    print(f"[INFO] Reading PO file...")
    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    print(f"[DEBUG] PO file length: {len(content)} characters")
    
    # Parse msgid and msgstr pairs (improved regex)
    # Handle multi-line strings
    pattern = r'msgid\s+"((?:[^"\\]|\\.)*)"\s*\nmsgstr\s+"((?:[^"\\]|\\.)*)"'
    matches = re.findall(pattern, content)
    
    print(f"[DEBUG] Found {len(matches)} translation pairs with simple regex")
    
    for msgid, msgstr in matches:
        if msgid and msgstr:
            try:
                # Unescape special characters
                msgid_decoded = msgid.encode('utf-8').decode('unicode_escape')
                msgstr_decoded = msgstr.encode('utf-8').decode('unicode_escape')
                translations[msgid_decoded] = msgstr_decoded
            except Exception as e:
                print(f"[WARN] Failed to decode: {msgid[:50]}... Error: {e}")
    
    print(f"[INFO] Parsed {len(translations)} valid translations")
    
    # Show some sample translations
    print("[DEBUG] Sample translations:")
    count = 0
    for k, v in translations.items():
        if count < 10:
            print(f"  '{k}' => '{v}'")
            count += 1
    
    if translations:
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump(translations, f, ensure_ascii=False, indent=2)
        print(f"[SUCCESS] Generated {len(translations)} translations to {json_file}")
    else:
        print("[ERROR] No translations parsed from PO file!")
        sys.exit(1)
else:
    print(f"[ERROR] PO file not found: {po_file}")
    sys.exit(1)
PYTHON_SCRIPT
        
        PYTHON_EXIT_CODE=$?
        if [ $PYTHON_EXIT_CODE -ne 0 ]; then
            echo "[ERROR] Python script failed with exit code: $PYTHON_EXIT_CODE"
        fi
    else
        echo "[ERROR] PO file not found: ${MESSAGES_PO}"
    fi
else
    echo "[INFO] Translation JSON file found: ${MESSAGES_JSON}"
    echo "[DEBUG] JSON file size: $(stat -c%s "${MESSAGES_JSON}" 2>/dev/null || stat -f%z "${MESSAGES_JSON}" 2>/dev/null) bytes"
fi

echo ""
echo "[INFO] Creating runtime translation injection..."

python3 << 'PYTHON_SCRIPT'
import json
import os
import sys

print("[INFO] Running Python script to create runtime injection...")

locale = os.environ.get('BABEL_DEFAULT_LOCALE', 'ja')
json_file = f"/app/superset/translations/{locale}/LC_MESSAGES/messages.json"
output_file = "/app/superset/static/assets/i18n-runtime-fix.js"

print(f"[DEBUG] Looking for JSON file: {json_file}")
print(f"[DEBUG] Output file: {output_file}")

translations = {}

if os.path.exists(json_file):
    print(f"[INFO] Loading translations from JSON file...")
    with open(json_file, 'r', encoding='utf-8') as f:
        translations = json.load(f)
    print(f"[SUCCESS] Loaded {len(translations)} translations")
else:
    print(f"[ERROR] JSON file not found: {json_file}")
    print("[WARN] Creating empty runtime injection...")

# Create the injection script
script_content = f'''
// =============================================================================
// Superset 6.0.0 i18n Runtime Injection
// Auto-generated by i18n-fix.sh - DO NOT EDIT MANUALLY
// See: https://github.com/apache/superset/issues/34751
// TODO: Remove when official fix is released
// Generated at: {os.popen("date '+%Y-%m-%d %H:%M:%S'").read().strip()}
// Translations loaded: {len(translations)}
// =============================================================================
(function() {{
    'use strict';
    
    console.log('[i18n-fix] Runtime injection loaded');
    console.log('[i18n-fix] Translations count:', {len(translations)});
    
    var translations = {json.dumps(translations, ensure_ascii=False)};
    
    // Debug: log some translations
    var keys = Object.keys(translations);
    console.log('[i18n-fix] Sample translations:', keys.slice(0, 5));
    
    // Wait for Superset to be ready and patch translations
    function patchTranslations() {{
        console.log('[i18n-fix] Attempting to patch translations...');
        var patched = false;
        
        // Method 1: Patch @superset-ui/core translation function
        if (window.__SUPERSET_I18N__) {{
            console.log('[i18n-fix] Found window.__SUPERSET_I18N__');
            var original = window.__SUPERSET_I18N__.t;
            window.__SUPERSET_I18N__.t = function(key) {{
                if (translations[key]) {{
                    return translations[key];
                }}
                return original ? original(key) : key;
            }};
            patched = true;
        }}
        
        // Method 2: Patch any global t function
        if (typeof window.t === 'function') {{
            console.log('[i18n-fix] Found window.t function');
            var originalT = window.t;
            window.t = function(key) {{
                if (translations[key]) {{
                    return translations[key];
                }}
                return originalT(key);
            }};
            patched = true;
        }}
        
        // Method 3: Look for translation in webpack modules
        if (window.webpackJsonp || window.webpackChunk) {{
            console.log('[i18n-fix] Found webpack chunks');
        }}
        
        // Method 4: Intercept i18next if used
        if (window.i18next) {{
            console.log('[i18n-fix] Found i18next');
            var originalI18n = window.i18next.t.bind(window.i18next);
            window.i18next.t = function(key) {{
                if (translations[key]) {{
                    return translations[key];
                }}
                return originalI18n(key);
            }};
            patched = true;
        }}
        
        if (!patched) {{
            console.log('[i18n-fix] No translation function found to patch');
        }} else {{
            console.log('[i18n-fix] Translation patching complete');
        }}
        
        return patched;
    }}
    
    // Apply patch when DOM is ready
    if (document.readyState === 'loading') {{
        document.addEventListener('DOMContentLoaded', function() {{
            console.log('[i18n-fix] DOMContentLoaded');
            patchTranslations();
        }});
    }} else {{
        console.log('[i18n-fix] DOM already ready');
        patchTranslations();
    }}
    
    // Also patch after delays to catch late-loaded modules
    setTimeout(function() {{
        console.log('[i18n-fix] Retry patch after 1s');
        patchTranslations();
    }}, 1000);
    
    setTimeout(function() {{
        console.log('[i18n-fix] Retry patch after 3s');
        patchTranslations();
    }}, 3000);
    
    setTimeout(function() {{
        console.log('[i18n-fix] Retry patch after 5s');
        patchTranslations();
    }}, 5000);
    
    // Expose for debugging
    window.__I18N_FIX__ = {{
        translations: translations,
        patchTranslations: patchTranslations,
        version: '1.1.0'
    }};
    console.log('[i18n-fix] Debug object available at window.__I18N_FIX__');
}})();
'''

try:
    # Ensure output directory exists
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(script_content)
    print(f"[SUCCESS] Created runtime injection: {output_file}")
    print(f"[DEBUG] Output file size: {os.path.getsize(output_file)} bytes")
except Exception as e:
    print(f"[ERROR] Failed to create runtime injection: {e}")
    sys.exit(1)
PYTHON_SCRIPT

PYTHON_EXIT_CODE=$?
if [ $PYTHON_EXIT_CODE -ne 0 ]; then
    echo "[ERROR] Python script failed with exit code: $PYTHON_EXIT_CODE"
fi

# Verify output file
echo ""
echo "[DEBUG] Verifying output file..."
if [ -f "/app/superset/static/assets/i18n-runtime-fix.js" ]; then
    echo "[SUCCESS] Runtime injection file created"
    echo "[DEBUG] File size: $(stat -c%s "/app/superset/static/assets/i18n-runtime-fix.js" 2>/dev/null || stat -f%z "/app/superset/static/assets/i18n-runtime-fix.js" 2>/dev/null) bytes"
    echo "[DEBUG] First 30 lines of generated file:"
    head -30 "/app/superset/static/assets/i18n-runtime-fix.js"
else
    echo "[ERROR] Runtime injection file was NOT created!"
fi

echo ""
echo "============================================================"
echo "i18n Fix Patch completed at: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Log file: ${LOG_FILE}"
echo "============================================================"
