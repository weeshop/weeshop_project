#!/bin/bash
# https://www.php.net/manual/zh/ref.pdo-oci.php
# https://www.oracle.com/database/technologies/instant-client/downloads.html
apt-get update && apt-get install libaio1
wget https://download.oracle.com/otn_software/linux/instantclient/213000/instantclient-basic-linux.x64-21.3.0.0.0.zip
wget https://download.oracle.com/otn_software/linux/instantclient/213000/instantclient-sdk-linux.x64-21.3.0.0.0.zip
unzip instantclient-basic-linux.x64-21.3.0.0.0.zip
unzip instantclient-sdk-linux.x64-21.3.0.0.0.zip

cp /app/oracle-lib.conf /etc/ld.so.conf.d/oracle-lib.conf
ldconfig

docker-php-ext-configure oci8 --with-oci8=instantclient,/instantclient_21_3
docker-php-ext-install oci8
docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/instantclient_21_3
docker-php-ext-install pdo_oci
