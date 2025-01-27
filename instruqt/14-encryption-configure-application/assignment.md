---
slug: encryption-configure-application
id: yzlb9jdoy468
type: challenge
title: Encryption - Configure application
teaser: Refactor the Spring application to encrypt the data in the database
notes:
- type: text
  contents: |-
    There are two main libraries for Spring applications to make requests to Vault.

    1. Spring Vault - base library with interfaces to make requests to the Vault API.
    1. Spring Cloud Vault - library integrating with Spring Cloud configuration to automatically
       request secrets from Vault and inject them into application properties.

    This workshop primarily focuses on using Spring Vault to interface
    with Vault's transit secrets engine.
tabs:
- id: km0mniuaxtgp
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
- id: hvse6h51hi93
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
difficulty: basic
timelimit: 600
enhanced_loading: null
---

Spring Vault authenticates to Vault and accesses the `encrypt` and `decrypt` endpoints
for a given key to encrypt and decrypt data in your application

For more details, review: https://docs.spring.io/spring-vault/reference/vault/vault-secret-engines.html#vault.core.backends.transit

You used the Vault CLI to encrypt and decrypt credit card numbers. Refactor the Spring application
to encrypt the credit card before storing it in the database.

Configure local authentication to Vault
===

Vault supports two types of authentication methods:

1. Human user authentication - you log into Vault and get a token for subsequent requests
2. Machine authentication - a service or machine logs into Vault and gets a token for subsequent requests

You will test the application **locally** in this first section of the workshop.
For local testing only, get a token from VAult and pass it as an environment
variable to application properties.

Open `src/main/resources/application.properties` in the **Code** tab.

Check you have application properties to authenticate to Vault. Since you already use Spring Cloud Vault,
Spring Vault (core library) has the correct information to authenticate to Vault using a local Vault token.

```java,nocopy
spring.cloud.vault.uri=${VAULT_ADDR:http://127.0.0.1:8200}
spring.cloud.vault.token=${VAULT_TOKEN}
```

Configure Spring to access transit secrets engine
===

Open `src/main/resources/application.properties` in the **Code** tab.

Spring Vault needs the path and key of the transit secrets engine.
This application sets custom properties, `custom.transit.path` and `custom.transit.key`
to define how the application should access the transit secrets engine.

```java,nocopy
custom.transit.path=transit
custom.transit.key=payments
```

Next, create custom configuration properties to inject the transit secrets engine
path and key into the code.
