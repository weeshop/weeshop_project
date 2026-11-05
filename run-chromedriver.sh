#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

ENV_FILE="../.env"

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

: "${CHROME_DRIVER_PATH:?CHROME_DRIVER_PATH is not set}"
: "${CHROME_DRIVER_PORT:?CHROME_DRIVER_PORT is not set}"
: "${CHROME_DRIVER_ALLOW_IPS:?CHROME_DRIVER_ALLOW_IPS is not set}"
: "${CHROME_DRIVER_ALLOW_HOSTS:?CHROME_DRIVER_ALLOW_HOSTS is not set}"

exec "$CHROME_DRIVER_PATH" \
  --port="$CHROME_DRIVER_PORT" \
  --allowed-ips="$CHROME_DRIVER_ALLOW_IPS" \
  --allowed-origins="$CHROME_DRIVER_ALLOW_HOSTS"
