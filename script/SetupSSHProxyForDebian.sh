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
# apt-get install netcat
apt-get -y install corkscrew

#sed -i 'HOST *' /home/application/.ssh/config
#sed -i '  ProxyCommand nc -x 192.168.246.1:8889 %h %p' /home/application/.ssh/config
