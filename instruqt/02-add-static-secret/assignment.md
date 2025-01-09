---
slug: add-static-secret
id: fprrxjwyxhrj
type: challenge
title: Static Secrets - Add a secret to Vault
teaser: Store a secret in Vault's key-value secrets engine.
notes:
- type: text
  contents: |-
    A secret is simply a collection of keys and values that are stored at a specific path.

    Vault has a number of secrets engines, which you mount at various API paths to store
    and manage secrets.  You can write and read a secret from Vault.

    For secrets that you manage manually, you can write them to the key-value secrets engine.
tabs:
- id: wqyhajnc6xge
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
- id: wthfn5vpy1dk
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

You can write any arbitrary set of keys and values into a secret managed by Vault's key-value secrets engine.

You can find the details in this documentation: https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2#writing-reading-arbitrary-data

Add a static secret with username and password
===

Create a secret named after the application, `workshop-spring-vault`, that has two keys and values.

1. A username,  `custom.StaticSecret.username=nic`
1. A password, `custom.StaticSecret.password=H@rdT0Gu3ss`

The keys have the format of Spring application properties, as the application injects into custom properties on startup.

<details>
<summary><b>Solution</b></summary>
Run the following command in the <b>Terminal</b> tab.

```shell
vault kv put secret/workshop-spring-vault custom.StaticSecret.username=nic custom.StaticSecret.password=H@rdT0Gu3ss
```
</details>

<details>
<summary><b>Verify</b></summary>
After adding the secret, verify that you can read the secret using the following:

```shell
vault kv get secret/workshop-spring-vault
```
</details>

Next, configure the Spring application to read the secret from Vault.