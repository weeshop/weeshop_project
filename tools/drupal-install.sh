#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

ENV_FILE="../.env"
COMPOSE_FILES=(-f docker-compose.yml)

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

if [[ "${PHP_OPCACHE:-}" == "true" ]]; then
  COMPOSE_FILES+=(-f docker-compose.opcache.yml)
fi
if [[ "${PHP_JIT:-}" == "true" ]]; then
  COMPOSE_FILES+=(-f docker-compose.jit.yml)
fi
if [[ "${SSL:-}" == "true" ]]; then
  COMPOSE_FILES+=(-f docker-compose.ssl.yml)
fi

echo "Waiting for database on db:3306 ..."
# Avoid wrapping docker exec in `timeout` (can hang with uutils timeout).
# --connect-timeout keeps each probe short while MySQL is still initializing.
until ./docker-exec.sh db \
  mysqladmin ping \
    -h127.0.0.1 \
    -uroot \
    --password="${MYSQL_ROOT_PASSWORD}" \
    --connect-timeout=2 \
    --silent \
    >/dev/null 2>&1
do
  sleep 2
done
echo "Database is ready."

SITE_DEFAULT="${DRUPAL_PATH}/web/sites/default"
# Drupal locks sites/default to 0555 after install; reopen for settings.php.
chmod u+w "${SITE_DEFAULT}"
mkdir -p "${SITE_DEFAULT}/files"

./docker-exec.sh -u application cli vendor/bin/drush site:install "${DRUPAL_PROFILE}" \
  install_configure_form.enable_update_status_emails=NULL \
  --db-url="mysql://root:${MYSQL_ROOT_PASSWORD}@db:3306/${MYSQL_DATABASE}" \
  --locale=en \
  --site-name="${DRUPAL_SITE_NAME}" \
  --site-mail="${DRUPAL_SITE_EMAIL}" \
  --site-pass="${DRUPAL_SITE_PASSWORD}" \
  --account-name="${DRUPAL_ADMIN_USER}" \
  --account-mail="${DRUPAL_ADMIN_EMAIL}" \
  --account-pass="${DRUPAL_ADMIN_PASSWORD}"
