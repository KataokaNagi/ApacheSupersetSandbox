/**
 * Superset 6.0.0 i18n Fix Patch
 * 
 * This patch fixes the partial translation issue in Superset 6.0.0 frontend.
 * See: https://github.com/apache/superset/issues/34751
 * 
 * Issue: Frontend plugins and packages do not properly load translations
 * because the translation function t('') is not correctly imported in
 * controlPanel components.
 * 
 * Solution: This script patches the built JavaScript files to ensure
 * translations are properly loaded at runtime.
 * 
 * TODO: Remove this patch when official fix is released.
 *       Check these PRs/issues for updates:
 *       - https://github.com/apache/superset/issues/34751
 *       - https://github.com/apache/superset/issues/35569
 * 
 * @version 1.0.0
 * @date 2026-01-19
 */

const fs = require('fs');
const path = require('path');

// Configuration
const STATIC_ASSETS_DIR = '/app/superset/static/assets';
const TRANSLATIONS_DIR = '/app/superset/translations';
const TARGET_LOCALE = process.env.BABEL_DEFAULT_LOCALE || 'ja';

console.log('='.repeat(60));
console.log('Superset 6.0.0 i18n Fix Patch');
console.log('Target Locale:', TARGET_LOCALE);
console.log('='.repeat(60));

/**
 * Load translation messages from JSON file
 */
function loadTranslations(locale) {
    const messagesPath = path.join(TRANSLATIONS_DIR, locale, 'LC_MESSAGES', 'messages.json');
    
    if (!fs.existsSync(messagesPath)) {
        console.warn(`Warning: Translation file not found: ${messagesPath}`);
        return null;
    }
    
    try {
        const content = fs.readFileSync(messagesPath, 'utf8');
        return JSON.parse(content);
    } catch (error) {
        console.error(`Error loading translations: ${error.message}`);
        return null;
    }
}

/**
 * Find and patch JavaScript files that contain untranslated strings
 */
function patchJavaScriptFiles(translations) {
    if (!translations) {
        console.log('No translations loaded, skipping patch.');
        return;
    }

    const jsFiles = findJsFiles(STATIC_ASSETS_DIR);
    console.log(`Found ${jsFiles.length} JavaScript files to check.`);

    let patchedCount = 0;

    for (const filePath of jsFiles) {
        if (patchFile(filePath, translations)) {
            patchedCount++;
        }
    }

    console.log(`Patched ${patchedCount} files.`);
}

/**
 * Recursively find all JavaScript files
 */
function findJsFiles(dir) {
    const files = [];
    
    if (!fs.existsSync(dir)) {
        console.warn(`Directory not found: ${dir}`);
        return files;
    }

    const items = fs.readdirSync(dir);
    
    for (const item of items) {
        const fullPath = path.join(dir, item);
        const stat = fs.statSync(fullPath);
        
        if (stat.isDirectory()) {
            files.push(...findJsFiles(fullPath));
        } else if (item.endsWith('.js') && !item.endsWith('.map')) {
            files.push(fullPath);
        }
    }
    
    return files;
}

/**
 * Patch a single JavaScript file with translations
 */
function patchFile(filePath, translations) {
    try {
        let content = fs.readFileSync(filePath, 'utf8');
        let modified = false;

        // Common untranslated strings in controlPanel components
        const stringsToTranslate = [
            'Query mode',
            'Aggregate',
            'Raw records',
            'Columns',
            'Ordering',
            'Row limit',
            'Sort descending',
            'Sort ascending',
            'Series limit',
            'Contribution',
            'Show empty columns',
            'Time Grain',
            'Time Column',
            'Time Range',
            'Filters',
            'Group by',
            'Metrics',
            'Dimensions',
            'Color Scheme',
            'Show Legend',
            'Show Labels',
            'X Axis',
            'Y Axis',
            'Chart Title',
            'Description',
            'Certified by',
            'Certification details',
            'Warning',
            'Cache timeout',
            'Annotation Layers',
            'Left Margin',
            'Bottom Margin',
            'Show Markers',
            'Line interpolation',
            'Stack',
            'Normalize',
            'Bar Values',
            'Show Percentage',
            'Rich Tooltip',
            'Truncate Metric',
            'Sort Bars',
        ];

        for (const original of stringsToTranslate) {
            const translated = translations[original];
            if (translated && translated !== original) {
                // Pattern to match label definitions in compiled JS
                // e.g., label:"Query mode" or label: "Query mode"
                const patterns = [
                    new RegExp(`label:\\s*["']${escapeRegex(original)}["']`, 'g'),
                    new RegExp(`label:\\s*\\(\\)\\s*=>\\s*["']${escapeRegex(original)}["']`, 'g'),
                    new RegExp(`placeholder:\\s*["']${escapeRegex(original)}["']`, 'g'),
                    new RegExp(`title:\\s*["']${escapeRegex(original)}["']`, 'g'),
                ];

                for (const pattern of patterns) {
                    if (pattern.test(content)) {
                        content = content.replace(pattern, (match) => {
                            return match.replace(original, translated);
                        });
                        modified = true;
                    }
                }
            }
        }

        if (modified) {
            fs.writeFileSync(filePath, content, 'utf8');
            console.log(`Patched: ${path.basename(filePath)}`);
            return true;
        }
    } catch (error) {
        console.error(`Error patching ${filePath}: ${error.message}`);
    }
    
    return false;
}

/**
 * Escape special regex characters
 */
function escapeRegex(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

/**
 * Create runtime translation injection script
 */
function createRuntimeInjection(translations) {
    if (!translations) return;

    const injectionScript = `
// Superset 6.0.0 i18n Runtime Injection
// Auto-generated - DO NOT EDIT
// See: https://github.com/apache/superset/issues/34751
(function() {
    const translations = ${JSON.stringify(translations, null, 2)};
    
    // Override the translation function if it exists
    if (window.superset && window.superset.t) {
        const originalT = window.superset.t;
        window.superset.t = function(key, ...args) {
            if (translations[key]) {
                return translations[key];
            }
            return originalT(key, ...args);
        };
    }
    
    // Also patch the global t function
    if (typeof window.t === 'function') {
        const originalGlobalT = window.t;
        window.t = function(key, ...args) {
            if (translations[key]) {
                return translations[key];
            }
            return originalGlobalT(key, ...args);
        };
    }
})();
`;

    const outputPath = path.join(STATIC_ASSETS_DIR, 'i18n-runtime-fix.js');
    
    try {
        fs.writeFileSync(outputPath, injectionScript, 'utf8');
        console.log(`Created runtime injection: ${outputPath}`);
    } catch (error) {
        console.error(`Error creating runtime injection: ${error.message}`);
    }
}

// Main execution
console.log('Loading translations...');
const translations = loadTranslations(TARGET_LOCALE);

if (translations) {
    console.log(`Loaded ${Object.keys(translations).length} translation entries.`);
    
    console.log('\nPatching JavaScript files...');
    patchJavaScriptFiles(translations);
    
    console.log('\nCreating runtime injection script...');
    createRuntimeInjection(translations);
}

console.log('\n' + '='.repeat(60));
console.log('i18n Fix Patch completed.');
console.log('='.repeat(60));
