#!/bin/bash

echo "Starting AI Agent System (Simple Java compilation)..."

# Compile Java sources
echo "Compiling Java sources..."
find src/main/java -name "*.java" > sources.txt

mkdir -p target/classes

# Set classpath - we'll download dependencies to a lib folder
if [ ! -d "lib" ]; then
    mkdir lib
    echo "Downloading dependencies..."
    
    # Download Spring Boot and related JARs
    curl -s -o lib/spring-boot-starter-web-3.2.0.jar https://repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-web/3.2.0/spring-boot-starter-web-3.2.0.jar
    curl -s -o lib/spring-boot-starter-webflux-3.2.0.jar https://repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-webflux/3.2.0/spring-boot-starter-webflux-3.2.0.jar
    
    echo "Dependencies downloaded."
fi

CLASSPATH="lib/*:target/classes"

# Compile
javac -cp "$CLASSPATH" -d target/classes @sources.txt

if [ $? -eq 0 ]; then
    echo "Compilation successful!"
    
    # Copy resources
    cp -r src/main/resources/* target/classes/
    
    echo "Starting application..."
    java -cp "$CLASSPATH" com.enable.Application
else
    echo "Compilation failed!"
    exit 1
fi
