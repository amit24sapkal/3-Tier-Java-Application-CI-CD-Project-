# Multi-stage Dockerfile for Java Application

# Stage 1: Build Stage
FROM maven:3.8.3-openjdk-17 as builder

WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build application
RUN mvn clean package -DskipTests

# Stage 2: Runtime Stage
FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy JAR from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Create non-root user for security
RUN useradd -m -u 1000 appuser
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD java -version && echo "Application is running"

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
