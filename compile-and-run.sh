#!/bin/bash

echo "Compiling and running AI Agent System..."

# Find all Java source files
find src/main/java -name "*.java" > sources.txt

# Set classpath to existing Maven dependencies
CLASSPATH="/Users/jackyzhu/.m2/repository/org/springframework/boot/spring-boot-starter-web/3.2.0/spring-boot-starter-web-3.2.0.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/org/springframework/boot/spring-boot-starter/3.2.0/spring-boot-starter-3.2.0.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/org/springframework/boot/spring-boot/3.2.0/spring-boot-3.2.0.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/org/springframework/boot/spring-boot-autoconfigure/3.2.0/spring-boot-autoconfigure-3.2.0.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/org/springframework/spring-web/6.1.1/spring-web-6.1.1.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/org/springframework/spring-webmvc/6.1.1/spring-webmvc-6.1.1.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/org/springframework/spring-context/6.1.1/spring-context-6.1.1.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/org/springframework/spring-beans/6.1.1/spring-beans-6.1.1.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/org/springframework/spring-core/6.1.1/spring-core-6.1.1.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/org/springframework/boot/spring-boot-starter-webflux/3.2.0/spring-boot-starter-webflux-3.2.0.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/org/springframework/spring-webflux/6.1.1/spring-webflux-6.1.1.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/io/projectreactor/reactor-core/3.6.0/reactor-core-3.6.0.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/org/springframework/web/reactive/function/client/WebClient.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/com/fasterxml/jackson/core/jackson-databind/2.15.3/jackson-databind-2.15.3.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/com/fasterxml/jackson/core/jackson-annotations/2.15.3/jackson-annotations-2.15.3.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/com/fasterxml/jackson/core/jackson-core/2.15.3/jackson-core-2.15.3.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/org/projectlombok/lombok/1.18.30/lombok-1.18.30.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/org/springframework/boot/spring-boot-starter-validation/3.2.0/spring-boot-starter-validation-3.2.0.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/jakarta/validation/jakarta.validation-api/3.0.2/jakarta.validation-api-3.0.2.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/org/slf4j/slf4j-api/2.0.9/slf4j-api-2.0.9.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/ch/qos/logback/logback-classic/1.4.11/logback-classic-1.4.11.jar"
CLASSPATH="$CLASSPATH:/Users/jackyzhu/.m2/repository/ch/qos/logback/logback-core/1.4.11/logback-core-1.4.11.jar"
CLASSPATH="$CLASSPATH:target/classes"

echo "Compiling Java sources..."
javac -cp "$CLASSPATH" -d target/classes @sources.txt

if [ $? -eq 0 ]; then
    echo "Compilation successful!"
    
    # Copy resources
    cp -r src/main/resources/* target/classes/ 2>/dev/null || true
    
    echo "Starting AI Agent System..."
    echo "The application will be available at:"
    echo "  - Backend API: http://localhost:8080/api"  
    echo "  - Frontend UI: http://localhost:8080/index.html"
    echo ""
    echo "Press Ctrl+C to stop the application"
    echo ""
    
    java -cp "$CLASSPATH" com.enable.Application
else
    echo "Compilation failed!"
    exit 1
fi
