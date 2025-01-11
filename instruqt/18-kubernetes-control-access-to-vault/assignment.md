---
slug: kubernetes-control-access-to-vault
id: 1ers2ploc2n6
type: challenge
title: Kubernetes - Configure Kubernetes workload access to Vault
teaser: Configure Vault to allow application access from Kubernetes
notes:
- type: text
  contents: |
    Vault uses a set of policies to define API access to various secrets engines and paths. You can attach
    the policy to a role, which then gets assigned to an identity.
tabs:
- id: jwiyex1rrs9i
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
- id: 5iczic5c0zyy
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

Policies are used to control access to Vault.  A policy is a HCL file that defines
the paths that a token can access and the operations that can be performed on those
paths. For example, the following policy allows access to create a dynamic
database credential using the `writer` role, get static secrets from the key-value
secrets engine, and encrypt and decrypt data using the `payments` key.

```javascript
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
```

Add policy to Vault
===

Create a policy named `payments` to Vault using the `vault policy` command.

<details>
<summary><b>Solution</b></summary>
Run the following command in the <b>Terminal</b> tab.

```shell
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
```
</details>

<details>
<summary><b>Verify</b></summary>
After adding the policy, verify that you can read the policy using the following:

```shell
vault policy read payments
```
</details>

Link policy to Vault role
===

Create a Vault role that associates the policy with a Kubernetes service account.
Use the Vault CLI to add a role named `payments` that associates the `payments` policy with the
`payments` service account in the `default` namespace.

<details>
<summary><b>Solution</b></summary>
Run the following command in the <b>Terminal</b> tab.

```shell
vault write auth/kubernetes/role/payments \
  bound_service_account_names=payments \
  bound_service_account_namespaces=default \
  token_policies=payments \
  ttl=24h
```
</details>

<details>
<summary><b>Verify</b></summary>
After adding the role, verify that you can read the role using the following:

```shell
vault read auth/kubernetes/role/payments
```
</details>

Next, create a new Kubernetes deployment
that uses the `payments` service account in the `default` namespace
to authenticate to Vault and runs the application.