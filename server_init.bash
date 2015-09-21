#!/bin/bash

SECRET_KEY_BASE=$(bundle exec rake secret)

CLIENT_ROOT=/srv/app/ember-observer/client
SERVER_ROOT=/srv/app/ember-observer/server

USER=eo
GROUP=eo

WEB_USER=www-data
RUBY_VERSION=$(cat .ruby-version)
RUBY_GEMSET=$(cat .ruby-gemset)

PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)

#####################################################################

require_env_variable() {
	var_name=$1
	value="${!var_name}"

	if [[ -z "${value}" ]]; then
		echo "ERROR: Environment variable ${var_name} is not set" >&2
		exit 1
	fi
}

if [[ $# == 0 || $# > 2 ]]; then
	echo "USAGE: ./server_init.bash <host> [env file]" 2>&1
	exit 1
fi

DEPLOY_HOST=$1

[[ $# == 2 ]] && . $2

require_env_variable 'BACKUP_SNITCH_URL'
require_env_variable 'BUGSNAG_API_KEY'
require_env_variable 'EMBER_OBSERVER_DATABASE_PASSWORD'
require_env_variable 'FETCH_SNITCH_ID'
require_env_variable 'GITHUB_ACCESS_TOKEN'
require_env_variable 'MANDRILL_USERNAME'
require_env_variable 'MANDRILL_PASSWORD'
require_env_variable 'SUDO_PASSWORD'
require_env_variable 'UPDATE_SNITCH_ID'

ssh -T root@${DEPLOY_HOST} << END_SSH

# Create EO user
useradd -m -s /bin/bash -U eo
chpasswd <<< "${USER}:${SUDO_PASSWORD}"

# Add current local user's SSH key to eo user
mkdir ~eo/.ssh
chown eo.eo ~eo/.ssh
echo "${PUBLIC_KEY}" > ~eo/.ssh/authorized_keys

apt-get update
apt-get install postgresql postgresql-contrib postgresql-server-dev-all nginx redis-server git nodejs npm nodejs-legacy

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --ruby=${RUBY_VERSION}
source /usr/local/rvm/scripts/rvm
rvm gemset create "${RUBY_GEMSET}"

mkdir -p "${CLIENT_ROOT}/www/badges"
mkdir -p "${CLIENT_ROOT}/logs"
chown -R "${USER}:${GROUP}" "${CLIENT_ROOT}"
chown "${WEB_USER}" "${CLIENT_ROOT}/logs"

mkdir -p "${SERVER_ROOT}/shared/log"
chown -R "${USER}:${GROUP}" "${SERVER_ROOT}"

# create postgres user and database
sudo -u postgres psql <<< "create user ember_observer login password '${EMBER_OBSERVER_DATABASE_PASSWORD}'; create database ember_observer with owner ember_observer;"

# create nginx config
cat << END_OF_NGINX_CONFIG | tee /etc/nginx/sites-available/ember-observer > /dev/null
upstream ember-observer-server {
        server unix:${SERVER_ROOT}/shared/tmp/sockets/puma.sock fail_timeout=0;
}

server {
        listen 80;
        server_name emberobserver.com www.emberobserver.com;

        gzip on;
        gzip_types text/html text/css application/x-javascript application/json image/svg+xml;

        root ${CLIENT_ROOT}/www;
        access_log ${CLIENT_ROOT}/logs/access.log;
        error_log ${CLIENT_ROOT}/logs/error.log;

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
ln -s /etc/nginx/sites-available/ember-observer /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# trigger nginx reload
service nginx reload

# create logrotate config
cat << END_OF_LOGROTATE_CONFIG | tee /etc/logrotate.d/ember-observer > /dev/null
${CLIENT_ROOT}/logs/*.log {
        weekly
        missingok
        rotate 52
        compress
        delaycompress
        notifempty
        create 0640 ${WEB_USER} ${GROUP}
        sharedscripts
        prerotate
                if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
                        run-parts /etc/logrotate.d/httpd-prerotate; \
                fi \
        endscript
        postrotate
                [ -s /run/nginx.pid ] && kill -USR1 \`cat /run/nginx.pid\`
        endscript
}

${SERVER_ROOT}/log/*.log {
        daily
        missingok
        rotate 52
        compress
        delaycompress
        notifempty
        create 0644 ${USER} ${GROUP}
        sharedscripts
}
END_OF_LOGROTATE_CONFIG

cat << END_OF_ENV > "${SERVER_ROOT}/shared/.env"
SECRET_KEY_BASE=${SECRET_KEY_BASE}
EMBER_OBSERVER_DATABASE_PASSWORD="${EMBER_OBSERVER_DATABASE_PASSWORD}"
BUGSNAG_API_KEY=${BUGSNAG_API_KEY}
FETCH_SNITCH_URL=https://nosnch.in/${FETCH_SNITCH_ID}
FETCH_SNITCH_ID=${FETCH_SNITCH_ID}
UPDATE_SNITCH_URL=https://nosnch.in/${UPDATE_SNITCH_ID}
UPDATE_SNITCH_ID=${UPDATE_SNITCH_ID}
BACKUP_SNITCH_URL=${BACKUP_SNITCH_URL}
GITHUB_ACCESS_TOKEN=${GITHUB_ACCESS_TOKEN}
MANDRILL_USERNAME=${MANDRILL_USERNAME}
MANDRILL_PASSWORD=${MANDRILL_PASSWORD}
ADDON_BADGE_DIR=${CLIENT_ROOT}/www/badges
END_OF_ENV
chown eo.eo "${SERVER_ROOT}/shared/.env"

cat << END_OF_SUDOERS > /etc/sudoers.d/ember-observer
eo ALL=(ALL:ALL) ALL
eo ALL=(postgres) NOPASSWD:/usr/bin/psql
END_OF_SUDOERS
chmod 0440 /etc/sudoers.d/ember-observer

sed -e 's/^PermitRootLogin yes/PermitRootLogin no/' -i /etc/ssh/sshd_config
sed -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' -i /etc/ssh/sshd_config
service ssh reload

ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# generate SSH key for backups
ssh-keygen -f ~eo/.ssh/id_rsa_backup -N ''
echo "New SSH key for sending backups created. Add it to the authorized_keys file on the remote backup target!"

exit

END_SSH
