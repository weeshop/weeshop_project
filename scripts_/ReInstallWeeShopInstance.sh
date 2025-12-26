#!/bin/bash

docker compose down

sudo rm -rf ./data
sudo rm -rf ./web/sites/default/files/*
sudo chmod u+w ./web/sites/default

docker compose up -d
# docker compose exec -ti -u root cli bash
docker compose exec -u root cli bash /app/scripts/SetupSSHProxyForDebian.sh
docker compose exec -u application cli bash /app/scripts/InstallWeeShop.sh
