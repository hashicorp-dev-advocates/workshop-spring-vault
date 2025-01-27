---
slug: dynamic-secrets-add-database-configuration
id: iq0gnppx44gp
type: challenge
title: Dynamic Secrets - Add database configuration
teaser: Configure Vault's database secrets engine to issue usernames and passwords
notes:
- type: text
  contents: |-
    A secret is simply a collection of keys and values that are stored at a specific path.

    Vault has a number of secrets engines, which you mount at various API paths to store
    and manage secrets.  You can write and read a secret from Vault.

    Vault manages certain types of secrets, including database usernames and passwords.
    When it detects a secret's lease expires, it deletes the credentials from the database
    on your behalf.
tabs:
- id: tleersznqguw
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
- id: mi5nek0cpavk
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

The database secrets engine requires connection information to the database.

Connection information changes depending on the [database supported by Vault](https://developer.hashicorp.com/vault/docs/secrets/databases).

When configuring the database secrets engine, you need to specify the plugin name,
the connection URL, and the allowed roles.

We will configure the database secrets engine for a PostgreSQL database.
The connection URL has the format:

```
postgresql://{{username}}:{{password}}@hostname:port/database_name?sslmode=disable
```

The connection URL expects a root database `username` and `password` as template variables. To prevent
leaking the root database username and password, pass the root database username and password
as parameters.

> [!NOTE]
> It is highly recommended a user within the database is created specifically for Vault to use.
> For simplicity of the exercise, we will use the default postgres administrator.

Configure the database connection
===

Configure the database secrets engine at `database/` with a connection
to the PostgreSQL database at the DNS alias `database` and a database
name of `payments`. The configuration should use the PostgreSQL database plugin
and attach roles for a database `writer` and `reader`. Set the root database
username to `postgres` and password to `payments`.

You can find more details at: https://developer.hashicorp.com/vault/docs/secrets/databases/postgresql

<details>
<summary><b>Solution</b></summary>
Run the following command in the <b>Terminal</b> tab.

```shell
vault write database/config/payments \
    plugin_name=postgresql-database-plugin \
    allowed_roles=writer,reader \
    connection_url="postgresql://{{username}}:{{password}}@database:5432/payments?sslmode=disable" \
    username="postgres" \
    password="password"
```
</details>


<details>
<summary><b>Verify</b></summary>
After configuring the database, verify using the following:

```shell
vault read database/config/payments
```
</details>

Rotate the root database username and password
===

Once you pass the root database username and password in Vault,
you cannot extract them by reading the database configuration from Vault.
As a best practice, rotate the initial root database username and password
to prevent a leak.

Vault can automatically rotate the root database username and password for you.

<details>
<summary><b>Solution</b></summary>
Run the following command in the <b>Terminal</b> tab.

```shell
vault write -force database/rotate-root/payments
```
</details>

Now you configured Vault to connect to the database, let's create roles
that grant specific permissions to write and read from the database.