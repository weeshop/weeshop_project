#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

ENV_FILE="../.env"

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

mkdir -p "$DRUPAL_PATH"

./docker-exec.sh -u application cli composer config minimum-stability dev
./docker-exec.sh -u application cli composer config allow-plugins.symfony/runtime true
./docker-exec.sh -u application cli composer config allow-plugins.wikimedia/composer-merge-plugin true
./docker-exec.sh -u application cli composer config allow-plugins.cweagans/composer-patches true

./docker-exec.sh -u application cli composer require -W \
  drush/drush \
  wikimedia/composer-merge-plugin

./docker-exec.sh -u application cli composer require --dev -W \
  cweagans/composer-patches \
  dealerdirect/phpcodesniffer-composer-installer \
  drupal/core-dev \
  drupal/devel \
  drupal/devel_entity_updates \
  mglaman/drupal-check \
  mglaman/phpstan-drupal \
  phpspec/prophecy-phpunit \
  phpstan/extension-installer \
  drupal/upgrade_status \
  palantirnet/drupal-rector
