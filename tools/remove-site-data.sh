#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

ENV_FILE="../.env"

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

MYSQL_DATA_DIR="${DATA_PATH}/mysql"
SITE_DEFAULT="${DRUPAL_PATH}/web/sites/default"
FILES_DIR="${SITE_DEFAULT}/files"

echo "Stopping containers..."
./docker-down.sh

echo "Removing MySQL data: ${MYSQL_DATA_DIR}"
sudo rm -rf "${MYSQL_DATA_DIR}"

echo "Removing site settings and public files under: ${SITE_DEFAULT}"
# Drupal may have locked the directory to 0555 after install.
if [[ -d "${SITE_DEFAULT}" ]]; then
  chmod u+w "${SITE_DEFAULT}" || sudo chmod u+w "${SITE_DEFAULT}"
fi
rm -f "${SITE_DEFAULT}/settings.php" "${SITE_DEFAULT}/settings.local.php" "${SITE_DEFAULT}/services.yml"
if [[ -d "${FILES_DIR}" ]]; then
  sudo rm -rf "${FILES_DIR:?}"/*
  # Keep the directory itself for the next install.
  sudo mkdir -p "${FILES_DIR}"
else
  mkdir -p "${FILES_DIR}"
fi

echo "Site data removed. Run ./docker-up.sh and ./drupal-install.sh to reinstall."
