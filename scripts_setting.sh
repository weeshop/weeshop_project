#!/bin/bash
# Sample settings for scripts. Copy this file to scripts/../scripts_setting.sh and modify as needed.
export DRUPAL_PATH=./drupal
export DRUPAL_MODULES_TO_REPLACE_TO_GIT=(
)

export DRUPAL_THEMES_TO_REPLACE_TO_GIT=(
"github.com weeshop weeshop_molla 1.0.x weeshop_molla"
)

export DRUPAL_PROFILES_TO_REPLACE_TO_GIT=(
"github.com weeshop weeShop 1.0.x weeShop"
)

export CHROME_DRIVER_PATH=/home/kent/Downloads/chromedriver-linux64/chromedriver
export CHROME_DRIVER_PORT=4444
export CHROME_DRIVER_ALLOW_IPS=172.18.0.3
export CHROME_DRIVER_ALLOW_HOSTS=host.docker.internal
