# =========================
# STEP 1 — Build the app
# =========================
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# =========================
# STEP 2 — Run the app
# =========================
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app

# Copy built jar from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Copy .env (optional for local use)
COPY .env .env

# Expose port
EXPOSE 8080

# Run Spring Boot with environment variables
ENTRYPOINT ["java", "-jar", "app.jar"]
