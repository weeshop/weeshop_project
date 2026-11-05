#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

ENV_FILE="../.env"

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

MYSQL_DATA_DIR="${DATA_PATH}/mysql"
FILES_DIR="${DRUPAL_PATH}/web/sites/default/files"

echo "Stopping containers..."
./docker-down.sh

echo "Removing MySQL data: ${MYSQL_DATA_DIR}"
sudo rm -rf "${MYSQL_DATA_DIR}"

echo "Removing public files: ${FILES_DIR}"
if [[ -d "${FILES_DIR}" ]]; then
  sudo rm -rf "${FILES_DIR:?}"/*
  # Keep the directory itself for the next install.
  sudo mkdir -p "${FILES_DIR}"
else
  mkdir -p "${FILES_DIR}"
fi

echo "Site data removed. Run ./docker-up.sh and ./drupal-install.sh to reinstall."
