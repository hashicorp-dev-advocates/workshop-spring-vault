---
slug: dynamic-secrets-inject-secret-into-application
id: yv2ly8bhcohk
type: challenge
title: Dynamic Secrets - Inject secret into application
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
- id: rjrulgzvi80q
  title: Code
  type: code
  hostname: sandbox
  path: /root/workshop-spring-vault
- id: hwwfgdrxihfx
  title: Terminal
  type: terminal
  hostname: sandbox
  workdir: /root/workshop-spring-vault
difficulty: ""
enhanced_loading: null
---

Recall that Vault generates a database username and password to inject into `spring.datasource.username`
and `spring.datasource.password` application properties. Use these application properties in your
code to authenticate to the database and establish a connection.

Inject username and password into a controller
===

Open `src/main/java/com/example/workshop_spring_vault/PaymentController.java` in the **Code** tab.

This class defines an API endpoint that returns a list of payment cards. Spring Boot
injects the `DataSource` to enable `JdbcClient` to connect to the database.

```java,nocopy
@Controller
@ResponseBody
class PaymentController {
    private final JdbcClient db;
    // omitted

    PaymentController(DataSource dataSource,
                      AppProperties appProperties, // omitted) {
        this.db = JdbcClient.create(dataSource);
        // omitted
    }
    
    // omitted
}
```

Let's define the `DataSource` based on the datasource application properties.

Refresh application when secret changes
===

Open `src/main/java/com/example/workshop_spring_vault/WorkshopSpringVaultApplication.java` in the **Code** tab.

This main file defines an `DataSource` Bean that should be injected into the application.
Note that the Bean returns a new `DataSource` once Spring Cloud Vault gets a new username and password
from Vault and updates the properties.

```java,nocopy
// omitted
@SpringBootApplication
@EnableScheduling
@EnableConfigurationProperties(AppProperties.class)
public class WorkshopSpringVaultApplication {

	private final Log log = LogFactory.getLog(getClass());

	public static void main(String[] args) {
		SpringApplication.run(WorkshopSpringVaultApplication.class, args);
	}

	@Bean
	DataSource dataSource(DataSourceProperties properties) {
		log.info("rebuild database secrets: " +
				properties.getUsername() +
				"," +
				properties.getPassword()
		);

		return DataSourceBuilder
				.create()
				.url(properties.getUrl())
				.username(properties.getUsername())
				.password(properties.getPassword())
				.build();
	}

	// omitted
}
```

In order to properly support an application context refresh, you must completely rebuild
any objects that reference the secret and define the object as a Bean. If you do not, the
application will not identify the objects that require new secrets. Use the `@Bean` and
[`@RefreshScope`](https://docs.spring.io/spring-cloud-commons/reference/spring-cloud-commons/application-context-services.html#refresh-scope)
annotations to reload the object.

The application needs to track when the secret expires. Once the application identifies
that it needs a new database username and password, it can reload application context and
retrieve a new set of credentials from Vault.

Open `src/main/java/com/example/workshop_spring_vault/VaultRefresher.java` in the **Code** tab.

This file includes a constructor called `VaultRefresher` that uses the Spring Vault library
to add a lease listener. The lease listener checks if the secret lease will expire. If it does,
then the application refreshes context and loads new database credentials from Vault.

```java,nocopy
    VaultRefresher(
            SecretLeaseContainer leaseContainer,
            ContextRefresher contextRefresher) {
        final Log log = LogFactory.getLog(getClass());

        this.contextRefresher = contextRefresher;

        leaseContainer.addLeaseListener(event -> {
            if (event instanceof SecretLeaseExpiredEvent) {
                contextRefresher.refresh();
                log.info("application refreshes database credentials");
            }
        });
    }
```

Vault revokes the old credentials once they expire.

Update `src/main/java/com/example/workshop_spring_vault/WorkshopSpringVaultApplication.java` in the **Code** tab.

You will need to the `@RefreshScope` annotation to refresh the `DataSource` each time the properties change.

<details>
<summary><b>Solution</b></summary>
Add two annotations to enable scheduling for the application and refresh scope for the bean
in the <b>Code</b> tab.

```java
// omitted
@SpringBootApplication
@EnableScheduling
@EnableConfigurationProperties(AppProperties.class)
public class WorkshopSpringVaultApplication {

    private final Log log = LogFactory.getLog(getClass());

    public static void main(String[] args) {
        SpringApplication.run(WorkshopSpringVaultApplication.class, args);
    }

    @Bean
    @RefreshScope // add annotation to refresh this bean
    DataSource dataSource(DataSourceProperties properties) {
        log.info("rebuild database secrets: " +
                properties.getUsername() +
                "," +
                properties.getPassword()
        );

        return DataSourceBuilder
                .create()
                .url(properties.getUrl())
                .username(properties.getUsername())
                .password(properties.getPassword())
                .build();
    }

    // omitted
}
```
</details>

Next, test the application.