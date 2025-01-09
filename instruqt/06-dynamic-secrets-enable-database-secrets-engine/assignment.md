---
slug: dynamic-secrets-enable-database-secrets-engine
id: zytc3wqxfypy
type: challenge
title: Dynamic Secrets - Enable Vault's database secrets engine
teaser: Mount Vault's database secrets engine to manage usernames and passwords for
  a database.
notes:
- type: text
  contents: |
    In this section of the workshop, you will learn how to use [Spring Vault](https://spring.io/projects/spring-vault) and [Spring Cloud Vault](https://cloud.spring.io/spring-cloud-vault/reference/html/)
    libraries in your Spring Boot application to retrieve dynamic secrets managed by HashiCorp Vault.

    In this second section, you will:

    1. Enable Vault's database secrets engine.
    2. Add a database configuration for Vault to generate usernames and password on demand.
    3. Configure a Spring Boot application to retrieve the database username and password from Vault.
    4. Update the application to refresh and inject the database secret.
- type: text
  contents: |
    HashiCorp Vault stores and manages your secrets. It can handle two main types of secrets:

    1. Static secrets - you manually write them into Vault as keys and values and handle their rotation.
    2. Dynamic secrets - Vault automatically generates a secret with an expiration date. When the secret expires, Vault deletes it.

    Besides storing secrets, Vault supports different methods of authentication.

    1. User authentication - Once Vault verifies your identity, it provides a token for future requests.
    1. Machine authentication - Once Vault verifies a service or machine identity, it provides a token for future requests.
tabs:
- id: tyyuk81virxo
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
- id: sr44ystyyiy8
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

Dynamic secrets expire after a certain period of time. Vault deletes the secret on
your behalf. Many secrets engines support some kind of dynamic secret capability.

The database engine generates dynamic secrets for a database (username and password) for
a variety of databases.

This guide will walk you through configuring the database secrets engine and
generating dynamic credentials for a PostgreSQL database.

Enable the database secrets engine
===

Enable the database secrets engine at the path `database` in Vault
with the `vault secrets enable <type>` command.
You must mount secrets engines before Vault can issue secrets on your behalf.

You can find the details in this documentation: https://developer.hashicorp.com/vault/docs/secrets/databases.

> [!NOTE]
> You need to enable the engine at the path `database`. This requires defining the path.

<details>
<summary><b>Solution</b></summary>
Run the following command in the <b>Terminal</b> tab.

```shell
vault secrets enable database
```
</details>

<details>
<summary><b>Verify</b></summary>
After mounting the secrets engine, verify that you've created the secrets engine using the following:

```shell
vault secrets list
```
</details>

After you've mounted the database secrets engine, let's configure the database secrets engine
for the application's PostgreSQL database.