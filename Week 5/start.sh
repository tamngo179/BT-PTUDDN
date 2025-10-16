#!/bin/bash

# Simple startup script for Spring Boot Course Tracker Application

echo "🚀 Starting Course Tracker Application..."
echo "================================================"

# Set default values
export SERVER_PORT="${SERVER_PORT:-8080}"
export SPRING_PROFILES_ACTIVE="${SPRING_PROFILES_ACTIVE:-default}"

# Display configuration
echo "Configuration:"
echo "  - Server Port: $SERVER_PORT"
echo "  - Spring Profile: $SPRING_PROFILES_ACTIVE"
echo "  - Java Version: $(java -version 2>&1 | head -n 1)"

# JVM Options
JVM_OPTS="-XX:+UseG1GC -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError"

# Application Arguments
APP_ARGS="--server.port=$SERVER_PORT --spring.profiles.active=$SPRING_PROFILES_ACTIVE"

echo "Starting application..."
echo "================================================"

# Start the application
exec java $JVM_OPTS -jar /app/app.jar $APP_ARGS