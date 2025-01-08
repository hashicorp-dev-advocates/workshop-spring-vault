---
slug: static-secrets-inject-secret-into-application
id: yykgfdq9jggh
type: challenge
title: Static Secrets - Inject secret into application
teaser: Refactor the Spring application to inject the secret and refresh the application
  when the secret changes.
notes:
- type: text
  contents: |-
    The username and password stored in Vault reference a custom application property `custom.StaticSecret`.
    In general, Spring Boot recommends defining custom application properties using the `@ConfigurationProperties`
    annotation instead of injecting them directly using `@Value`.

    Injecting the secrets with a custom application property class ensures that any Java Bean using the
    configuration can be refreshed.
tabs:
- id: msu2kctxmcks
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
- id: dydp88944yhn
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

Recall that you stored a username and password at `secret/workshop-spring-vault`
with custom configuration properties named `custom.StaticSecret.username`
and `custom.StaticSecret.password`.

Verify custom application properties
===

Open `src/main/java/com/example/workshop_spring_vault/AppProperties.java` in the **Code** tab.

The file defines a set of custom application properties using the `@ConfigurationProperties` annotation.
The custom properties have a prefix named `custom` and sub-properties under `StaticSecret`.

Inject username and password into a controller
===

Open `src/main/java/com/example/workshop_spring_vault/StaticSecretController.java` in the **Code** tab.

This class defines an API endpoint that returns the static username and password
in plaintext (for example use only). Note that this endpoint shows an example of a
web client (named `ExampleClient`) that connects to a third-party service using the username and password.

```java,nocopy
@Controller
@ResponseBody
class StaticSecretController {
    private final ExampleClient client;

    StaticSecretController(ExampleClient client) {
        this.client = client;
    }

    @GetMapping("/secret")
    public AppProperties.StaticSecret getStaticSecret() {
        return client.getProperties().getStaticSecret();
    }
}
```

Examine the example web client in `src/main/java/com/example/workshop_spring_vault/ExampleClient.java` in the **Code** tab.

It references the custom application properties. While this example returns the properties in plaintext,
you can use this class to pass the properties to a `WebClient` to authenticate to a third-party service.

```java,nocopy
class ExampleClient {
    private final AppProperties properties;

    ExampleClient(AppProperties properties) {
        this.properties = properties;
    }

    public AppProperties getProperties() {
        return properties;
    }
}
```

When the application starts, Spring Cloud Vault retrieves a secret from Vault and
injects into the custom application properties. The `ExampleClient` references the
custom application properties for the static secret, specifically the username and password.

Refresh application when secret changes
===

By using the `@ConfigurationProperties` annotation and an object like `ExampleClient` to use the injected secrets,
your application can refresh objects using the application properties when secrets change in Vault. This means
the application live reloads with new credentials instead of you manually restarting the application each time
a secret changes, this minimizing application downtime.

Since you manually rotate static secrets in Vault, you can set up a time interval for your application
to refresh any objects.

> [!NOTE]
> If you have requirements for your application to immediately reload based on a rotated secret,
> you can write additional code to reload based on key-value events from the
> [Vault Enterprise event stream](https://developer.hashicorp.com/vault/docs/concepts/events).

Open `src/main/java/com/example/workshop_spring_vault/VaultRefresher.java` in the **Code** tab.

This file includes a method called `refresher` that runs on a delay defined by a custom property.
The custom property in this example has a delay of three minutes.
Each time the `refresher` method runs, it refreshes the application context.

```java,nocopy
    @Scheduled(initialDelayString="${custom.refresh-interval-ms}",
            fixedDelayString = "${custom.refresh-interval-ms}")
    void refresher() {
        contextRefresher.refresh();
        log.info("application refreshes static secret");
    }
```

Open `src/main/java/com/example/workshop_spring_vault/WorkshopSpringVaultApplication.java` in the **Code** tab.

This main file defines an `ExampleClient` Bean that should be injected into the application.
Note that the Bean returns a new `ExampleClient` once it gets a new username and password
from Vault.

```java,nocopy
// omitted
@SpringBootApplication
@EnableConfigurationProperties(AppProperties.class)
public class WorkshopSpringVaultApplication {

	private final Log log = LogFactory.getLog(getClass());

	public static void main(String[] args) {
		SpringApplication.run(WorkshopSpringVaultApplication.class, args);
	}

	// omitted

	@Bean
	ExampleClient exampleClient(AppProperties properties) {
		log.info("rebuild client using static secrets: " +
				properties.getStaticSecret().getUsername() +
				"," +
				properties.getStaticSecret().getPassword()
		);
		return new ExampleClient(properties);
	}
}
```

In order to properly support an application context refresh, you must completely rebuild
any objects that reference the secret and define the object as a Bean. If you do not, the
application will not identify the objects that require new secrets.

Update `src/main/java/com/example/workshop_spring_vault/WorkshopSpringVaultApplication.java` in the **Code** tab.

You will need to add two annotations, `@EnableScheduling` and `@RefreshScope`, to support
scheduled `refresher` task and refresh `ExampleClient` each time the properties change.

<details>
<summary><b>Solution</b></summary>
Add two annotations to enable scheduling for the application and refresh scope for the bean
in the <b>Code</b> tab.

```java
// omitted
@SpringBootApplication
@EnableScheduling // add annotation to enable scheduling
@EnableConfigurationProperties(AppProperties.class)
public class WorkshopSpringVaultApplication {

    private final Log log = LogFactory.getLog(getClass());

    public static void main(String[] args) {
        SpringApplication.run(WorkshopSpringVaultApplication.class, args);
    }

    // omitted

    @Bean
    @RefreshScope // add annotation to refresh this bean
    ExampleClient exampleClient(AppProperties properties) {
        log.info("rebuild client using static secrets: " +
                properties.getStaticSecret().getUsername() +
                "," +
                properties.getStaticSecret().getPassword()
        );
        return new ExampleClient(properties);
    }
}
```
</details>

Next, test the application.