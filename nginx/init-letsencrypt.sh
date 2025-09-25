#!/bin/bash

# --- IMPORTANT: ACTION REQUIRED ---
# Replace the placeholder IP address below with your actual EC2 server's Public IP address.
# Replace the placeholder email with your actual email address.
#
# For example, if your IP is 15.134.86.46, the domains should be:
# domains=(pacmusic.15.134.86.46.nip.io stg.pacmusic.15.134.86.46.nip.io)
#
domains=(pacmusic.15.134.86.46.nip.io stg.pacmusic.15.134.86.46.nip.io)
email="mikha.kristofer@example.com"
rsa_key_size=4096
data_path="./certbot_data"
staging=0 # Set to 1 if you're testing your setup to avoid hitting rate limits

if [ -d "$data_path" ]; then
  echo ">>> Existing data found for $domains. Recreating certificates ..."
fi

echo "### Downloading recommended TLS parameters ..."
mkdir -p "$data_path/conf"
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
echo

echo "### Creating dummy certificates for all domains ..."
for domain in "${domains[@]}"; do
  path="/etc/letsencrypt/live/$domain"
  mkdir -p "$data_path/conf/live/$domain"
  docker compose run --rm --entrypoint "\
    openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
      -keyout '$path/privkey.pem' \
      -out '$path/fullchain.pem' \
      -subj '/CN=localhost'" certbot
done
echo

echo "### Starting nginx ..."
docker compose up --force-recreate -d nginx
echo

echo "### Deleting dummy certificates for all domains ..."
for domain in "${domains[@]}"; do
    docker compose run --rm --entrypoint "\
      rm -Rf /etc/letsencrypt/live/$domain && \
      rm -Rf /etc/letsencrypt/archive/$domain && \
      rm -Rf /etc/letsencrypt/renewal/$domain.conf" certbot
done
echo

echo "### Requesting Let's Encrypt certificates for all domains ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Reloading nginx ..."
docker compose exec nginx nginx -s reload

echo "### Starting all services ..."
docker compose up -d --build
