#!/bin/bash

# --- IMPORTANT: ACTION REQUIRED ---
# Replace the placeholder IP address below with your actual EC2 server's Public IP address.
# Replace the placeholder email with your actual email address.
#
# For example, if your IP is 15.134.86.46, the domains should be:
# domains=(pacmusic.15.134.86.46.nip.io stg.pacmusic.15.134.86.46.nip.io)
#
domains=(pacmusic.15.134.86.46.nip.io stg.pacmusic.15.134.86.46.nip.io)
email="mikha.kristoferexample.com"
rsa_key_size=4096
data_path="./certbot_data"

if [ -d "$data_path" ]; then
  echo ">>> Existing data found for $domains. Recreating certificates ..."
fi

echo "### Downloading recommended TLS parameters ..."
mkdir -p "$data_path/conf"
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
echo

echo "### Creating dummy certificate for $domains ..."
path="/etc/letsencrypt/live/${domains[0]}"
mkdir -p "$data_path/conf/live/${domains[0]}"
docker compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot
echo

echo "### Starting NGINX ..."
docker compose up --force-recreate -d nginx
echo

echo "### Deleting dummy certificate for $domains ..."
docker compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/${domains[0]}" certbot
echo

echo "### Requesting Let's Encrypt certificate for $domains ..."
# Join domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

docker compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Reloading NGINX ..."
docker compose exec nginx nginx -s reload

echo "### Starting all services ..."
docker compose up -d --build
