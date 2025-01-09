---
slug: encryption-enable-transit-secrets-engine
type: challenge
title: Encryption - Enable Vault's transit secrets engine
teaser: Mount Vault's transit secrets engine to manage encryption keys for the application.
notes:
- type: text
  contents: |
    In this section of the workshop, you will learn how to use [Spring Vault](https://spring.io/projects/spring-vault)
    to use an encryption key managed by HashiCorp Vault to encrypt and decrypt data in your database.

    In this third section, you will:

    1. Enable Vault's transit secrets engine.
    2. Add an encryption key for an application.
    3. Configure a Spring Boot application to use the encryption key to encrypt and decrypt data in a database.
- type: text
  contents: |
    HashiCorp Vault stores and manages your secrets. It can handle two main types of secrets:

    1. Static secrets - you manually write them into Vault as keys and values and handle their rotation.
    2. Dynamic secrets - Vault automatically generates a secret with an expiration date. When the secret expires, Vault deletes it.

    Vault can manage an existing encryption key as a static secret, although it has the transit secrets
    engine to manage keys on your behalf.

    Besides storing secrets, Vault supports different methods of authentication.

    1. User authentication - Once Vault verifies your identity, it provides a token for future requests.
    1. Machine authentication - Once Vault verifies a service or machine identity, it provides a token for future requests.
tabs:
- id: dxqqginnkqkb
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
- id: dnolaw0mgnch
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

In the previous section, recall that you accessed the database and got a list of credit card records.
However, you noticed that the database stored credit card numbers in plaintext! This raises a potential security
violation of personal and identifying information.

```shell,nocopy
 id | user_id |        name         |  number  | expiry | cv3
----+---------+---------------------+----------+--------+------
  1 |     123 | Mr Nicholas Jackson | 12313434 | 01/23  | 1231
(1 row)
```

Rather than store sensitive information in plaintext, you can encrypt the data using an encryption key.
Applications that require access to the data use the key to decrypt the data for processing. Otherwise,
any other user or service accessing the data will only get ciphertext.

While you could store your encryption key as a static secret in Vault, you could also set up the
Vault's transit secrets engine to manage encryption keys for you. Vault includes an API to handle
encryption and decryption of the payload.

This guide will walk you through configuring the transit secrets engine, generating a key
for the application, and using the key in the application to encrypt and decrypt payloads.

Enable the transit secrets engine
===

Enable the transit secrets engine at the path `transit` in Vault
with the `vault secrets enable <type>` command.
You must mount secrets engines before Vault can issue secrets on your behalf.

You can find the details in this documentation: https://developer.hashicorp.com/vault/docs/secrets/transit.

> [!NOTE]
> You need to enable the engine at the path `transit`.

<details>
<summary><b>Solution</b></summary>
Run the following command in the <b>Terminal</b> tab.

```shell
vault secrets enable transit
```
</details>

<details>
<summary><b>Verify</b></summary>
After mounting the secrets engine, verify that you've created the secrets engine using the following:

```shell
vault secrets list
```
</details>

After you've mounted the transit secrets engine, let's create a key for the Spring Boot application.