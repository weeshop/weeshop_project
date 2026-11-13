#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."
PREFIX="${SCRIPT_DIR#$(pwd)/}"
BRANCH="${2:-main}"
REMOTE="git@github.com:solody/drupal-dev-helper.git"

# git-subtree uses diff-index without refresh; avoid false "has modifications".
git update-index -q --refresh

echo "Operating $1 for $PREFIX subtree (branch: $BRANCH)..."

case $1 in
  "add" )
    git subtree add --prefix="$PREFIX" "$REMOTE" "$BRANCH"
    ;;
  "pull" )
    git fetch "$REMOTE" "$BRANCH" || exit $?
    if git merge-base HEAD FETCH_HEAD >/dev/null 2>&1; then
      git subtree merge --prefix="$PREFIX" FETCH_HEAD
    else
      # Local prefix was never subtree-add'ed (e.g. push-first); link histories.
      git merge --no-ff -Xsubtree="$PREFIX" --allow-unrelated-histories \
        -m "Merge '$PREFIX/' from $REMOTE $BRANCH" FETCH_HEAD
    fi
    ;;
  "push" )
    git subtree push --prefix="$PREFIX" "$REMOTE" "$BRANCH"
    ;;
  * )
    echo "Usage: $0 {add|pull|push} [branch]"
    exit 1
    ;;
esac
