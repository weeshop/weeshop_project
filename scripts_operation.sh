#!/bin/bash

echo Operating $1 for scripts subtree...

case $1 in
  "add" )
    git subtree add --prefix=scripts git@github.com:solody/drupal-dev-helper.git main --squash
    ;;
  "pull" )
    git subtree pull --prefix=scripts git@github.com:solody/drupal-dev-helper.git main --squash
    ;;
  "push" )
    git subtree push --prefix=scripts git@github.com:solody/drupal-dev-helper.git main
    ;;
  * )
    echo "Usage: $0 {add|pull|push}"
    exit 1
    ;;
esac
