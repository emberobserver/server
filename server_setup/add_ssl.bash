#!/bin/bash

CLIENT_ROOT=/srv/app/ember-observer/client
SERVER_ROOT=/srv/app/ember-observer/server

#####################################################################

WORK_DIR=$(mktemp -d)

cleanup() {
  rm -rf "${WORK_DIR}"
}

trap cleanup EXIT

if [[ $# == 0 || $# > 2 ]]; then
  echo "USAGE: ./add_ssl.bash <old host> <new host>" 2>&1
  exit 1
fi

OLD_HOST=$1
DEPLOY_HOST=$2

scp -r root@${OLD_HOST}:/etc/letsencrypt "${WORK_DIR}/"
scp -r "${WORK_DIR}/letsencrypt" root@${DEPLOY_HOST}:/etc/

ssh -T root@${DEPLOY_HOST} << END_SSH

apt-get update
apt-get -y install letsencrypt

# Prep for SSL
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# create SSL config for nginx
cat << END_OF_NGINX_SSL_CONFIG | tee /etc/nginx/ssl.conf > /dev/null
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the "preload" directive if you understand the implications.
#add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;

ssl_dhparam /etc/ssl/certs/dhparam.pem;
END_OF_NGINX_SSL_CONFIG

# now create app-specific nginx config
cat << END_OF_NGINX_CONFIG | tee /etc/nginx/sites-available/ember-observer > /dev/null
upstream ember-observer-server {
  server unix:${SERVER_ROOT}/shared/tmp/sockets/puma.sock fail_timeout=0;
}

server {
  listen 80;
  server_name emberobserver.com www.emberobserver.com ${DEPLOY_HOST};

  return 301 https://\\\$host\\\$request_uri;
}

server {
  listen 443;
  server_name emberobserver.com www.emberobserver.com ${DEPLOY_HOST};

  ssl on;
  ssl_certificate /etc/letsencrypt/live/emberobserver.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/emberobserver.com/privkey.pem;
  include /etc/nginx/ssl.conf;

  gzip on;
  gzip_types text/html text/css application/x-javascript application/json image/svg+xml;

  root ${CLIENT_ROOT}/www;
  access_log ${CLIENT_ROOT}/logs/access.log;
  error_log ${CLIENT_ROOT}/logs/error.log;

  client_max_body_size 1G;

  location /api {
    proxy_set_header X-Forwarded-For \\\$proxy_add_x_forwarded_for;
    proxy_set_header Host \\\$http_host;
    proxy_redirect off;
    proxy_pass http://ember-observer-server;
  }

  location /badges {
    add_header Cache-Control no-cache;
  }

  location / {
    try_files \\\$uri \\\$uri/ /index.html?/\\\$request_uri;
  }
}
END_OF_NGINX_CONFIG

# trigger nginx reload
service nginx reload

# Add cron job to auto-renew SSL cert
echo << END_OF_LETSENCRYPT_CRON | tee /etc/cron.daily/letsencrypt-renew 2>/dev/null
#!/bin/sh

/opt/letsencrypt/letsencrypt-auto renew >> /var/log/le-renew.log
service nginx reload
END_OF_LETSENCRYPT_CRON

# Disable root login
# sed -e 's/^PermitRootLogin yes/PermitRootLogin no/' -i /etc/ssh/sshd_config
# service ssh reload

exit

END_SSH

echo "Finished. You can now re-disable root login on the old host and proceed with"
echo "the rest of the migration process (deploy code, migrate DB, update DNS)"
