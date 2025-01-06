FROM maven:3.9-eclipse-temurin-23 AS build
COPY pom.xml /app/
COPY src /app/src
RUN mvn -f /app/pom.xml clean package

FROM eclipse-temurin:23
EXPOSE 8080
COPY --from=build /app/target/*.jar /app/app.jar
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-Dspring.config.location=/config/application.properties", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app/app.jar"]