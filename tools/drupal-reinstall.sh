#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

ENV_FILE="../.env"
COMPOSE_FILES=(-f docker-compose.yml)

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

./remove-site-data.sh && \
./docker-up.sh && \
./drupal-install.sh
