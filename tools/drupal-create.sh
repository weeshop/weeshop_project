#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

ENV_FILE="../.env"

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

mkdir -p "$DRUPAL_PATH"

./docker-up.sh

# Run composer create-project drupal/recommended-project drupal in the cli container
./docker-exec.sh -u application cli composer create-project drupal/recommended-project:^${DRUPAL_VERSION} /app