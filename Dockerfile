# Stage 1: Build with Maven
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /build

# Copy project files
COPY pom.xml ./
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Copy compiled files from build stage
COPY --from=build /build/target/classes ./target/classes
COPY --from=build /build/src/main/webapp ./src/main/webapp

# Environment variable for Render
ENV PORT=10000

# Expose port for local reference (Render ignores EXPOSE)
EXPOSE 10000

# Run your Main class (adjust package if needed)
CMD ["java", "-cp", "target/classes", "com.example.Main"]
