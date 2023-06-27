#!/bin/bash

dockerize -wait tcp://db:3306 \
          -timeout 3600s

cd /app && \
vendor/bin/drush site:install weeshop \
install_configure_form.enable_update_status_emails=NULL \
install_configure_form.demo_content=0 \
--db-url=mysql://root:123@db:3306/drupal \
--locale=en \
--site-name='WeeShop' \
--site-mail='164713332@qq.com' \
--site-pass=ekpass \
--account-name=admin \
--account-mail=164713332@qq.com \
--account-pass=ekpass
vendor/bin/drush locale:check && \
vendor/bin/drush locale:update
