---
slug: static-secrets-test-application
id: 4qbjcojtow0g
type: challenge
title: Static Secrets - Test application
teaser: Run the application that uses static secrets from Vault.
notes:
- type: text
  contents: |-
    For more resources on using Spring Vault to read static secrets from Vault, check out:

    - [Tutorial](https://developer.hashicorp.com/vault/tutorials/app-integration/spring-reload-secrets#reload-static-secrets)
    - [Example Demo](https://www.youtube.com/watch?v=Q1MzpFAplbA)
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
1. Get all secrets from the `secret/workshop-spring-vault` path
1. Inject the secrets based on their custom configuration property
1. Refresh objects using the secrets based on a scheduled task delay (3 minutes)

Configure local authentication to Vault
===

You will test the application **locally** in this first section of the workshop.
To run the application locally, you need to log into Vault and get a token.

Use the username `dev` and password `password` to log into Vault and store the Vault token
in the `VAULT_TOKEN` environment variable. This is a pre-defined environment variable
that the Vault CLI uses to authenticate.

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

When the Spring Boot application starts, it retrieves records from a database
and injects the static username and password into the `secret/` endpoint.

Test the application
===

Make a request to the application to get the secret in the **API Request** tab.

```shell
curl localhost:8080/secret
```

The request returns the value of the username and password.

Rotate the secret
===

Change the password of the secret in Vault.

```shell
vault kv put secret/workshop-spring-vault custom.StaticSecret.username=nic custom.StaticSecret.password=Sec0ndVers!on
```

After a few minutes, make a request to the application to get the secret in
the **API Request** tab.

```shell
curl localhost:8080/secret
```

The request returns the value of the username and new password. The application logs should
also show that the application rebuilt `ExampleClient` with the new password.

Summary
===

In this section, you learned how to:

1. Enable Vault's key-value secrets engine.
2. Add a static secret (username and password) to Vault.
3. Configure a Spring Boot application to retrieve the static secret.
4. Update the application to refresh and inject the static secret.