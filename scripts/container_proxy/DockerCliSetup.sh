#!/bin/bash

# docker compose exec -u root cli bash /app/scripts/container_proxy/AddTestingRepositoryForAlpine.sh
# docker compose exec -u root cli bash /app/scripts/container_proxy/SetupSSHProxyForAlpine.sh
 docker compose exec -u root cli bash /app/scripts/container_proxy/SetupSSHProxyForDebian.sh
#docker compose exec -u root web bash
