#!/bin/bash

echo "deb https://mirrors.aliyun.com/debian/ bookworm main non-free non-free-firmware contrib
      deb-src https://mirrors.aliyun.com/debian/ bookworm main non-free non-free-firmware contrib
      deb https://mirrors.aliyun.com/debian-security/ bookworm-security main
      deb-src https://mirrors.aliyun.com/debian-security/ bookworm-security main
      deb https://mirrors.aliyun.com/debian/ bookworm-updates main non-free non-free-firmware contrib
      deb-src https://mirrors.aliyun.com/debian/ bookworm-updates main non-free non-free-firmware contrib
      deb https://mirrors.aliyun.com/debian/ bookworm-backports main non-free non-free-firmware contrib
      deb-src https://mirrors.aliyun.com/debian/ bookworm-backports main non-free non-free-firmware contrib
" > /etc/apt/sources.list

apt-get -y update
# apt-get install netcat
apt-get -y install corkscrew

#sed -i 'HOST *' /home/application/.ssh/config
#sed -i '  ProxyCommand nc -x 192.168.246.1:8889 %h %p' /home/application/.ssh/config
