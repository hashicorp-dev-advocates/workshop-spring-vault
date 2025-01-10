---
slug: encryption-encrypt-application-data
id: txupfk42ixrk
type: challenge
title: Encryption - Encrypt application data
teaser: Refactor the Spring application to encrypt data before storing it in a database.
notes:
- type: text
  contents: |-
    The transit secrets engine path and key stored in Vault reference a custom application property `custom.transit`.
    In general, Spring Boot recommends defining custom application properties using the `@ConfigurationProperties`
    annotation instead of injecting them directly using `@Value`. This provides flexibility in updating
    the configuration, should you require multiple encryption keys or configuration properties.
tabs:
- id: wxxzgaunz3xi
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
- id: ckmu8yyzrfat
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---


Recall that you created an encryption key in Vault at `transit/keys/payments`
with custom configuration properties named `custom.transit.path`
and `custom.StaticSecret.key` to allow the application to access
the encryption key.

> [!NOTE]
> You may find [examples](https://github.com/nicholasjackson/workshop-spring-vault/blob/main/src/main/java/com/example/springvault/entity/PaymentCard.java#L14)
> that use [JPA entity listeners](https://www.baeldung.com/jpa-entity-lifecycle-events)
> to handle the encryption and decryption of data before JPA writes data to the database.
> The Spring community has moved away from using JPA and instead using records. This section of the workshop
> does not leverage `@EntityListeners` to abstract decryption and encryption of data into the database,
> as this example Spring Boot application does not use JPA repository.

Verify custom application properties
===

Open `src/main/java/com/example/workshop_spring_vault/AppProperties.java` in the **Code** tab.

The file defines a set of custom application properties using the `@ConfigurationProperties` annotation.
The custom properties have a prefix named `custom` and sub-properties under `Transit`.

```java
@ConfigurationProperties(prefix = "custom")
public class AppProperties {
    private Transit transit = new Transit();
    // omitted

    public Transit getTransit() {
        return transit;
    }

    public void setTransit(Transit transit) {
        this.transit = transit;
    }

    static class Transit {

        private String path;
        private String key;

        public String getPath() {
            return path;
        }

        public void setPath(String path) {
            this.path = path;
        }

        public String getKey() {
            return key;
        }

        public void setKey(String key) {
            this.key = key;
        }
    }

    // omitted
}
```

Reference transit secrets engine path in object
===

Open `src/main/java/com/example/workshop_spring_vault/VaultTransit.java` in the **Code** tab.

This class defines `VaultTransit` operations for encrypting and decrypting a payload. It uses the
`opsForTransit` method in the Spring Vault library to interface with the Vault API. This abstraction
supports addition of any other logic you want to include as part of the encryption or decryption process.

```java,nocopy
class VaultTransit {
    private final VaultOperations vault;
    private final String path;
    private final String key;

    VaultTransit(AppProperties properties, VaultTemplate vaultTemplate) {
        this.vault = vaultTemplate;
        this.path = properties.getTransit().getPath();
        this.key = properties.getTransit().getKey();
    }

    String decrypt(String payload) {
        return vault.opsForTransit(path).decrypt(key, payload);
    }

    String encrypt(String payload) {
        return vault.opsForTransit(path).encrypt(key, payload);
    }
}
```

Inject Vault transit operations into controller
===

Open `src/main/java/com/example/workshop_spring_vault/PaymentController.java` in the **Code** tab.

The method `getPaymentById` uses the `vaultTransit.decrypt` method to decrypt any ciphertext or
return any plaintext. However, the method `createPayment` does not encrypt the credit card number
and inserts the record as plaintext into the database.

```java,nocopy
@Controller
@ResponseBody
class PaymentController {
    private final JdbcClient db;
    private final VaultTransit vaultTransit;

    PaymentController(DataSource dataSource,
                      AppProperties appProperties,
                      VaultTemplate vaultTemplate) {
        this.db = JdbcClient.create(dataSource);
        this.vaultTransit = new VaultTransit(appProperties, vaultTemplate);
    }

    private SequencedCollection<Payment> getPaymentById(JdbcClient db, String id) {
        return db
                .sql(String.format("SELECT * FROM payment_card WHERE id = '%s'", id))
                .query((rs, rowNum) -> new Payment(
                        rs.getLong("id"),
                        rs.getLong("user_id"),
                        rs.getString("name"),
                        rs.getString("number").startsWith("vault") ?
                                vaultTransit.decrypt(rs.getString("number")) :
                                rs.getString("number"),
                        rs.getString("expiry"),
                        rs.getString("cv3")
                )).list();
    }

    // omitted

    @PostMapping(path = "/paymentcard",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    Collection<Payment> createPayment(@RequestBody Payment request) {
        var statement = String.format(
                "INSERT INTO payment_card(user_id, name, number, expiry, cv3) "
                        + "VALUES('%s', '%s', '%s', '%s', '%s') "
                        + "RETURNING id",
                request.userId(),
                request.name(),
                request.number(),
                request.expiry(),
                request.cv3());
        var id = this.db.sql(statement).query((rs, rowNum) -> valueOf(
                rs.getLong("id")
        )).list();

        return getPaymentById(this.db, id.get(0).toString());
    }
}
```

Update `src/main/java/com/example/workshop_spring_vault/PaymentController.java` in the **Code** tab
to encrypt the credit card number before storing it in the database.

<details>
<summary><b>Solution</b></summary>
Add the <code>vaultTransit.encrypt</code> method to the <code>createPayment</code> method.

```java
    @PostMapping(path = "/paymentcard",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    Collection<Payment> createPayment(@RequestBody Payment request) {
        var statement = String.format(
                "INSERT INTO payment_card(user_id, name, number, expiry, cv3) "
                        + "VALUES('%s', '%s', '%s', '%s', '%s') "
                        + "RETURNING id",
                request.userId(),
                request.name(),
                vaultTransit.encrypt(request.number()),
                request.expiry(),
                request.cv3());
        var id = this.db.sql(statement).query((rs, rowNum) -> valueOf(
                rs.getLong("id")
        )).list();

        return getPaymentById(this.db, id.get(0).toString());
    }
```
</details>

Next, test the application.