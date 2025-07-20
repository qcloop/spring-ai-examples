#!/bin/bash

# Script to build and run Spring AI examples
# Usage: ./run-example.sh <project-directory-name>
# Example: ./run-example.sh agentic-patterns/chain-workflow

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Base directory for Spring AI examples
BASE_DIR=$(dirname "$(readlink -f "$0")")

# Check if project name is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Project directory not specified${NC}"
    echo "Usage: ./run-example.sh <project-directory-name>"
    echo "Example: ./run-example.sh agentic-patterns/chain-workflow"
    exit 1
fi

PROJECT_PATH="$BASE_DIR/$1"

# Check if project directory exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Project directory not found: $PROJECT_PATH${NC}"
    exit 1
fi

# Check if pom.xml exists
if [ ! -f "$PROJECT_PATH/pom.xml" ]; then
    echo -e "${RED}Error: pom.xml not found in $PROJECT_PATH${NC}"
    echo "This script is for Maven-based Spring AI examples only."
    exit 1
fi

# Function to display section header
function section() {
    echo -e "\n${YELLOW}======== $1 ========${NC}"
}

# Navigate to project directory
cd "$PROJECT_PATH"
PROJECT_NAME=$(basename "$PROJECT_PATH")

section "Building $PROJECT_NAME"
echo "Running mvn clean package..."
./mvnw clean package

section "Running $PROJECT_NAME"
echo "Starting the application..."
./mvnw spring-boot:run

echo -e "\n${GREEN}Execution completed successfully!${NC}"