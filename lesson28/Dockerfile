FROM eclipse-temurin:17-jre-alpine

ARG APP_NAME
ARG JAR_FILE=${APP_NAME}/target/hello-app-1.0-SNAPSHOT.jar

COPY ${JAR_FILE} app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]