# Build stage
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY common/pom.xml common/
COPY notification-service/pom.xml notification-service/

RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

COPY common/src common/src
COPY notification-service/src notification-service/src

RUN ./mvnw clean package -pl common,notification-service -am -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

RUN addgroup -g 1001 -S appgroup && adduser -u 1001 -S appuser -G appgroup

COPY --from=build /app/notification-service/target/*.jar app.jar

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8085

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8085/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "-Dspring.profiles.active=docker", "app.jar"]
