# Stage 1: Build with Maven
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /build

# Copy project files
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Copy the JAR file
COPY --from=build /build/target/*.jar app.jar

# Copy webapp directory (JSP files)
COPY --from=build /build/src/main/webapp ./src/main/webapp

# Create necessary directories
RUN mkdir -p /app/target/classes

# Expose port
EXPOSE 10000

# Environment variable
ENV PORT=10000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
  CMD curl -f http://localhost:10000/ || exit 1

# Run the application
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
