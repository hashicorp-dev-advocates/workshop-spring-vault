---
slug: dynamic-secrets-test-application
id: 9xyk5a6n0xit
type: challenge
title: Dynamic Secrets - Test Application
teaser: Run the application that uses dynamic secrets from Vault.
notes:
- type: text
  contents: |-
    For more resources on using Spring Vault to read static secrets from Vault, check out:

    - [Tutorial](https://developer.hashicorp.com/vault/tutorials/app-integration/spring-reload-secrets#reload-dynamic-secrets)
    - [Example Demo](https://www.youtube.com/watch?v=E9XDfOVNN2U)
tabs:
- id: dxqqginnkqkb
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
- id: 4gjkvukj4jxi
  title: API Request
  type: terminal
  hostname: sandbox
  workdir: /root
- id: dnolaw0mgnch
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

Your application will do the following when it runs:

1. Authenticate to Vault using a token
1. Get a database secret from the `database` path using the `writer` role
1. Inject a database secret into `spring.datasource`
1. Refresh objects using a new database secret when the Vault lease almost expires

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

When the Spring Boot application starts, it authenticates to the database
using the injected username and password from Vault.

Test the application
===

Make a request to the application to get the secret in the **API Request** tab.

```shell
curl 127.0.0.1:8080/paymentcard/1
```

The request returns a payment card record.

```shell,nocopy
[{"id":1,"user_id":123,"name":"Mr Nicholas Jackson","number":"12313434","expiry":"01/23","cv3":"1231"}]
```

Verify application refreshes with new secret
===

After a few minutes, make a second request to the application to get the record
again in the **API Request** tab.

```shell
curl 127.0.0.1:8080/paymentcard/1
```

The request returns the same payment card record.

```shell,nocopy
[{"id":1,"user_id":123,"name":"Mr Nicholas Jackson","number":"12313434","expiry":"01/23","cv3":"1231"}]
```

Examine the application logs in the **Terminal** tab. After about two minutes, the application gets
new database credentials because it detects the old ones will expire.
When you make a second request to the application, you
signal to the application to recreate the datasource and reconnect to the database
with new credentials.

```shell,nocopy
2025-01-09T13:59:35.371-05:00  INFO 83075 --- [workshop-spring-vault] [           main] opSpringVaultApplication$$SpringCGLIB$$0 : rebuild database secrets: v-token-writer-vKKFrRgnUvIdUU2EaktO-1736449174,3YC4Tr5BcpFIn4-WEdzC
## omitted
2025-01-09T14:01:14.866-05:00  INFO 83075 --- [workshop-spring-vault] [g-Cloud-Vault-2] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown initiated...
2025-01-09T14:01:14.869-05:00  INFO 83075 --- [workshop-spring-vault] [g-Cloud-Vault-2] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown completed.
2025-01-09T14:01:14.869-05:00  INFO 83075 --- [workshop-spring-vault] [g-Cloud-Vault-2] c.e.w.VaultRefresher                     : application refreshes database credentials
2025-01-09T14:01:19.847-05:00  INFO 83075 --- [workshop-spring-vault] [nio-8080-exec-4] opSpringVaultApplication$$SpringCGLIB$$0 : rebuild database secrets: v-token-writer-j5tuXA8TZvvWKioFfiZM-1736449274,7VI16NmgXCBnbB4tn-vm
2025-01-09T14:01:19.848-05:00  INFO 83075 --- [workshop-spring-vault] [nio-8080-exec-4] com.zaxxer.hikari.HikariDataSource       : HikariPool-2 - Starting...
2025-01-09T14:01:19.875-05:00  INFO 83075 --- [workshop-spring-vault] [nio-8080-exec-4] com.zaxxer.hikari.pool.HikariPool        : HikariPool-2 - Added connection org.postgresql.jdbc.PgConnection@1ecf28dd
2025-01-09T14:01:19.876-05:00  INFO 83075 --- [workshop-spring-vault] [nio-8080-exec-4] com.zaxxer.hikari.HikariDataSource       : HikariPool-2 - Start completed.
```

> [!NOTE]
> Your `DataSource` implementation may or may not support graceful shutdown of connections
> when tearing down an old `DataSource` and creating a new one. Verify the underlying
> implementation if your application has concerns about open database connections.

The application continues to serve requests with minimal disruption, as it automatically
handles the injection of new credentials and reconnects to the database. If your application
cannot use Spring Cloud Vault, you may need to restart the application using a separate process
such as [Vault agent](https://developer.hashicorp.com/vault/docs/agent-and-proxy/agent).

Summary
===

In this section, you learned how to:

1. Enable Vault's database secrets engine.
2. Add a database configuration for Vault to generate usernames and password on demand.
3. Configure a Spring Boot application to retrieve the database username and password from Vault.
4. Update the application to refresh and inject the database secret.