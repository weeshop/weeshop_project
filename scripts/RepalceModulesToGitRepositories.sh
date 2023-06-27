#!/bin/bash

source ./scripts/TryCommand.sh


# https://www.drupal.org/project/facets/issues/3349266
cp -r ./script/config ./web/modules/contrib/facets/modules/facets_rest

cd ./web/modules/contrib || exit

tryCommand "rm -rf ./migrate_inline_image && git clone git@github.com:solody/migrate_inline_image.git"

tryCommand "rm -rf ./product_adverts && git clone git@github.com:solody/product_adverts.git"

tryCommand "rm -rf ./adverts && git clone git@github.com:solody/adverts.git"

tryCommand "rm -rf ./enhanced_product && git clone git@github.com:solody/enhanced_product.git"

tryCommand "rm -rf ./enhanced_store && git clone git@github.com:solody/enhanced_store.git"

tryCommand "rm -rf ./weeshop_demo && git clone git@github.com:weeshop/weeshop_demo.git"

tryCommand "rm -rf ./weeshop_alpha_components && git clone git@github.com:weeshop/weeshop_alpha_components.git"

tryCommand "rm -rf ./weeshop_molla_supports && git clone git@github.com:weeshop/weeshop_molla_supports.git"



cd ../../themes/contrib || exit

tryCommand "rm -rf ./weeshop_alpha && git clone git@github.com:weeshop/weeshop_alpha.git" 60

tryCommand "rm -rf ./weeshop_molla && git clone git@github.com:weeshop/weeshop_molla.git" 60



cd ../../profiles/contrib || exit

tryCommand "rm -rf ./weeshop && git clone git@github.com:weeshop/WeeShop.git weeshop" 60
