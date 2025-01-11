---
slug: kubernetes-test-application
type: challenge
title: Kubernetes - Test application
teaser: Run the application in Kubernetes that uses secrets from Vault.
notes:
  - type: text
    contents: |-
      For other patterns regarding accessing Vault from Kubernetes, check out:

      - [Vault agent](https://developer.hashicorp.com/vault/tutorials/kubernetes/agent-kubernetes)
      - [Vault Secrets Operator](https://developer.hashicorp.com/vault/tutorials/integrate-kubernetes-hcp-vault-dedicated/kubernetes-vso-hcp-vault)
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

1. Authenticate to Vault using the Kubernetes service account JWT and get a Vault token
1. Get all secrets from the `secret/workshop-spring-vault` path
1. Get a database username and password from the `database/` path
1. Get an encryption key to decrypt and encrypt payloads for the credit card number
1. Refresh objects

Configure Kubernetes service account
===

Your application needs a service account that matches the role you created in Vault
(`payments`).

Open `k8s/app.yaml` and verify that it includes a `ServiceAccount` named
`payments`.

```yaml,nocopy
apiVersion: v1
kind: ServiceAccount
metadata:
  name: payments
```

Define application properties
===

You need to override your default application properties you used to test locally.

Open `k8s/app.yaml` and verify that it includes a `ConfigMap` named
`payments-config`.

Note that it defines the exact IP address of the Vault server, as
the application runs in Kubernetes. It also includes has `spring.cloud.vault.authentication`
set to `KUBERNETES` and the `spring.cloud.vault.kubernetes.role` set to `payments`.
These parameters ensure that the Spring Cloud Vault libraries uses Vault's Kubernetes
authentication method instead of the local Vault token you used for testing.

```yaml,nocopy
apiVersion: v1
data:
  application.properties: |
    spring.application.name=workshop-spring-vault
    
    spring.main.allow-bean-definition-overriding=true
    
    spring.cloud.vault.uri=http://10.5.0.2:8200
    spring.cloud.vault.fail-fast=true
    spring.cloud.vault.authentication: KUBERNETES
    spring.cloud.vault.kubernetes.role: payments
    
    custom.transit.path=transit
    custom.transit.key=payments
    custom.refresh-interval-ms=180000
    
    spring.config.import=vault://
    
    spring.cloud.vault.kv.enabled=true
    spring.cloud.vault.kv.backend=secret
    spring.cloud.vault.kv.application-name=workshop-spring-vault
    
    spring.cloud.vault.database.enabled=true
    spring.cloud.vault.database.role=writer
    spring.cloud.vault.database.backend=database
    
    spring.cloud.vault.config.lifecycle.min-renewal=30s
    spring.cloud.vault.config.lifecycle.expiry-threshold=10s
    
    spring.datasource.url=jdbc:postgresql://10.5.0.3:5432/payments
kind: ConfigMap
metadata:
  name: payments-config
  namespace: default
```

Review the deployment
===

Make sure your application uses the service account that matches the Vault role.

Open `k8s/app.yaml` and verify that it includes a `Deployment` named
`payments`. It uses the `serviceAccountName` named `payments`, which matches
the Vault role and Kubernetes service account.

```yaml,nocopy
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: payments
  name: payments
spec:
  replicas: 1
  selector:
    matchLabels:
      app: payments
  template:
    metadata:
      labels:
        app: payments
    spec:
      serviceAccountName: payments
      automountServiceAccountToken: true
      containers:
        - image: ghcr.io/hashicorp-dev-advocates/workshop-spring-vault:stable
          name: payments
          volumeMounts:
            - name: config-volume
              mountPath: /config
      volumes:
        - name: config-volume
          configMap:
            name: payments-config
```

Deploy the application
===

Apply the Kubernetes manifests for the application.

```shell
kubectl apply -f k8s/app.yaml
```

Check that the application starts using `kubectl get pods`.
You should have a pod prefixed by `payments`.

Test the application
===

Make a request to the application to get the first payment card in the **API Request** tab.

```shell
curl localhost/paymentcard/1
```

The request returns the first payment card record.

```shell,nocopy
[{"id":1,"user_id":123,"name":"Mr Nicholas Jackson","number":"12313434","expiry":"01/23","cv3":"1231"}]
```

Verify rotation of secrets
===

Follow the application logs in the **Terminal** tab.

```shell
kubectl logs -l app=payments -f
```

Wait about three minutes and make a second request to the API in the **API Request** tab.

```shell
curl localhost/paymentcard/1
```

The application retrieves a static secret and the database username and password from Vault.
It rotates the database credentials after a few minutes.

```shell,nocopy
2025-01-11T01:09:17.485Z  INFO 1 --- [workshop-spring-vault] [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port 8080 (http) with context path '/'
2025-01-11T01:09:17.496Z  INFO 1 --- [workshop-spring-vault] [           main] opSpringVaultApplication$$SpringCGLIB$$0 : rebuild database secrets: v-kubernet-writer-OKLunExkzEFDwllLE0vX-1736557753,yx-aRt4iXufAs8bgiPTD
2025-01-11T01:09:17.512Z  INFO 1 --- [workshop-spring-vault] [           main] opSpringVaultApplication$$SpringCGLIB$$0 : rebuild client using static secrets: nic,Sec0ndVersion
## omitted
2025-01-11T01:10:18.048Z  INFO 1 --- [workshop-spring-vault] [nio-8080-exec-1] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2025-01-11T01:10:18.273Z  INFO 1 --- [workshop-spring-vault] [nio-8080-exec-1] com.zaxxer.hikari.pool.HikariPool        : HikariPool-1 - Added connection org.postgresql.jdbc.PgConnection@4b3e9076
2025-01-11T01:10:18.274Z  INFO 1 --- [workshop-spring-vault] [nio-8080-exec-1] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
## omitted
2025-01-11T01:10:54.136Z  INFO 1 --- [workshop-spring-vault] [g-Cloud-Vault-2] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown initiated...
2025-01-11T01:10:54.143Z  INFO 1 --- [workshop-spring-vault] [g-Cloud-Vault-2] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown completed.
2025-01-11T01:10:54.144Z  INFO 1 --- [workshop-spring-vault] [g-Cloud-Vault-2] c.e.w.VaultRefresher                     : application refreshes database credentials
2025-01-11T01:11:36.773Z  INFO 1 --- [workshop-spring-vault] [nio-8080-exec-5] opSpringVaultApplication$$SpringCGLIB$$0 : rebuild database secrets: v-kubernet-writer-0DXviIffojedsKMmQRLM-1736557854,6V-vDEZjXKN2vNVTGKY9
2025-01-11T01:11:36.780Z  INFO 1 --- [workshop-spring-vault] [nio-8080-exec-5] com.zaxxer.hikari.HikariDataSource       : HikariPool-2 - Starting...
2025-01-11T01:11:36.812Z  INFO 1 --- [workshop-spring-vault] [nio-8080-exec-5] com.zaxxer.hikari.pool.HikariPool        : HikariPool-2 - Added connection org.postgresql.jdbc.PgConnection@430d4690
2025-01-11T01:11:36.813Z  INFO 1 --- [workshop-spring-vault] [nio-8080-exec-5] com.zaxxer.hikari.HikariDataSource       : HikariPool-2 - Start completed.
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
 id | user_id |        name         |                                                                                                                                                                                                                                                                                                                                                        number                                                                                                                                                                                                                                                                                                                                                         | expiry | cv3
----+---------+---------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------+------
  1 |     123 | Mr Nicholas Jackson | 12313434                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | 01/23  | 1231
  2 |     456 | Mr Nicholas Jackson | vault:v1:LH5Gfh1Meh1S19hSvBNKnnCnH+M7q9yrNCYLpzaAbLNjJCOiZQQbjDnXHrKaiQh0vUNtTWr/fDfpyW5AOBZApN2gXUL+5Mv0+oCINGjoCnNaTSX5ONMRNcnZXAAwOXOV3K6EjHJcYw98Ym8JaktnYAMx/et5zzZhnWMnJt+C21XLAlVixFTpRUm2ViK+AxOuZyzrOZVYR1Czo+kIRzYF7H7BozwiCytlXbgSoyuY7C4pHTIrO4JPIzLN3gpTumlQZY9hTSF0UvgqLelgI2wnBHsn5BwDtg1uFTNTEud+egbhaZiBUJ0vo2h+tsoeXnPdFsvvBYeKVlr66ASq3LvdaUpxX9bOItHRpy8jQdnpM9DEKD/DRSNLVPjZBrnaR3jPcfKVN4D2+hdcncawl0yMV1v701d0r6eRBtP9opoakFA4dgxN85sw/Mb51kPTxZqwtI4VhvZGRs2hsZL0YEP+B/hhZR4Yw/LTHxixFhVahxXg+MifycNlgnE2wUMAg+mY+98wceUHgbsxewf7iBzfss7oZWuFN5apUdUZelp0aMYRZEttLhKAfbAlll8dba+B+gElGX2LE+p/QEjra9IIOUy4nC6iWd/GXUerib6gykSFzybQ4q/nHssGOOdsqqBdLPbVLoQqJNC4UewH1QXuPGYHlCwCmGOwogUIFKED7M0= | 01/26  | 9081
(2 rows)
```

Summary
===

In this section, you learned how to:

1. Enable Vault's Kubernetes authentication method.
2. Configure a Spring Boot application to use the Kubernetes authentication  method.
3. Deploy and verify the application runs properly.
