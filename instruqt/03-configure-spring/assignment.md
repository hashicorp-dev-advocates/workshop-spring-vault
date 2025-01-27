---
slug: configure-spring
id: cdoox8xdkblo
type: challenge
title: Static Secrets - Configure Spring application
teaser: Refactor Spring application properties to retrieve a secret from Vault.
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
- id: 4x2lifwdqegx
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
- id: ml1uxf2mvdwl
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

On application startup, Spring Cloud Vault attempts to retrieve secrets from the following paths in Vault:

```plaintext
/secret/{application}/{profile}
/secret/{application}
/secret/{default-context}/{profile}
/secret/{default-context}
```

For more details, review: https://cloud.spring.io/spring-cloud-vault/reference/html/#vault.config.backends.kv.versioned

Recall that you stored a username and password at `secret/workshop-spring-vault`.
The secret path in Vault takes the format of `/secret/{application}`, which Spring Cloud Vault
automatically reads.

Verify the Spring application name
===

Open `src/main/resources/application.properties` in the **Code** tab.

Check the application name matches `workshop-spring-vault`.

```java,nocopy
spring.application.name=workshop-spring-vault
```

Configure local authentication to Vault
===

Vault supports two types of authentication methods:

1. Human user authentication - you log into Vault and get a token for subsequent requests
2. Machine authentication - a service or machine logs into Vault and gets a token for subsequent requests

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

Configure Spring to read static secrets from Vault
===

Open `src/main/resources/application.properties` in the **Code** tab.

The application properties update the Spring Cloud configuration
to import secrets from Vault.

```java,nocopy
spring.config.import=vault://
```

However, the application property to read from Vault's key-value engine is currently disabled.

```java,nocopy
spring.cloud.vault.kv.enabled=false
```

Change the `spring.cloud.vault.kv.enabled` property to `true`.

<details>
<summary><b>Solution</b></summary>
Change the property to true in the <b>Code</b> tab.

```java
spring.cloud.vault.kv.enabled=true
```
</details>

Next, create custom configuration properties to inject the username and password
into a controller.