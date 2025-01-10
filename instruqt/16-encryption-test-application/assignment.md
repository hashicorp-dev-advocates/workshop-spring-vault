---
slug: encryption-test-application
type: challenge
title: Encryption - Test application
teaser: Run the application that uses Vault to encrypt and decrypt customer data.
notes:
  - type: text
    contents: |-
      For more resources on using Spring Vault to encrypt and decrypt data:

      - [Tutorial](https://developer.hashicorp.com/vault/tutorials/encryption-as-a-service/eaas-spring-demo)
tabs:
  - id: vewwfodxkmai
    title: Terminal
    type: terminal
    hostname: sandbox
    workdir: /root/workshop-spring-vault
  - id: ajxeiws4w8rd
    title: API Request
    type: terminal
    hostname: sandbox
    workdir: /root
  - id: 01ddg0sifytr
    title: Code
    type: code
    hostname: sandbox
    path: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

Your application will do the following when it runs:

1. Authenticate to Vault using a token
1. Inject the path to encryption key in Vault based on its custom configuration property
1. Encrypt and decrypt a credit card number stored in a database using the key from Vault

Configure local authentication to Vault
===

You will test the application **locally** in this first section of the workshop.
To run the application locally, you need to log into Vault and get a token.

Use the username `dev` and password `password` to log into Vault and store the Vault token
in the `VAULT_TOKEN` environment variable. This is a pre-defined environment variable
that the Vault CLI uses to authenticate.

Using the **Terminal** tab, log into Vault and store the token.

```shell
export VAULT_TOKEN=$(vault login -method userpass -token-only username=dev password=password)
```

Recall that the application properties reference the Vault token in the `VAULT_TOKEN`
environment variable.

Run the application
===

Run Maven to start the application in the **Terminal** tab.

```shell
./mvnw spring-boot:run
```

When the Spring Boot application starts, it
injects the static username and password into the `secret/` endpoint.

Create a new payment card record
===

Make a request to the application to create a new payment card record in the **API Request** tab.

```shell
curl 127.0.0.1:8080/paymentcard  -H "content-type: application/json" \
  -d '{
        "user_id": 456,
        "name": "Mr Nicholas Jackson",
        "number": "456789012345",
        "expiry":"01/26",
        "cv3": "9081"
      }'
```

The request returns a new payment card record with the credit card number in plaintext.

```shell,nocopy
[{"id":2,"user_id":456,"name":"Mr Nicholas Jackson","number":"456789012345","expiry":"01/26","cv3":"9081"}]
```

Verify encrypted credit card number in database
===

Get a database username and password from Vault to read from the database.

```shell
vault read database/creds/reader
```

The command outputs a username and password for the database.

```shell,nocopy
Key                Value
---                -----
lease_id           database/creds/reader/SbwFzRsPeB3IcSi8ecyrMgjk
lease_duration     1h
lease_renewable    true
password           YYkQlEhlaYg9oZ9p-pl6
username           v-token-reader-vGcR3xsXCrCLPC5ALo33-1736436171
```

Copy the database username and password to log into Vault and select from the `payment_card`
table.

```shell
PGPASSWORD=<copy from Vault output> psql -h 127.0.0.1 -U <copy from Vault output> payments --command 'select * from payment_card;'
```

The command outputs two records. The first record has its credit card number in plaintext as you used it
before you implemented Vault transit secrets engine. The second record that you just created
has a ciphertext credit card number.

```shell,nocopy
 id | user_id |        name         |  number  | expiry | cv3
----+---------+---------------------+----------+--------+------
  1 |     123 | Mr Nicholas Jackson | 12313434 | 01/23  | 1231
(1 row)
```

If an unauthorized user or service accesses the data in the database, they cannot decrypt and use
the credit card number without sufficient access to decrypt the ciphertext using Vault. You can encrypt any
previous records to store in the database or rekey records with a new key as needed.

Summary
===

In this section, you learned how to:

1. Enable Vault's transit secrets engine.
2. Add an encryption key for an application.
3. Configure a Spring Boot application to use the encryption key to encrypt and decrypt data in a database.

