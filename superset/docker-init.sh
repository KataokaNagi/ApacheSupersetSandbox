#!/bin/bash
set -e

# Wait for database to be ready
echo "Waiting for database connection..."
timeout=60
counter=0

until psql "${DATABASE_DIALECT}://${DATABASE_USER}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DB}" -c '\l' > /dev/null 2>&1; do
    counter=$((counter + 1))
    if [ $counter -gt $timeout ]; then
        echo "Error: Database connection timeout after ${timeout} seconds"
        exit 1
    fi
    echo "Database is not ready yet. Waiting... ($counter/$timeout)"
    sleep 1
done

echo "Database is ready!"

# Initialize database
echo "Initializing Superset database..."
superset db upgrade

# Create admin user if it doesn't exist
echo "Creating admin user..."
superset fab create-admin \
    --username "${ADMIN_USERNAME}" \
    --firstname "${ADMIN_FIRSTNAME}" \
    --lastname "${ADMIN_LASTNAME}" \
    --email "${ADMIN_EMAIL}" \
    --password "${ADMIN_PASSWORD}" || echo "Admin user already exists"

# Initialize Superset
echo "Initializing Superset..."
superset init

# Load examples if specified
if [ "${SUPERSET_LOAD_EXAMPLES}" = "yes" ]; then
    echo "Loading example data..."
    superset load_examples || echo "Examples already loaded or failed to load"
fi

echo "Starting Superset..."
/usr/bin/run-server.sh
