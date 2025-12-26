#!/bin/bash

script_path=$(dirname $(readlink -f $0))

source $script_path/../scripts_setting.sh

echo $DRUPAL_PATH

str="apple banana cherry"
arr=(${str// / })  # 使用空格替换分隔符，并扩展为数组

for i in "${!arr[@]}"
do
  echo "${arr[$i]}"  # 输出数组元素
done

