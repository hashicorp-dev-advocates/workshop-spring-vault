---
slug: kubernetes-test-application
id: rtfe9ynulx6t
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
- id: eif5s1szrkkf
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
- id: moixp5bairqj
  title: API Request
  type: terminal
  hostname: sandbox
  workdir: /root
- id: focxw1mjwrgf
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

Open `k8s/app.yaml` in the **Code** tab. Verify that it includes a `ServiceAccount` named
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

Open `k8s/app.yaml` in the **Code** tab. Verify that it includes a `ConfigMap` named
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
    spring.cloud.vault.authentication=KUBERNETES
    spring.cloud.vault.kubernetes.role=payments

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

Open `k8s/app.yaml` in the **Code** tab. Verify that it includes a `Deployment` named
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

Apply the Kubernetes manifests for the application using the **Terminal** tab.

```shell
kubectl apply -f k8s/app.yaml
```

Check that the application starts using the **Terminal** tab.

```shell
kubectl get pods -l app=payments
```

After a minute or two, the pod should be running.

```shell,nocopy
NAME                        READY   STATUS    RESTARTS   AGE
payments-6468f7c94b-p6zg9   1/1     Running   0          43s
```

Test the application
===

Follow the application logs in the **Terminal** tab.

```shell
kubectl logs -l app=payments -f
```

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

Use CTRL-C to exit the application logs in the **Terminal** tab.

Verify encrypted credit card number in database
===

Make a request to the application to create a new payment card record in the **API Request** tab.

```shell
curl localhost/paymentcard  -H "content-type: application/json" \
  -d '{
        "user_id": 789,
        "name": "Mr Nicholas Jackson",
        "number": "7890123456",
        "expiry":"02/25",
        "cv3": "8070"
      }'
```

The request returns a new payment card record with the credit card number in plaintext.

```shell,nocopy
[{"id":3,"user_id":789,"name":"Mr Nicholas Jackson","number":"7890123456","expiry":"02/25","cv3":"8070"}]
```

Get a database username and password from Vault to read from the database
in the **Terminal** tab.

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

The command outputs three records. You just added the third record by making a request
to the Kubernetes application. It encrypted the credit card number before storing the data in the database.

```shell,nocopy
 id | user_id |        name         |                                                                                                                                                                                                                                                                                                                                                        number                                                                                                                                                                                                                                                                                                                                                         | expiry | cv3  
----+---------+---------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------+------
  1 |     123 | Mr Nicholas Jackson | 12313434                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | 01/23  | 1231
  2 |     456 | Mr Nicholas Jackson | vault:v1:rR1zWbnDCWp+C87MLVQdeSsFSwTuo6Dc4JY3KQUfDXkUsRxn+pJObzqvlweXKUd06RFEeMl4sxK1lgfIx9bUyHMhDgqGLpZFmT8HoUkTr7D4RRLq9G+7T53w6x5dHvcnGcmoNZuioStchb+IE4JmWnwpN8N6bSf/dMjXudyQ+gNfwomoeSL609A53biFezu/kUPi8Kh1mlzpxu5CLZh/kunWi6pSR12CQsqsePKG/y+PrWplu8pCiCkJd1e/PW0mNNjnqonPaCILRoEvYzaj+JMbY4TGCblo3n5SDFXUYSJuxefy8keVedKXXXYpXk0dIBXlFXfbOMrY6MpSqV9HmAGXxOpaC60dtgztVSEcN4j0rKuQ3KRT1J3qcvLU8Dkm0MySJjRy6uYbgGwGVqcI2T+oaUuZS9ZE9rMPv8BUdLNyjk3Wl7APAhOHdIX/BzG91QOMgnvy1ExeDlWStpLobKmTIFZ4iVrPqdAdjX47gQJ4C07FYmgMcsoFbinpHIsg2VNWgJ+rmI1sNPfQ5XLiQgtwx9Q30jtYqXmWH2QZ3J0MOvfqMHIO70S0OsWIs0r2xkCTgdJwQsCQ0fwsMOtrRl/Y15/ez+/c+mKrkCurIULhDVILG1GYoaM7jGIctX+cCOy1h5YCpRfnIcuXb/b5mqW8NYnYH5qIlQKXdvC5j0Q= | 01/26  | 9081
  3 |     789 | Mr Nicholas Jackson | vault:v1:Fdz+K2pcGtMZNurF6PD+FuX/DMtqsWlTGpPncdCykMB12l17ltsHyKrGulQyFnmIW/BevbbQ2JzTToXbwWj+hWV/i/D1fY53gTqMveGsieK3ZRV6K0eqeyaacvFAjoz8kfKKAawrWzTVGl0lo/iKSaBF/DNnEhEsHp9+98OkThNK8ZCPUPmlYntyCJt1xtdxn6ML/eJX+aQy4K6xLeAk9cMTXehEZXEyN8o8mdAHU4rzM81C7S+4+QC5r/hNI6/AZXqXyCG9BKYhC2vu69gga3NzuxzkRclTLH5XbRnRVcAW7WeX4LktOXxCgFTHHpGMuRJlTOU4wzSgVRGIKIb0PpTppXSB75d4QODXZlGtQYsfd44u6khg2RT+n/NP5Ri6XN28MV4aQZshdVH0v/iWt7DFZEPuuU5F8EM9YhOEAuwsazrw72qnyQ+TphGUj5iiziIDlv9Xd4mKwWAtNXs0Y7/bgspRXD+G4v9WRpv+RhlOWI1WXhJ5ayKj9gfZg520E6tEiDJViWMbp6PFEXf8jAdlzSdowurCW2ejLGNS2q0frDpVDvv6aaexhcSrP5TC7IRkPE3PF2absdX4Ca9eCTUQ2CLNDF1jgf+sBOAZDvTIvhAi4KMJ/daJLy5qR+nyXu9m19kU0A5G9Vpuoa/s8+7it6WQTOeuodbZstqnx1Q= | 02/25  | 8070
(3 rows)
```

Summary
===

In this section, you learned how to:

1. Enable Vault's Kubernetes authentication method.
2. Configure a Spring Boot application to use the Kubernetes authentication  method.
3. Deploy and verify the application runs properly.
