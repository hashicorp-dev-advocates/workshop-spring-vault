package com.example.workshop_spring_vault;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;

import javax.sql.DataSource;

@SpringBootApplication
@EnableConfigurationProperties(AppProperties.class)
public class WorkshopSpringVaultApplication {

	private final Log log = LogFactory.getLog(getClass());

	public static void main(String[] args) {
		SpringApplication.run(WorkshopSpringVaultApplication.class, args);
	}

	@Bean
	@RefreshScope
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
