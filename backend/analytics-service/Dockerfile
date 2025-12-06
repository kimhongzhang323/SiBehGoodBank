# Build stage
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app

# Copy Maven wrapper and POM files
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY common/pom.xml common/
COPY analytics-service/pom.xml analytics-service/

# Download dependencies
RUN chmod +x mvnw && ./mvnw dependency:go-offline -pl analytics-service -am -B

# Copy source code
COPY common/src common/src
COPY analytics-service/src analytics-service/src

# Build the application
RUN ./mvnw package -pl analytics-service -am -DskipTests -B

# Runtime stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Add non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copy built artifact
COPY --from=build /app/analytics-service/target/*.jar app.jar

# Set ownership
RUN chown -R appuser:appgroup /app

USER appuser

# JVM configuration for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0 -Djava.security.egd=file:/dev/./urandom"

EXPOSE 8086

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
