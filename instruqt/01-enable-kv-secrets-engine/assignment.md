---
slug: enable-kv-secrets-engine
id: gonlxb3pd8eo
type: challenge
title: Enable Vault's key-value secrets engine
teaser: Mount Vault's key-value secrets engine to store static secrets.
notes:
- type: text
  contents: |
    In this workshop, you will learn how to use [Spring Vault](https://spring.io/projects/spring-vault) and [Spring Cloud Vault](https://cloud.spring.io/spring-cloud-vault/reference/html/) libraries in your Spring Boot application to retrieve secrets from and encrypt payloads with HashiCorp Vault.

    In this first challenge, you will:

    1. Enable Vault's key-value secrets engine.
    2. Add a static secret (username and password) to Vault.
    3. Configure a Spring Boot application to retrieve the static secret.
    4. Update the application to refresh and inject the static secret.
- type: text
  contents: |+
    HashiCorp Vault stores and manages your secrets. It can handle two main types of secrets:

    1. Static secrets - you manually write them into Vault as keys and values and handle their rotation.
    2. Dynamic secrets - Vault automatically generates a secret with an expiration date. When the secret expires, Vault deletes it.

    Besides storing secrets, Vault supports different methods of authentication.

    1. User authentication - Once Vault verifies your identity, it provides a token for future requests.
    1. Machine authentication - Once Vault verifies a service or machine identity, it provides a token for future requests.

tabs:
- id: avmy0ctjsd3v
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
- id: 1ncd8zyxna92
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---
Enable the key-value secrets engine at the path `secret` in Vault. You must mount secrets engines before you can add secrets.

You can find the details in this documentation: https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2/setup.

> [!NOTE]
> You need to enable the engine at the path `secret`. This requires defining the path.

<details>
<summary><b>Solution</b></summary>
Run the following command:

```shell
vault secrets enable -version=2 -path=secret kv
```
</details>

<details>
<summary><b>Verify</b></summary>
After mounting the secrets engine, verify that you've created the secrets engine using the following:

```shell
vault secrets list
```
</details>

After you've mounted the key-value secrets engine, let's create a secret for the application to use.