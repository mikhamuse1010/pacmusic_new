#!/bin/bash
echo "🚀 Starting deployment to production..."
cd /home/ubuntu/production || exit
echo "📝 Creating production .env file..."
cat > .env << EOF
APP_IMAGE=${APP_IMAGE}
APP_TAG=${APP_TAG}
APP_PROD_PORT=${APP_PROD_PORT}
MINIO_PROD_ENDPOINT=${MINIO_PROD_ENDPOINT}
MINIO_PROD_ACCESS_KEY=${MINIO_PROD_ACCESS_KEY}
MINIO_PROD_SECRET_KEY=${MINIO_PROD_SECRET_KEY}
EOF
echo "🚚 Pulling image ${APP_IMAGE}:${APP_TAG} from Docker Hub..."
docker pull ${APP_IMAGE}:${APP_TAG}
echo "📦 Deploying production container..."
docker compose up -d pacmusic-prod
echo "🧹 Cleaning up old Docker images..."
docker image prune -f
echo "✅ Production deployment complete!"
