#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."
PREFIX="${SCRIPT_DIR#$(pwd)/}"
BRANCH="${2:-main}"

echo "Operating $1 for $PREFIX subtree (branch: $BRANCH)..."

case $1 in
  "add" )
    git subtree add --prefix="$PREFIX" git@github.com:solody/drupal-dev-helper.git "$BRANCH"
    ;;
  "pull" )
    git subtree pull --prefix="$PREFIX" git@github.com:solody/drupal-dev-helper.git "$BRANCH"
    ;;
  "push" )
    git subtree push --prefix="$PREFIX" git@github.com:solody/drupal-dev-helper.git "$BRANCH"
    ;;
  * )
    echo "Usage: $0 {add|pull|push} [branch]"
    exit 1
    ;;
esac
