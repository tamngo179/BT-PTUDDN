# Multi-stage Dockerfile for Spring Boot Course Tracker Application

# Stage 1: Build stage
FROM maven:3.9.8-amazoncorretto-21 AS build

# Set working directory
WORKDIR /app

# Copy Maven wrapper and properties first (for better caching)
COPY .mvn .mvn
COPY mvnw mvnw.cmd ./

# Make Maven wrapper executable
RUN chmod +x ./mvnw

# Copy POM file for dependency resolution
COPY pom.xml ./

# Download dependencies (cached layer if pom.xml doesn't change)
RUN ./mvnw dependency:resolve

# Copy source code
COPY src ./src

# Build the application (skip tests for faster build)
RUN mvn clean package -DskipTests

# Stage 2: Runtime stage
FROM amazoncorretto:21.0.4

# Create non-root user for security. Do mặc định trong Docker, container chạy bằng root.
RUN yum update -y && \
    yum install -y shadow-utils && \
    useradd -r -s /bin/false appuser && \
    yum clean all

# yum: Trình quản lý gói trên Amazone Linux/CentOS

# Set working directory
WORKDIR /app

# Copy built JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Copy startup script
COPY start.sh /app/start.sh

# Make script executable and change ownership to non-root user
RUN chmod +x /app/start.sh && \
    chown appuser:appuser /app/app.jar /app/start.sh

# Switch to non-root user
USER appuser

# Expose port 8080
EXPOSE 8080

# Install curl for health checks (need to switch to root temporarily)
USER root
RUN yum install -y curl && yum clean all
USER appuser

# Health check (using main endpoint since no actuator)
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# Environment variables
ENV SERVER_PORT=8080 \
    SPRING_PROFILES_ACTIVE=default

# Run the application using startup script
ENTRYPOINT ["/app/start.sh"]