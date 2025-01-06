#!/bin/bash

set -e

K3S_TOKEN=$(cat ./tmp/k3s.token) docker compose -f docker-compose.yaml down

docker volume rm workshop-spring-vault_k3s-agent
docker volume rm workshop-spring-vault_k3s-server
rm -rf tmp