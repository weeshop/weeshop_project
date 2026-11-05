#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

ENV_FILE="../.env"

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

# Run composer create-project drupal/recommended-project drupal in the cli container
./docker-exec.sh -u application cli vendor/bin/drush site:install standard \
                                    install_configure_form.enable_update_status_emails=NULL \
                                    --db-url=mysql://root:${MYSQL_ROOT_PASSWORD}@db:3306/${MYSQL_DATABASE} \
                                    --locale=en \
                                    --site-name=${DRUPAL_SITE_NAME} \
                                    --site-mail=${DRUPAL_SITE_EMAIL} \
                                    --site-pass=${DRUPAL_SITE_PASSWORD} \
                                    --account-name=${DRUPAL_ADMIN_USER} \
                                    --account-mail=${DRUPAL_ADMIN_EMAIL} \
                                    --account-pass=${DRUPAL_ADMIN_PASSWORD}