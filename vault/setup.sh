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
