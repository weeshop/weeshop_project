#!/bin/bash

script_path=$(dirname $(readlink -f $0))

source $script_path/../scripts_setting.sh

${CHROME_DRIVER_PATH} --port=${CHROME_DRIVER_PORT} --allowed-ips=${CHROME_DRIVER_ALLOW_IPS} --allowed-origins=${CHROME_DRIVER_ALLOW_HOSTS}