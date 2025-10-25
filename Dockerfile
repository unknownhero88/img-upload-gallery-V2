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

# Copy compiled classes and dependencies
COPY --from=build /build/target/classes ./target/classes
COPY --from=build /build/target/dependency ./target/dependency

# Copy webapp (JSPs, web.xml, etc.)
COPY --from=build /build/src/main/webapp ./src/main/webapp

# Environment variable for Render
ENV PORT=10000

# Render automatically assigns a random port,
# so we map our Java app to it dynamically
EXPOSE 10000

# Run the embedded Tomcat starter class
CMD ["java", "-cp", "target/classes:target/dependency/*", "com.example.MainClass"]
