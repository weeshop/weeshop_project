#!/bin/bash

echo "deb https://mirrors.aliyun.com/debian/ buster main non-free contrib
      deb-src https://mirrors.aliyun.com/debian/ buster main non-free contrib
      deb https://mirrors.aliyun.com/debian-security buster/updates main
      deb-src https://mirrors.aliyun.com/debian-security buster/updates main
      deb https://mirrors.aliyun.com/debian/ buster-updates main non-free contrib
      deb-src https://mirrors.aliyun.com/debian/ buster-updates main non-free contrib
      deb https://mirrors.aliyun.com/debian/ buster-backports main non-free contrib
      deb-src https://mirrors.aliyun.com/debian/ buster-backports main non-free contrib
" > /etc/apt/sources.list

apt-get -y update
apt-get -y install corkscrew mariadb-client wget

DOCKERIZE_VERSION=v0.7.0
rm -f dockerize-linux-amd64-*.tar.gz*
wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

#sed -i 'HOST *' /home/application/.ssh/config
#sed -i '  ProxyCommand nc -x 192.168.246.1:8889 %h %p' /home/application/.ssh/config
