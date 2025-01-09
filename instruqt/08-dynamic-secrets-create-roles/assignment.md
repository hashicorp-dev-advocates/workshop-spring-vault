---
slug: dynamic-secrets-create-roles
id: xuvtqbqtcif3
type: challenge
title: Dynamic Secrets - Create Vault roles to access database
teaser: Set up roles in Vault to read from and write to the database
notes:
- type: text
  contents: |-
    Unlike static secrets and Vault's key-value secrets engine, you need
    to attach a level of access to a secret managed by Vault.

    You define and control the permissions a given database credential
    has by defining a Vault role.
tabs:
- id: 8fu8vmx9en18
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
- id: ggmcllouzf0a
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

A Vault role configures the permissions for the database user. When you create a role,
you can specify the SQL statements that are executed to create the user and grant permissions.
You can also specify the time-to-live (TTL) for the credentials.

Create a Vault role to write to the database
===

The application needs a Vault role with permissions to insert records into the `payment_card` table.
The application does not create or drop tables. Thus, it needs a `writer` role to add records
to the table.

When you request Vault to generate database credentials, it runs a *creation statement*.
This SQL statement defines how the database creates a username and password and attaches its
permissions. It uses template variables to automatically pass in the `{{name}}` of the user,
`{{password}}`, and `{{expiration}}` time.

The role also sets a TTL, which limits the lifetime of the credential.
Set the TTL for the writer to default to 1 minute, with a maximum of 2 minutes.
This means that Vault allows one renewal of the existing credential before it deletes it permanently.

> [!NOTE]
> This TTL is for example purposes only. Do not set a short TTL in production, as it may
> disrupt your application or Vault.

<details>
<summary><b>Solution</b></summary>
Run the following command in the <b>Terminal</b> tab.

```shell
vault write database/roles/writer \
    db_name=payments \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
    GRANT SELECT, INSERT, UPDATE ON payment_card TO \"{{name}}\";" \
    default_ttl="1m" \
    max_ttl="2m"
```
</details>

<details>
<summary><b>Verify</b></summary>
After creating the writer role, verify that you can get some credentials with the following:

```shell
vault read database/creds/writer
```

The command outputs a username and password with a lease used by Vault to track the expiration
of the secret.

```shell,nocopy
Key                Value
---                -----
lease_id           database/creds/writer/x9fpwRltEqD4Gq45HZgPtU1i
lease_duration     1m
lease_renewable    true
password           H-K3EPsHkXX0TAw1tHB2
username           v-token-writer-SKafQcVrz91Lu3BDxeGi-1736435705
```

Copy the database username and password to log into Vault and select from the `payment_card`
table.

```shell
PGPASSWORD=<copy from Vault output> psql -h 127.0.0.1 -U <copy from Vault output> payments --command 'select * from payment_card;'
```

There should be one record.

```shell
 id | user_id |        name         |  number  | expiry | cv3
----+---------+---------------------+----------+--------+------
  1 |     123 | Mr Nicholas Jackson | 12313434 | 01/23  | 1231
(1 row)
```
</details>

Create a Vault role to read from the database
===

Create a `reader` role that allows a human user to select records from the `payments` table.

The permissions should grant select on the `payment_card` table,
a default TTL of 1 hour, and a maximum of 24 hours. Since a user leverages
the `reader` role to debug the database, it helps to have an longer TTL for the
database credentials. Other parameters should match the `writer` role you created.

<details>
<summary><b>Solution</b></summary>
Run the following command in the <b>Terminal</b> tab.

```shell
vault write database/roles/reader \
    db_name=payments \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
    GRANT SELECT ON payment_card TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"
```
</details>

<details>
<summary><b>Verify</b></summary>
After creating the reader role, verify that you can get some credentials with the following:

```shell
vault read database/creds/reader
```

The command outputs a username and password with a lease used by Vault to track the expiration
of the secret.

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

The command outputs one record.

```shell,nocopy
 id | user_id |        name         |  number  | expiry | cv3
----+---------+---------------------+----------+--------+------
  1 |     123 | Mr Nicholas Jackson | 12313434 | 01/23  | 1231
(1 row)
```
</details>

Next, configure the Spring application to read the database secret from Vault.