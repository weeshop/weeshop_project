#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

ENV_FILE="../.env"

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

usage() {
  echo "Usage: $0 <profile_name>" >&2
  echo "Copies Drupal core's standard profile to ${DRUPAL_PATH}/web/profiles/<profile_name>." >&2
  echo "Example: $0 ztb" >&2
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

PROFILE="$1"

if [[ ! "$PROFILE" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Invalid profile name '${PROFILE}': use a Drupal machine name (e.g. my_site)." >&2
  exit 1
fi

if [[ "$PROFILE" == "standard" ]]; then
  echo "Profile name cannot be 'standard'." >&2
  exit 1
fi

SRC="${DRUPAL_PATH}/web/core/profiles/standard"
DEST="${DRUPAL_PATH}/web/profiles/${PROFILE}"

if [[ ! -d "$SRC" ]]; then
  echo "Source profile not found: ${SRC}" >&2
  exit 1
fi

if [[ -e "$DEST" ]]; then
  echo "Destination already exists: ${DEST}" >&2
  exit 1
fi

# my_site -> MySite
to_pascal() {
  local IFS='_'
  # shellcheck disable=SC2206
  local parts=($1)
  local out="" part
  for part in "${parts[@]}"; do
    out+="$(printf '%s' "${part:0:1}" | tr '[:lower:]' '[:upper:]')${part:1}"
  done
  printf '%s' "$out"
}

PROFILE_PASCAL="$(to_pascal "$PROFILE")"

echo "Copying ${SRC} -> ${DEST}"
cp -a "$SRC" "$DEST"

# Rename files/dirs whose names contain standard/Standard (depth-first).
while IFS= read -r -d '' path; do
  dir="$(dirname "$path")"
  base="$(basename "$path")"
  new_base="${base//standard/${PROFILE}}"
  new_base="${new_base//Standard/${PROFILE_PASCAL}}"
  if [[ "$new_base" != "$base" ]]; then
    mv "$path" "${dir}/${new_base}"
  fi
done < <(find "$DEST" -depth -print0)

# Rewrite file contents: machine name + PascalCase class/namespace tokens.
while IFS= read -r -d '' file; do
  [[ -f "$file" ]] || continue
  [[ -L "$file" ]] && continue
  sed -i \
    -e "s/standard/${PROFILE}/g" \
    -e "s/Standard/${PROFILE_PASCAL}/g" \
    "$file"
done < <(find "$DEST" -type f -print0)

INFO_YML="${DEST}/${PROFILE}.info.yml"

# Human-readable label in .info.yml (my_site -> My Site).
PROFILE_LABEL="${PROFILE//_/ }"
PROFILE_LABEL="$(printf '%s' "${PROFILE_LABEL}" | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')"
sed -i "s/^name: .*/name: ${PROFILE_LABEL}/" "${INFO_YML}"

# Core profiles use "version: VERSION"; custom profiles need core_version_requirement.
CORE_REQ="^${DRUPAL_VERSION%%.*}"
if grep -q '^version: VERSION$' "${INFO_YML}"; then
  sed -i "s/^version: VERSION$/core_version_requirement: ${CORE_REQ}/" "${INFO_YML}"
elif ! grep -q '^core_version_requirement:' "${INFO_YML}"; then
  sed -i "/^type: profile$/a core_version_requirement: ${CORE_REQ}" "${INFO_YML}"
fi

echo "Generated profile: ${DEST}"
echo "Set DRUPAL_PROFILE=${PROFILE} in .env to install with it."
