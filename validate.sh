#!/bin/bash
# Validation Script for Apache Superset Configuration
# 設定ファイル検証スクリプト

echo "================================================="
echo "Apache Superset Configuration Validation"
echo "Apache Superset 設定ファイル検証"
echo "================================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Function to check file existence
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} File exists: $1"
    else
        echo -e "${RED}✗${NC} File missing: $1"
        ((ERRORS++))
    fi
}

# Function to validate YAML
validate_yaml() {
    if command -v docker &> /dev/null; then
        if docker compose --env-file "$2" config > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Valid YAML: $1 with $2"
        else
            echo -e "${RED}✗${NC} Invalid YAML: $1 with $2"
            ((ERRORS++))
        fi
    else
        echo -e "${YELLOW}⚠${NC} Docker not available, skipping YAML validation"
        ((WARNINGS++))
    fi
}

# Function to validate Python syntax
validate_python() {
    if command -v python3 &> /dev/null; then
        if python3 -m py_compile "$1" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} Valid Python: $1"
        else
            echo -e "${RED}✗${NC} Invalid Python: $1"
            ((ERRORS++))
        fi
    else
        echo -e "${YELLOW}⚠${NC} Python not available, skipping Python validation"
        ((WARNINGS++))
    fi
}

# Function to validate Bash syntax
validate_bash() {
    if bash -n "$1" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Valid Bash: $1"
    else
        echo -e "${RED}✗${NC} Invalid Bash: $1"
        ((ERRORS++))
    fi
}

echo "1. Checking required files..."
echo "----------------------------"
check_file "docker-compose.yml"
check_file ".env.production"
check_file ".env.development"
check_file ".env.sandbox"
check_file ".env.example"
check_file "superset/Dockerfile"
check_file "superset/superset_config.py"
check_file "superset/docker-init.sh"
check_file "README.md"
check_file "SETUP.md"
echo ""

echo "2. Validating YAML configurations..."
echo "------------------------------------"
validate_yaml "docker-compose.yml" ".env.development"
validate_yaml "docker-compose.yml" ".env.production"
validate_yaml "docker-compose.yml" ".env.sandbox"
echo ""

echo "3. Validating Python files..."
echo "----------------------------"
validate_python "superset/superset_config.py"
echo ""

echo "4. Validating Shell scripts..."
echo "-----------------------------"
validate_bash "superset/docker-init.sh"
validate_bash "quickstart.sh"
echo ""

echo "5. Checking environment variables..."
echo "------------------------------------"
for env_file in .env.production .env.development .env.sandbox; do
    echo "Checking $env_file:"
    
    # Check for required variables
    required_vars=("SUPERSET_CONTAINER_NAME" "REDIS_CONTAINER_NAME" "DATABASE_HOST" "SUPERSET_SECRET_KEY")
    
    for var in "${required_vars[@]}"; do
        if grep -q "^${var}=" "$env_file"; then
            echo -e "  ${GREEN}✓${NC} $var is set"
        else
            echo -e "  ${RED}✗${NC} $var is missing"
            ((ERRORS++))
        fi
    done
    echo ""
done

echo "6. Checking port configurations..."
echo "---------------------------------"
echo "Production ports:"
grep "SUPERSET_PORT\|REDIS_PORT\|POSTGRES_PORT" .env.production | grep -v "^#" | grep -v "INTERNAL"
echo ""
echo "Development ports:"
grep "SUPERSET_PORT\|REDIS_PORT\|POSTGRES_PORT" .env.development | grep -v "^#" | grep -v "INTERNAL"
echo ""
echo "Sandbox ports:"
grep "SUPERSET_PORT\|REDIS_PORT\|POSTGRES_PORT" .env.sandbox | grep -v "^#" | grep -v "INTERNAL"
echo ""

echo "7. Checking container names..."
echo "-----------------------------"
echo "Production:"
grep "CONTAINER_NAME=" .env.production | grep -v "^#"
echo ""
echo "Development:"
grep "CONTAINER_NAME=" .env.development | grep -v "^#"
echo ""
echo "Sandbox:"
grep "CONTAINER_NAME=" .env.sandbox | grep -v "^#"
echo ""

echo "================================================="
echo "Validation Summary"
echo "================================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed!${NC}"
    echo "Errors: $ERRORS"
    echo "Warnings: $WARNINGS"
    exit 0
else
    echo -e "${RED}✗ Validation failed!${NC}"
    echo "Errors: $ERRORS"
    echo "Warnings: $WARNINGS"
    exit 1
fi
