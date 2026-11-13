#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

ENV_FILE="../.env"
VCS_PROJECTS_FILE="../drupal-vcs-projects.sh"

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

# shellcheck disable=SC1091
source ./try-command.sh
# shellcheck disable=SC1091
source "$VCS_PROJECTS_FILE"

if [[ -z "${DRUPAL_VCS_MODULES:-}${DRUPAL_VCS_THEMES:-}${DRUPAL_VCS_PROFILES:-}" ]]; then
  echo "No VCS projects listed in ${VCS_PROJECTS_FILE}." >&2
  echo "Add projects with: ./drupal-add-vcs-project.sh [--type module|theme|profile] <name> <branch> [git_url]" >&2
  exit 1
fi

DRUPAL_ROOT="$(cd "$DRUPAL_PATH" && pwd)"
export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o BatchMode=yes -o ConnectTimeout=10}"

# Replace composer-installed contrib projects with git checkouts.
# Each line: <project_name> <branch> [git_url]  (branch required; same as drupal-add-vcs-project.sh)
# Use FD 3 so commands inside the loop cannot consume the project list on stdin.
replace_vcs_projects() {
  local project_type="$1"
  local contrib_subdir="$2"
  local list="$3"
  local project_name project_branch git_url target

  while read -r project_name project_branch git_url <&3; do
    [[ -z "${project_name:-}" || "$project_name" =~ ^# ]] && continue

    if [[ -z "${project_branch:-}" ]]; then
      echo "Branch is required for ${project_type} ${project_name} in ${VCS_PROJECTS_FILE}." >&2
      exit 1
    fi

    git_url="${git_url:-git@github.com:solody/drupal-${project_name}.git}"
    target="${DRUPAL_ROOT}/web/${contrib_subdir}/contrib/${project_name}"

    echo "Replacing ${target} with ${git_url} (branch ${project_branch})"

    # Clone on the host to avoid docker exec + timeout signal issues.
    try_command \
      "rm -rf '${target}' && git clone -b '${project_branch}' --progress '${git_url}' '${target}'" \
      60
  done 3<<< "$list"
}

replace_vcs_projects module modules "${DRUPAL_VCS_MODULES:-}"
replace_vcs_projects theme themes "${DRUPAL_VCS_THEMES:-}"
replace_vcs_projects profile profiles "${DRUPAL_VCS_PROFILES:-}"
