#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."
PREFIX="${SCRIPT_DIR#$(pwd)/}"

echo Operating $1 for $PREFIX subtree...

case $1 in
  "add" )
    git subtree add --prefix="$PREFIX" git@github.com:solody/drupal-dev-helper.git main --squash
    ;;
  "pull" )
    git subtree pull --prefix="$PREFIX" git@github.com:solody/drupal-dev-helper.git main --squash
    ;;
  "push" )
    git subtree push --prefix="$PREFIX" git@github.com:solody/drupal-dev-helper.git main
    ;;
  * )
    echo "Usage: $0 {add|pull|push}"
    exit 1
    ;;
esac
