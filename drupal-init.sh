#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

ENV_FILE="../.env"

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

mkdir -p "$DRUPAL_PATH"

cp phpcs.xml.dist "${DRUPAL_PATH}/phpcs.xml"
# shellcheck disable=SC2016
envsubst '${SIMPLETEST_BASE_URL} ${SIMPLETEST_DB} ${BROWSERTEST_OUTPUT_BASE_URL} ${MINK_DRIVER_ARGS_WEBDRIVER}' \
  < phpunit.xml.dist > "${DRUPAL_PATH}/phpunit.xml"

# Copy Drupal's example.gitignore to the project root and rewrite paths for this layout.
PROJECT_ROOT="$(cd .. && pwd)"
DRUPAL_ABS="$(cd "$DRUPAL_PATH" && pwd)"
DRUPAL_REL="${DRUPAL_ABS#"$PROJECT_ROOT"/}"
GITIGNORE_SRC="${DRUPAL_PATH}/web/example.gitignore"
GITIGNORE_DEST="${PROJECT_ROOT}/.gitignore"
sed \
  -e "s|^# core$|# /${DRUPAL_REL}/web/core|" \
  -e "s|^/vendor/$|/${DRUPAL_REL}/vendor/|" \
  -e "s|^sites/|/${DRUPAL_REL}/web/sites/|" \
  -e "s|^!sites/|!/${DRUPAL_REL}/web/sites/|" \
  "$GITIGNORE_SRC" > "$GITIGNORE_DEST"

./docker-exec.sh -u application cli composer config minimum-stability dev
./docker-exec.sh -u application cli composer config process-timeout 36000
./docker-exec.sh -u application cli composer config preferred-install dist
./docker-exec.sh -u application cli composer config allow-plugins.symfony/runtime true
./docker-exec.sh -u application cli composer config allow-plugins.wikimedia/composer-merge-plugin true
./docker-exec.sh -u application cli composer config allow-plugins.cweagans/composer-patches true

./docker-exec.sh -u application cli composer require -W \
  drush/drush \
  wikimedia/composer-merge-plugin

./docker-exec.sh -u application cli composer config --json extra.merge-plugin "{
  \"include\": [
    \"web/modules/*/composer.json\",
    \"web/profiles/${DRUPAL_PROFILE}/composer.json\",
    \"web/profiles/${DRUPAL_PROFILE}/modules/*/composer.json\"
  ],
  \"recurse\": false,
  \"replace\": false,
  \"merge-extra\": false
}"

#  mglaman/drupal-check is removed because it is not compatible with mglaman/phpstan-drupal 2.x.
./docker-exec.sh -u application cli composer require --dev -W \
  cweagans/composer-patches \
  dealerdirect/phpcodesniffer-composer-installer \
  drupal/core-dev \
  drupal/devel \
  drupal/devel_entity_updates \
  mglaman/phpstan-drupal \
  phpspec/prophecy-phpunit \
  phpstan/extension-installer \
  drupal/upgrade_status \
  palantirnet/drupal-rector
