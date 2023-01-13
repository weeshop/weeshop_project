#!/bin/bash

cd ./web/modules/contrib || exit

rm -rf ./weeshop_demo
git clone git@github.com:weeshop/weeshop_demo.git

rm -rf ./weeshop_alpha_components
git clone git@github.com:weeshop/weeshop_alpha_components.git


cd ../../themes/contrib || exit

rm -rf ./weeshop_alpha
git clone git@github.com:weeshop/weeshop_alpha.git


cd ../../profiles/contrib || exit

rm -rf ./weeshop
git clone git@github.com:weeshop/WeeShop.git weeshop
