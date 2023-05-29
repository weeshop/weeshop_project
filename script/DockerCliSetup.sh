#!/bin/bash

# docker compose exec -u root cli bash /app/script/AddTestingRepositoryForAlpine.sh
# docker compose exec -u root cli bash /app/script/SetupSSHProxyForAlpine.sh
docker compose exec -u root cli bash /app/script/SetupSSHProxyForDebian.sh
