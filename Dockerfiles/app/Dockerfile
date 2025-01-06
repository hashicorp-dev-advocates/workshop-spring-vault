FROM openjdk:23

COPY ../../target/workshop-spring-vault-0.0.1-SNAPSHOT.jar /workshop-spring-vault-0.0.1-SNAPSHOT.jar

ENTRYPOINT ["java", "-Dspring.config.location=/config/application.properties", "-jar",  "/workshop-spring-vault-0.0.1-SNAPSHOT.jar"]