#!/bin/bash

# 增加testing仓库(默认只有main和community)
sed -i '$a@testing http://mirrors.tuna.tsinghua.edu.cn/alpine/edge/testing' /etc/apk/repositories
