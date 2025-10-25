# Stage 1: Build with Maven
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /build

# Copy project files
COPY pom.xml ./
COPY src ./src

# Build the application and copy dependencies
RUN mvn dependency:copy-dependencies package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Copy compiled classes and dependencies
COPY --from=build /build/target/classes ./target/classes
COPY --from=build /build/target/dependency ./target/dependency
COPY --from=build /build/src/main/webapp ./src/main/webapp

# Environment variable for Render
ENV PORT=10000

EXPOSE 10000

# Run the Main class with all dependencies on the classpath
CMD ["java", "-cp", "target/classes:target/dependency/*", "com.example.Main"]
