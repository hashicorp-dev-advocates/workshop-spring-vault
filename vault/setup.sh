#!/bin/bash

# Wait for vault to be ready
until [ "$(vault status --format json | jq .sealed)" = "false" ]; do
  echo "Vault is not running, waiting 2 seconds..."
  sleep 2
done

vault secrets disable secret

# Enable user auth
vault auth enable userpass

vault policy write dev - <<EOF
path "sys/health"
{
  capabilities = ["read", "sudo"]
}

# Create and manage ACL policies broadly across Vault

# List existing policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Enable and manage authentication methods broadly across Vault

# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# Enable and manage the transit secrets engine at `transit/` path

# List, create, update, and delete transit secrets
path "transit/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Enable and manage the key/value secrets engine at `secret/` path

# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Enable and manage the database secrets engine at `database/` path

# List, create, update, and delete database secrets
path "database/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read"]
}
EOF

# Configure users
vault write auth/userpass/users/dev \
  password=password \
  policies=dev

# Enable kubernetes auth
vault auth enable kubernetes

# Configure kubernetes auth
kubectl get secret -n vault vault-k8s-auth-secret -o json | jq -r '.data."ca.crt"' | base64 -d > tmp/k8s.crt
kubectl get secret -n vault vault-k8s-auth-secret -o json | jq -r '.data.token' | base64 -d > tmp/k8s.token

vault write auth/kubernetes/config \
  token_reviewer_jwt="$(cat tmp/k8s.token)" \
  kubernetes_host="https://10.5.0.4:6443" \
  kubernetes_ca_cert=@tmp/k8s.crt