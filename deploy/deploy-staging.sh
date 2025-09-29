#!/bin/bash
echo "Starting deployment to staging..."
cat <<EOF > .env
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=${POSTGRES_DB}
EOF
git pull origin main
if [ ! -d "./certbot_data/conf/live/" ]; then
  echo "Performing first-time setup for SSL certificates..."
  chmod +x ./nginx/init-letsencrypt.sh
  sudo ./nginx/init-letsencrypt.sh
else
  echo "Updating existing services..."
  docker compose up -d --build
fi
echo "Deployment to staging finished."
