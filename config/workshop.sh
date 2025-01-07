#!/bin/bash

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

vault policy write payments - <<EOF
path "database/creds/writer" {
  capabilities = ["read", "create"]
}

path "secret/*" {
  capabilities = ["read"]
}

path "transit/encrypt/payments" {
  capabilities = ["update"]
}

path "transit/decrypt/payments" {
  capabilities = ["update"]
}
EOF

vault write auth/kubernetes/role/payments \
  bound_service_account_names=payments \
  bound_service_account_namespaces=default \
  token_policies=payments
  ttl=24h

# To test Spring Vault locally
export VAULT_TOKEN=$(vault login -method userpass -token-only username=dev password=password)

./mvnw spring-boot:run

curl 127.0.0.1:8080/secret

curl 127.0.0.1:8080/paymentcard/1

curl 127.0.0.1:8080/paymentcard  -H "content-type: application/json" \
  -d '{
        "user_id": 456,
        "name": "Mr Nicholas Jackson",
        "number": "456789012345",
        "expiry":"01/26",
        "cv3": "9081"
      }'

# To test Kubernetes
kubectl apply -f k8s/app.yaml

curl 127.0.0.1/secret

curl 127.0.0.1/paymentcard/1

curl 127.0.0.1/paymentcard  -H "content-type: application/json" \
  -d '{
        "user_id": 456,
        "name": "Mr Nicholas Jackson",
        "number": "456789012345",
        "expiry":"01/26",
        "cv3": "9081"
      }'