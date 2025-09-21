#!/bin/bash
# This script is executed on the production server.

echo "Starting deployment to production..."

# Create a .env file with the environment variables passed from the workflow
echo "Creating .env file..."
cat <<EOL > .env
APP_IMAGE=${APP_IMAGE}
APP_TAG=${APP_TAG}
APP_PROD_PORT=${APP_PROD_PORT}
MINIO_PROD_ENDPOINT=${MINIO_PROD_ENDPOINT}
MINIO_PROD_ACCESS_KEY=${MINIO_PROD_ACCESS_KEY}
MINIO_PROD_SECRET_KEY=${MINIO_PROD_SECRET_KEY}
EOL

# Log in to Docker Hub using the credentials passed as environment variables
echo "Logging in to Docker Hub..."
echo "${DOCKERHUB_TOKEN}" | docker login --username "${DOCKERHUB_USERNAME}" --password-stdin

# Pull the new image from Docker Hub
echo "Pulling new image: ${APP_IMAGE}:${APP_TAG}"
docker pull "${APP_IMAGE}:${APP_TAG}"

# Stop and restart the service with the new image
echo "Restarting service with docker compose..."
docker compose up -d

echo "Deployment to production finished."
