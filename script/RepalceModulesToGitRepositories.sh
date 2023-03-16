#!/bin/bash

cd ./web/modules/contrib || exit

rm -rf ./enhanced_product
git clone git@github.com:solody/enhanced_product.git

rm -rf ./enhanced_store
git clone git@github.com:solody/enhanced_store.git


rm -rf ./weeshop_demo
git clone git@github.com:weeshop/weeshop_demo.git

rm -rf ./weeshop_alpha_components
git clone git@github.com:weeshop/weeshop_alpha_components.git

rm -rf ./weeshop_molla_supports
git clone git@github.com:weeshop/weeshop_molla_supports.git

cd ../../themes/contrib || exit

rm -rf ./weeshop_alpha
git clone git@github.com:weeshop/weeshop_alpha.git

rm -rf ./weeshop_molla
git clone git@github.com:weeshop/weeshop_molla.git


cd ../../profiles/contrib || exit

rm -rf ./weeshop
git clone git@github.com:weeshop/WeeShop.git weeshop
