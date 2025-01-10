---
slug: kubernetes-configure-authentication
type: challenge
title: kubernetes-configure-authentication
teaser: A short description of the challenge.
notes:
- type: text
  contents: |
    In this section of the workshop, you will learn how to update your application to run on Kubernetes.

    In this section, you will:

    1. Enable Vault's Kubernetes authentication method.
    2. Configure a Spring Boot application to use the Kubernetes authentication  method.
    3. Deploy and verify the application runs properly.
- type: text
  contents: |
    HashiCorp Vault stores and manages your secrets. It can handle two main types of secrets:

    1. Static secrets - you manually write them into Vault as keys and values and handle their rotation.
    2. Dynamic secrets - Vault automatically generates a secret with an expiration date. When the secret expires, Vault deletes it.

    Besides storing secrets, Vault supports different methods of authentication.

    1. User authentication - Once Vault verifies your identity, it provides a token for future requests.
    1. Machine authentication - Once Vault verifies a service or machine identity, it provides a token for future requests.
tabs:
- id: avmy0ctjsd3v
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
- id: 1ncd8zyxna92
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

In previous exercises, you tested your application's connection to Vault **locally**
using a local Vault token with elevated access.

When your application runs in production, you want to use the machine or service's identity
instead of a long-lived, user-generated token to grant the application access to Vault. The identity
must have sufficient permissions to Vault.

Vault uses a system of policies and roles. Policies
define what paths a token can access and what operations can be performed on those
paths. Roles define what policies are associated with an authentication endpoint.

Vault provides the concept of authentication endpoints.  These are endpoints that can be used to authenticate
to Vault using a known secret such as a Kubernetes service account token, a GitHub token, or JSON Web Token.

Verify the authentication method for Kubernetes has already been configured for your
cluster.

```shell
 vault read auth/kubernetes/config
```

The output includes information about authenticating to the Kubernetes cluster, including certificate, host, and more.

```shell,nocopy
Key                                  Value
---                                  -----
disable_iss_validation               true
disable_local_ca_jwt                 false
issuer                               n/a
kubernetes_ca_cert                   -----BEGIN CERTIFICATE-----
MIIBeDCCAR2gAwIBAgIBADAKBggqhkjOPQQDAjAjMSEwHwYDVQQDDBhrM3Mtc2Vy
dmVyLWNhQDE3MzY0NDg5ODAwHhcNMjUwMTA5MTg1NjIwWhcNMzUwMTA3MTg1NjIw
WjAjMSEwHwYDVQQDDBhrM3Mtc2VydmVyLWNhQDE3MzY0NDg5ODAwWTATBgcqhkjO
PQIBBggqhkjOPQMBBwNCAAQzSdLW7NnMx2BnGheScMJhV0P+T/1UAFwOHaadJL3+
x7c9WU1wMuVMCAHcrflSmnfFnV3jiEtjgtHfKHTEFV0to0IwQDAOBgNVHQ8BAf8E
BAMCAqQwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUfXLza4x/WEDL4T7rmW6M
PZ/e1vEwCgYIKoZIzj0EAwIDSQAwRgIhAJPIE4hGMF7tihIXSXi7WdsApUawkR2X
U9G6xn28FEIkAiEAt1Ya91Yx+ADE3Qf7Vd5VsWWG6RfML8SxquJtD4a+eG4=
-----END CERTIFICATE-----
kubernetes_host                      https://10.5.0.4:6443
pem_keys                             []
token_reviewer_jwt_set               true
use_annotations_as_alias_metadata    false
```

Vault's Kubernetes authentication method uses a JSON Web Token (JWT) assigned to your application's service
account to verify a service's identity and access to Vault.

Next, define a policy to allow the application to get static secrets, database credentials, and encryption keys
from Vault.