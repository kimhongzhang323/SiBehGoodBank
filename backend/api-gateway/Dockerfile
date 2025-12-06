# Build stage
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY common/pom.xml common/
COPY api-gateway/pom.xml api-gateway/

RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

COPY common/src common/src
COPY api-gateway/src api-gateway/src

RUN ./mvnw clean package -pl common,api-gateway -am -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

RUN addgroup -g 1001 -S appgroup && adduser -u 1001 -S appuser -G appgroup

COPY --from=build /app/api-gateway/target/*.jar app.jar

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "-Dspring.profiles.active=docker", "app.jar"]
