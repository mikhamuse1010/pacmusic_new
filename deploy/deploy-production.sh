#!/bin/bash
echo "Starting deployment to production..."

# Create a .env file for the production environment
echo "Creating .env file..."
cat <<EOL > .env
APP_IMAGE=${APP_IMAGE}
APP_TAG=${APP_TAG}
MINIO_ENDPOINT=${MINIO_ENDPOINT}
MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY}
MINIO_SECRET_KEY=${MINIO_SECRET_KEY}
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=${POSTGRES_DB}
APP_PROD_PORT_1=${APP_PROD_PORT_1}
APP_PROD_PORT_2=${APP_PROD_PORT_2}
EOL

# Log in to Docker Hub
echo "Logging in to Docker Hub..."
echo "${DOCKERHUB_TOKEN}" | docker login --username "${DOCKERHUB_USERNAME}" --password-stdin

# Pull the new image from Docker Hub
echo "Pulling new image: ${APP_IMAGE}:${APP_TAG}"
docker pull "${APP_IMAGE}:${APP_TAG}"

# Clean up old containers and networks before starting new ones
echo "Cleaning up old containers..."
docker compose -f docker-compose.yml -f docker-compose.prod.yml --project-name production down --remove-orphans

# Stop and restart all services using the base and production-specific compose files
echo "Restarting production services..."
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

echo "Deployment to production finished."
