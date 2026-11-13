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

./docker-exec.sh -u application cli composer -vvv "$@"
