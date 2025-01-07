#!/bin/bash

set -e

mkdir -p tmp/

if [ ! -f ./tmp/k3s.token ]; then
  uuidgen > ./tmp/k3s.token
fi

export KUBECONFIG=./tmp/kubeconfig.yaml
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root-token

K3S_TOKEN=$(cat ./tmp/k3s.token) docker-compose -f docker-compose.yaml up -d --build

# Wait for k3s to be ready
until kubectl get nodes; do
  echo "Kubernetes is not running, waiting 2 seconds..."
  sleep 2
done

kubectl create namespace vault --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n vault -f vault/service-account.yaml

bash vault/setup.sh