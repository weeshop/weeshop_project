#!/bin/bash

# docker compose exec -u root cli bash /app/scripts/AddTestingRepositoryForAlpine.sh
# docker compose exec -u root cli bash /app/scripts/SetupSSHProxyForAlpine.sh
docker compose exec -u root cli bash /app/scripts/SetupSSHProxyForDebian.sh
