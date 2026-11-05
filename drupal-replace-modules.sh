#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

ENV_FILE="../.env"
VCS_MODULES_FILE="../drupal-vcs-modules.sh"

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

# shellcheck disable=SC1091
source ./try-command.sh
# shellcheck disable=SC1091
source "$VCS_MODULES_FILE"

if [[ -z "${DRUPAL_VCS_MODULES:-}" ]]; then
  echo "DRUPAL_VCS_MODULES is empty in ${VCS_MODULES_FILE}." >&2
  echo "Add modules with: ./drupal-add-vcs-module.sh <module_name> <branch> [git_url]" >&2
  exit 1
fi

DRUPAL_ROOT="$(cd "$DRUPAL_PATH" && pwd)"
export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o BatchMode=yes -o ConnectTimeout=10}"

# Each line: <module_name> <branch> [git_url]  (branch required; same as drupal-add-vcs-module.sh)
# Use FD 3 so commands inside the loop cannot consume the module list on stdin.
while read -r module_name module_branch git_url <&3; do
  [[ -z "${module_name:-}" || "$module_name" =~ ^# ]] && continue

  if [[ -z "${module_branch:-}" ]]; then
    echo "Branch is required for module ${module_name} in ${VCS_MODULES_FILE}." >&2
    exit 1
  fi

  git_url="${git_url:-git@github.com:solody/drupal-${module_name}.git}"
  target="${DRUPAL_ROOT}/web/modules/contrib/${module_name}"

  echo "Replacing ${target} with ${git_url} (branch ${module_branch})"

  # Clone on the host to avoid docker exec + timeout signal issues.
  try_command \
    "rm -rf '${target}' && git clone -b '${module_branch}' --progress '${git_url}' '${target}'" \
    60
done 3<<< "$DRUPAL_VCS_MODULES"
