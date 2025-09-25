#!/bin/bash
echo "Starting deployment to staging..."

# Create a .env file for the staging environment
echo "Creating .env file..."
cat <<EOL > .env
MINIO_ENDPOINT=${MINIO_ENDPOINT}
MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY}
MINIO_SECRET_KEY=${MINIO_SECRET_KEY}
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=${POSTGRES_DB}
APP_STG_PORT_1=${APP_STG_PORT_1}
APP_STG_PORT_2=${APP_STG_PORT_2}
EOL

# Pull the latest code from the main branch
echo "Pulling latest code from main branch..."
git pull origin main

# Build and restart all services using the base and staging-specific compose files
echo "Building and restarting staging services..."
docker compose -f docker-compose.yml -f docker-compose.stg.yml up --build -d

echo "Deployment to staging finished."
