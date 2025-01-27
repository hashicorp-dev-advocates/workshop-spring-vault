---
slug: dynamic-secrets-configure-spring
id: ypw14ygc3w3z
type: challenge
title: Dynamic Secrets - Configure Spring application
teaser: Refactor Spring application properties to retrieve a database username and
  password from Vault.
notes:
- type: text
  contents: |-
    There are two main libraries for Spring applications to make requests to Vault.

    1. Spring Vault - base library with interfaces to make requests to the Vault API.
    1. Spring Cloud Vault - library integrating with Spring Cloud configuration to automatically
       request secrets from Vault and inject them into application properties.

    This workshop primarily focuses on using Spring Cloud Vault to
    automatically read secrets from Vault and inject them as application properties.

    Alternatively, you can write code that uses Spring Vault, the base library, to retrieve a secret from
    Vault's key-value secrets engine. In general, Spring Cloud Vault minimizes the
    extra code you need to write by automatically reading and injecting secrets into application properties.
tabs:
- id: yiltdtv8mcbi
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
- id: kqsimjnqnb2x
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

Spring Cloud Vault has a database backend that retrieves secrets from a given database secrets engine and
automatically injects the database username and password into `spring.datasource.username` and
`spring.datasource.password`.

For more details, review: https://cloud.spring.io/spring-cloud-vault/reference/html/#vault.config.backends.database

Recall that you set up a database secrets engine at the `database/` backend with a Vault role named `writer`
for the application to insert records into the database.

Configure local authentication to Vault
===

You will test the application **locally** in this first section of the workshop.
For local testing only, get a token from Vault and pass it as an environment
variable to application properties.

Open `src/main/resources/application.properties` in the **Code** tab.

The application properties define the Vault URI and token for
the application to locally authenticate to Vault for testing.
Note that the `spring.cloud.vault.token` references the
`VAULT_TOKEN` environment variable.

```java,nocopy
spring.cloud.vault.uri=${VAULT_ADDR:http://127.0.0.1:8200}
spring.cloud.vault.token=${VAULT_TOKEN}
```

Configure Spring to read database secrets from Vault
===

Open `src/main/resources/application.properties` in the **Code** tab.

The application properties update the Spring Cloud configuration
to import secrets from Vault.

```java,nocopy
spring.config.import=vault://
```

However, the application property to read from Vault's key-value engine is currently disabled.

```java,nocopy
spring.cloud.vault.database.enabled=false
```

Change the `spring.cloud.vault.database.enabled` property to `true`.

<details>
<summary><b>Solution</b></summary>
Change the property to true in the <b>Code</b> tab.

```java
spring.cloud.vault.database.enabled=true
```
</details>

Note additional application properties define the Vault backend and role
Spring Cloud Vault needs to retrieve the username and password.

```java,nocopy
spring.cloud.vault.database.role=writer
spring.cloud.vault.database.backend=database
```

> [!IMPORTANT]
> Vault itself does not signal to the application when the lease expires. Your
> application must have a timer to identify when the old secret expires and proactively
> request a new secret.

Spring Cloud Vault supports tracking of lease expiration. As a result, you can configure
additional application properties to tune its tracking such that it can properly retrieve
a new set of credentials when the old ones expire. The `writer` role has a TTL of 1 minute,
which may cause race conditions for applications renewing the secrets.

Note that application properties include configuration lifecycle parameters that control the minimum
renewal period and expiration threshold for Spring Cloud Vault.

```java,nocopy
spring.cloud.vault.config.lifecycle.min-renewal=30s
spring.cloud.vault.config.lifecycle.expiry-threshold=10s
```

If your application needs short-lived credentials and may have errors due to renewal, tuning
the configuration lifecycle parameters may help.

Next, add some code to refresh the database connection object in Spring Boot.