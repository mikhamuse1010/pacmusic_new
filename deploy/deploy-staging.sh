#!/bin/bash
echo "🚀 Starting deployment to staging..."
cd /home/ubuntu/staging || exit
echo "🚚 Pulling latest code from GitHub..."
git pull origin main
echo "📝 Creating staging .env file..."
cat > .env << EOF
APP_STG_PORT=${APP_STG_PORT}
MINIO_STG_ENDPOINT=${MINIO_STG_ENDPOINT}
MINIO_STG_ACCESS_KEY=${MINIO_STG_ACCESS_KEY}
MINIO_STG_SECRET_KEY=${MINIO_STG_SECRET_KEY}
EOF
echo "📦 Building and deploying staging container..."
docker compose up --build -d pacmusic-stg
echo "🧹 Cleaning up old Docker images..."
docker image prune -f
echo "✅ Staging deployment complete!"
