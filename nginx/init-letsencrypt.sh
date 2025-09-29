#!/bin/bash
# --- IMPORTANT: ACTION REQUIRED ---
# Replace the placeholder IP address and email below.
#
domains=(pacmusic.15.134.86.46.nip.io stg.pacmusic.15.134.86.46.nip.io)
email="mikha.kristofer@gmail.com"
data_path="./certbot_data"

# Check for existing data
if [ -d "$data_path" ]; then
  echo ">>> Existing data found. Skipping certificate generation."
  echo ">>> Starting all services ..."
  docker compose up -d --build
  exit 0
fi

echo "### Creating temporary files for initial validation ..."
mkdir -p "$data_path/www"
# Create a temporary NGINX config for validation
cat > "$data_path/validation-nginx.conf" <<EOF
server {
    listen 80;
    server_name ${domains[0]} ${domains[1]};

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 404;
    }
}
EOF

echo "### Starting temporary NGINX for validation ..."
docker compose run --rm --service-ports -d \
  -v "$data_path/validation-nginx.conf:/etc/nginx/conf.d/default.conf" \
  -v "$data_path/www:/var/www/certbot" \
  nginx

echo "### Requesting Let's Encrypt certificates ..."
#Join domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

docker compose run --rm certbot certonly --webroot -w /var/www/certbot \
  $email_arg \
  $domain_args \
  --agree-tos \
  --force-renewal
  
echo "### Stopping temporary NGINX ..."
docker compose down

echo "### Downloading recommended TLS parameters ..."
mkdir -p "$data_path/conf"
curl -s "https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf" > "$data_path/conf/options-ssl-nginx.conf"
curl -s "https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem" > "$data_path/conf/ssl-dhparams.pem"
echo

echo "### Starting final application stack ..."
docker compose up -d --build
