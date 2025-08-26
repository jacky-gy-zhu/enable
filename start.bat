@echo off

REM AI Agent System Startup Script for Windows

echo Starting AI Agent System...

REM Check if OPENAI_API_KEY is set
if "%OPENAI_API_KEY%"=="" (
    echo Warning: OPENAI_API_KEY environment variable is not set.
    echo Please set it using: set OPENAI_API_KEY=your-api-key-here
    echo Or configure it in src/main/resources/application.yml
    echo.
)

REM Check if Java is installed
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Java is not installed or not in PATH
    echo Please install Java 17 or higher
    pause
    exit /b 1
)

REM Check if Maven is installed
mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Maven is not installed or not in PATH
    echo Please install Maven 3.6 or higher
    echo.
    echo Alternative: You can use the Maven wrapper if available:
    echo   .\mvnw.cmd spring-boot:run
    pause
    exit /b 1
)

echo Java version:
java -version 2>&1 | findstr "version"
echo.
echo Maven version:
mvn -version 2>&1 | findstr "Apache Maven"
echo.

REM Build the project
echo Building the project...
mvn clean compile -q

if %errorlevel% neq 0 (
    echo Error: Build failed
    pause
    exit /b 1
)

echo Build successful!
echo.

REM Start the application
echo Starting SpringBoot application...
echo The application will be available at:
echo   - Backend API: http://localhost:8080/api
echo   - Frontend UI: http://localhost:8080/index.html
echo.
echo Press Ctrl+C to stop the application
echo.

mvn spring-boot:run
