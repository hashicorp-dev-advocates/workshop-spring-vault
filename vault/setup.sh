#!/bin/bash

# Wait for vault to be ready
until [ "$(vault status --format json | jq .sealed)" = "false" ]; do
  echo "Vault is not running, waiting 2 seconds..."
  sleep 2
done

vault secrets disable secret

## Transit secrets engine

vault secrets enable transit
vault write -f transit/keys/payments type=rsa-4096

## Database secrets engine

vault secrets enable database
vault write database/config/payments \
    plugin_name=postgresql-database-plugin \
    allowed_roles=writer,reader \
    connection_url="postgresql://{{username}}:{{password}}@database:5432/payments?sslmode=disable" \
    username="postgres" \
    password="password"

vault write -force database/rotate-root/payments
vault write database/roles/writer \
    db_name=payments \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
    GRANT SELECT, INSERT, UPDATE ON payment_card TO \"{{name}}\";" \
    default_ttl="1m" \
    max_ttl="2m"

vault write database/roles/reader \
    db_name=payments \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
    GRANT SELECT ON payment_card TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

vault secrets enable -version=2 -path=secret kv
vault kv put secret/workshop-spring-vault custom.StaticSecret.username=nic custom.StaticSecret.password=H@rdT0Gu3ss

# Enable user auth
vault auth enable userpass

# Configure users
vault write auth/userpass/users/ops \
  password=password \
  policies=ops

vault write auth/userpass/users/datascience \
  password=password \
  policies=datascience

vault write auth/userpass/users/runtime \
  password=password \
  policies=runtime

# Enable kubernetes auth
vault auth enable kubernetes

# Configure kubernetes auth
kubectl get secret -n vault vault-k8s-auth-secret -o json | jq -r '.data."ca.crt"' | base64 -d > tmp/k8s.crt
kubectl get secret -n vault vault-k8s-auth-secret -o json | jq -r '.data.token' | base64 -d > tmp/k8s.token

vault write auth/kubernetes/config \
  token_reviewer_jwt="${K3S_TOKEN}" \
  kubernetes_host="https://kubernetes.default.svc:443" \
  kubernetes_ca_cert=@tmp/k8s.crt