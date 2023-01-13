#!/bin/bash

apk add corkscrew@testing
apk add netcat-openbsd

#sed -i 'HOST *' /home/application/.ssh/config
#sed -i '  ProxyCommand nc -x 192.168.246.1:8889 %h %p' /home/application/.ssh/config
