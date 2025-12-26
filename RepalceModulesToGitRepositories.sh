#!/bin/bash

script_path=$(dirname $(readlink -f $0))

source $script_path/../scripts_setting.sh
source $script_path/TryCommand.sh

cd $DRUPAL_PATH/web/modules/contrib || exit

for i in "${!DRUPAL_MODULES_TO_REPLACE_TO_GIT[@]}"
do

module_name=${DRUPAL_MODULES_TO_REPLACE_TO_GIT[$i]% *}
module_branch=${DRUPAL_MODULES_TO_REPLACE_TO_GIT[$i]#* }

#echo 1 $module_name 2 $module_branch

tryCommand "rm -rf ./${module_name} && git clone -b ${module_branch} git@github.com:solody/drupal-${module_name}.git ${module_name}" 60

done