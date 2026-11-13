#!/bin/bash

script_path=$(dirname $(readlink -f $0))

source $script_path/../scripts_setting.sh
source $script_path/TryCommand.sh

function doWithArs() {
  str_args=$1
  echo $str_args
  ars=(${str_args// / })
  tryCommand "rm -rf ./${ars[4]} && git clone -b ${ars[3]} git@${ars[0]}:${ars[1]}/${ars[2]}.git ${ars[4]}" 60
}
current_path=`pwd`
cd $DRUPAL_PATH/web/modules/contrib || exit
for i in "${!DRUPAL_MODULES_TO_REPLACE_TO_GIT[@]}"
do
  doWithArs "${DRUPAL_MODULES_TO_REPLACE_TO_GIT[$i]}"
done
cd $current_path

current_path=`pwd`
cd $DRUPAL_PATH/web/themes/contrib || exit
for i in "${!DRUPAL_THEMES_TO_REPLACE_TO_GIT[@]}"
do
  doWithArs "${DRUPAL_THEMES_TO_REPLACE_TO_GIT[$i]}"
done
cd $current_path

current_path=`pwd`
cd $DRUPAL_PATH/web/profiles/contrib || exit
for i in "${!DRUPAL_PROFILES_TO_REPLACE_TO_GIT[@]}"
do
  doWithArs "${DRUPAL_PROFILES_TO_REPLACE_TO_GIT[$i]}"
done
cd $current_path