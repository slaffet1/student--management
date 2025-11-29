FROM eclipse-temurin:17-jdk
LABEL maintainer='said'
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8083
CMD  ["java", "-jar", "app.jar"]