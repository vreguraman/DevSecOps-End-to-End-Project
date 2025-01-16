# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the built JAR file into the container
COPY target/project-0.0.1-SNAPSHOT.jar app.jar

# Expose the port your application listens on (default Spring Boot port)
EXPOSE 8081

# Run the JAR file
CMD ["java", "-jar", "app.jar"]
