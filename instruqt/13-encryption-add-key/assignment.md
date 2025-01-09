---
slug: encryption-add-key
type: challenge
title: Encryption - Add an encryption key for the application
teaser: Create an encryption key for the Spring Boot application managed by Vault's transit secrets engine.
notes:
- type: text
  contents: |-
    When you create an encryption key in Vault, Vault has the ability to help rotate the key and rekey any
    data with the new key.
tabs:
- id: dxqqginnkqkb
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
- id: dnolaw0mgnch
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

To encrypt and decrypt data using the transit secrets engine, you need to create
an encryption key. You can create multiple keys for different purposes.
There are also many different types of keys that you can create, such as
AES, RSA, and ECDSA.

In general, create a new key for each application that needs to encrypt data.
This way, you can easily rotate the key without affecting other applications.
Vault securely stores the keys. You cannot retrieve the key unless you
configure the key with a parameter that allows export.

Create a new encryption key
===

Using the Vault CLI, create a new RSA 4096 key in the **Terminal** tab.

<details>
<summary><b>Solution</b></summary>
Run the following command in the <b>Terminal</b> tab.

```shell
vault write -f transit/keys/payments type=rsa-4096
```
</details>

<details>
<summary><b>Verify</b></summary>
After adding the secret, verify that you can read the key's attributes using the following:

```shell
vault read transit/keys/payments
```
</details>

Encrypt data
===

# Encrypt data with Vault

Explore the Vault API by using it to encrypt data based on the key you generated.

Run the following command to encrypt the
credit card number in the **Terminal** tab.
Note the `plaintext` parameter requires base64 encoded text.

```shell
vault write transit/encrypt/payments plaintext=$(base64 <<< "1234-5678-9012-3456")
```

The output will be a `ciphertext` value that you can store in your database.

```shell
Key            Value
---            -----
ciphertext     vault:v1:fbcH6caYot7x1LN7r71GM4KQn7jx5kmUsjb/knr4zFveOXyvgbB25ShGqtPR9kawrQnXWgGNoZakUvwXLYcIKBLTEYbWYYWFWWc5MToGe35jXKQHqNbNc2av2Ccva4HH00abXqUwdhT35F/w4fLtBYtQK8L8towizb4OcdrB/tWUZXFC8P7gF+95hpAWSeGGttIoGo7yLQAat9jNlEH4S4ZN1Pl8JfehRrB6YQwg+BB0fn1gW1XNmF3wa54ZlGAJf+0Sy/CYROkALN1de9nC1ZG1T0c0S5rcJzRsmJ25NjvOU5GV2bfVBtbwzGWXsXzIeuKxioxe26ql6MUh4uiwaWbLAiugVWxva5CKdiBiY8gRW015rLSesr5hZwQvb8EJRH6E7182eJmJSzBhZFZzmAWUSfQjn50Gu2QvBPcP4A69TuNuUa3R5EJ8hX/Kv6ONCUy0IHoR5KDJ5wxpN9J6hOlRNvKfgkF3mQzgIkw7LjLigamtFCrfKzP3V1EGE9m1Dt9SflYmamb/kFyfWFk6PmN41TnTO7bvhDUmF4xreuXuQ+/6RZMgop0zJ3V7cgGJ4s76P0S/I6BKT3XB0k2Nk3wwAZAEE/HN63rii4uXC+L3jHWvJmZILexttBmfSUaWzwp8gawGiAxic7oWGLhr1b7zcUvaw7wl857yI3UgVKA=
key_version    1
```

> [!NOTE]
> The `ciphertext` value is probably going to be larger than the original credit card number, if 
> you have a size limit on the column you may need to increase it.

Your application can use the same API path to encrypt a payload.

Decrypt data with Vault
===

Use the `decrypt` endpoint to decrypt the payload. Rather than passing the `plaintext` property,
you pass a `ciphertext` property.

<details>
<summary><b>Solution</b></summary>
Run the following command in the <b>Terminal</b> tab.

```shell
vault write transit/decrypt/payments ciphertext=<ciphertext>
```
</details>

If you base64-decode the value, you should see the original credit card number.

```shell
echo <plaintext> | base64 --decode
```

In this challenge, you learned how to encrypt and decrypt data using Vault's transit secrets engine.
In the next challenge, a Spring Boot application will use Vault to encrypt and decrypt data in a database.