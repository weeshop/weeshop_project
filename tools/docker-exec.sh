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

usage() {
  echo "Usage: $0 [exec options] SERVICE COMMAND [ARGS...]" >&2
  echo "       $0 [exec options] SERVICE 'cmd1 && cmd2'" >&2
  exit 1
}

# Parse docker compose exec options that may appear before SERVICE.
exec_opts=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--detach|-i|--interactive|-T|--no-TTY|-p|--privileged|--dry-run)
      exec_opts+=("$1")
      shift
      ;;
    -e|--env|--env-file|--detach-keys|--index|-u|--user|-w|--workdir)
      [[ $# -ge 2 ]] || usage
      exec_opts+=("$1" "$2")
      shift 2
      ;;
    --env=*|--env-file=*|--detach-keys=*|--index=*|--user=*|--workdir=*)
      exec_opts+=("$1")
      shift
      ;;
    -u?*|-w?*|-e?*|-p?*|-d?*|-i?*|-T?*)
      exec_opts+=("$1")
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      ;;
    *)
      break
      ;;
  esac
done

[[ $# -ge 2 ]] || usage

service="$1"
shift

echo "Executing command in container: $service $*"

# -T: never allocate a TTY (required for scripted/non-interactive use)
compose=(docker compose --project-name "$PROJECT_NAME" --env-file "$ENV_FILE" "${COMPOSE_FILES[@]}")

# A single COMMAND string is run via sh -c so shell operators work when quoted:
#   ./tools/docker-exec.sh cli 'echo pwd && pwd'
# Multi-arg form keeps argv passthrough (no shell interpretation):
#   ./tools/docker-exec.sh -u application cli composer require pkg
if [[ $# -eq 1 ]]; then
  "${compose[@]}" exec -T "${exec_opts[@]}" "$service" sh -c "$1"
else
  "${compose[@]}" exec -T "${exec_opts[@]}" "$service" "$@"
fi
