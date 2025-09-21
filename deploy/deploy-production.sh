#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --------------------------------------------------------------------------
# This script is executed on the production server.
# It pulls the correct, version-tagged Docker image from Docker Hub
# and restarts the service using docker-compose.
# --------------------------------------------------------------------------

echo "Starting deployment to production..."

# Create a .env file to hold the application's configuration.
# This ensures sensitive data is not stored in the repository.
echo "Creating .env file..."
cat <<EOF > .env
APP_PROD_PORT=${APP_PROD_PORT}
MINIO_PROD_ENDPOINT=${MINIO_PROD_ENDPOINT}
MINIO_PROD_ACCESS_KEY=${MINIO_PROD_ACCESS_KEY}
MINIO_PROD_SECRET_KEY=${MINIO_PROD_SECRET_KEY}
APP_IMAGE=${APP_IMAGE}
APP_TAG=${APP_TAG}
EOF

# Log in to Docker Hub. The password is provided as an environment variable
# from GitHub secrets for security.
echo "Logging in to Docker Hub..."
echo "${DOCKERHUB_TOKEN}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin

# Pull the specific, version-tagged image from Docker Hub.
# This is safer than building from source on the production server.
echo "Pulling image ${APP_IMAGE}:${APP_TAG} from Docker Hub..."
docker pull "${APP_IMAGE}:${APP_TAG}"

# Stop the current running containers and start the new ones.
# The `-d` flag runs the containers in detached mode (in the background).
# docker-compose will automatically use the new image we just pulled.
echo "Restarting services with the new image..."
docker compose up -d

echo "Deployment to production finished successfully!"
