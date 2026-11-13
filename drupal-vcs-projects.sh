#!/bin/bash
# Auto-maintained by tools/drupal-add-vcs-project.sh. Sourced by tools/drupal-replace-projects.sh.
# Each line: <project_name> <branch> [git_url]  (branch is required)
# Default git_url when omitted: git@github.com:solody/drupal-<project_name>.git
#
# Copy to project root:
#   cp tools/drupal-vcs-projects.sh.dist drupal-vcs-projects.sh

DRUPAL_VCS_MODULES="$(cat <<'EOF'
migrate_inline_image 1.0.x
product_adverts 1.0.x
adverts 1.0.x
enhanced_product 1.0.x
enhanced_store 1.0.x
weeshop_demo 2.0.x git@github.com:weeshop/weeshop_demo.git
weeshop_molla_supports 1.0.x git@github.com:weeshop/weeshop_molla_supports.git
EOF
)"

DRUPAL_VCS_THEMES="$(cat <<'EOF'
weeshop_molla 1.0.x git@github.com:weeshop/weeshop_molla.git
EOF
)"

DRUPAL_VCS_PROFILES="$(cat <<'EOF'
weeshop 1.0.x git@github.com:weeshop/WeeShop.git
EOF
)"
