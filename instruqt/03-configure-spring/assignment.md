---
slug: configure-spring
type: challenge
title: Configure Spring
teaser: Refactor Spring application properties to retrieve a secret from Vault.
notes:
- type: text
  contents: |-
    Spring Cloud Vault automatically reads the secret from Vault and injects it as an application property.

    On application startup, Spring Cloud Vault attempts to retrieve secrets from [the following paths in Vault](https://cloud.spring.io/spring-cloud-vault/reference/html/#vault.config.backends.kv.versioned):

    ```plaintext
    /secret/{application}/{profile}
    /secret/{application}
    /secret/{default-context}/{profile}
    /secret/{default-context}
    ```

    Your application can inject secrets by setting a custom property using the `@ConfigurationProperties` annotation.
tabs:
- id: wthfn5vpy1dk
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
- id: wqyhajnc6xge
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

Spring will attempt to load secrets from certain default paths. One of those default paths
include the application name.

Recall that you stored a username and password at `secret/workshop-spring-vault`.

## Verify the Spring application name

Open `src/main/resources/application.properties`. Check the application name
matches `workshop-spring-vault`.

```java
spring.application.name=workshop-spring-vault
```

## Configure Spring configuration to read from Vault key-value secrets engine

Open `src/main/resources/application.properties`. The configuration property
to read from Vault's key-value engine is currently disabled.

```java
spring.cloud.vault.kv.enabled=false
```

Change the `spring.cloud.vault.kv.enabled` property to `true`.



<details>
<summary><b>Solution</b></summary>
Run the following command:

```shell
spring.cloud.vault.kv.enabled=true
```
</details>

Let's now create a new controller to see how you can use these secrets.