#!/bin/bash
# Sample settings for scripts. Copy this file to scripts/../scripts_setting.sh and modify as needed.
export DRUPAL_PATH=./drupal
export DRUPAL_MODULES_TO_REPLACE_TO_GIT=(
"commerce_checkout_api 1.0.x"
"commerce_refund 2.0.x"
"front_page 1.0.x"
"promotion_blocks 1.0.x"
"sms_china 1.0.x"
"user_phone 3.0.x"
"migrate_source_markdown 1.0.x"
"awesome_modules 1.0.x"
"enhanced_user 2.0.x"
"vip 2.0.x"
"wechat_pay 3.0.x"
"wechat_connect 3.0.x"
)

export CHROME_DRIVER_PATH=/home/kent/Downloads/chromedriver-linux64/chromedriver
export CHROME_DRIVER_PORT=4444
export CHROME_DRIVER_ALLOW_IPS=172.18.0.3
export CHROME_DRIVER_ALLOW_HOSTS=host.docker.internal
