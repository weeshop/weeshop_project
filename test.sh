#!/bin/bash

script_path=$(dirname $(readlink -f $0))

source $script_path/../scripts_setting.sh

echo $DRUPAL_PATH
