#!/bin/bash

# AI Agent System Startup Script

echo "Starting AI Agent System..."

# Check if OPENAI_API_KEY is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "Warning: OPENAI_API_KEY environment variable is not set."
    echo "Please set it using: export OPENAI_API_KEY=your-api-key-here"
    echo "Or configure it in src/main/resources/application.yml"
    echo ""
fi

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Error: Java is not installed or not in PATH"
    echo "Please install Java 17 or higher"
    exit 1
fi

# Check Java version
JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt "17" ]; then
    echo "Error: Java 17 or higher is required. Current version: $JAVA_VERSION"
    exit 1
fi

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo "Error: Maven is not installed or not in PATH"
    echo "Please install Maven 3.6 or higher"
    exit 1
fi

echo "Java version: $(java -version 2>&1 | head -1)"
echo "Maven version: $(mvn -version | head -1)"
echo ""

# Build the project
echo "Building the project..."
mvn clean compile -q

if [ $? -ne 0 ]; then
    echo "Error: Build failed"
    exit 1
fi

echo "Build successful!"
echo ""

# Start the application
echo "Starting SpringBoot application..."
echo "The application will be available at:"
echo "  - Backend API: http://localhost:8080/api"
echo "  - Frontend UI: http://localhost:8080/index.html"
echo ""
echo "Press Ctrl+C to stop the application"
echo ""

mvn spring-boot:run
