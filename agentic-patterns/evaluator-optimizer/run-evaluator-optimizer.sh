#!/bin/bash

# Script to build and run the Evaluator-Optimizer example with verification
# Usage: ./run-evaluator-optimizer.sh

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "$SCRIPT_DIR"

# Initialize error counter
ERRORS=0

# Function to display section header
function section() {
    echo -e "\n${YELLOW}======== $1 ========${NC}"
}

# Build the project
section "Building Evaluator-Optimizer"
echo "Running mvn clean package..."
if ! ./mvnw clean package; then
    echo -e "${RED}Build failed! Cannot continue.${NC}"
    exit 1
fi

# Run the application and capture output
section "Running Evaluator-Optimizer"
echo "Starting the application..."
OUTPUT_FILE=$(mktemp)
./mvnw spring-boot:run | tee "$OUTPUT_FILE" || true

section "Verifying Output"

# Check if the application completed successfully
if ! grep -q "BUILD SUCCESS" "$OUTPUT_FILE"; then
    echo -e "${RED}ERROR: Application did not complete successfully${NC}"
    ERRORS=$((ERRORS+1))
fi

# Check for PASS evaluation in the final output
if grep -q "EVALUATION: PASS" "$OUTPUT_FILE"; then
    echo -e "${GREEN}✓ Final evaluation PASSED${NC}"
else
    echo -e "${RED}ERROR: Final evaluation did not PASS${NC}"
    ERRORS=$((ERRORS+1))
fi

# Check for FINAL OUTPUT message
if grep -q "FINAL OUTPUT:" "$OUTPUT_FILE"; then
    echo -e "${GREEN}✓ Final output generated successfully${NC}"
else
    echo -e "${RED}ERROR: Final output not found${NC}"
    ERRORS=$((ERRORS+1))
fi

section "Checking Stack Implementation Requirements"

# 1. Check for push method
if grep -q "public void push" "$OUTPUT_FILE"; then
    echo -e "${GREEN}✓ push(x) method implemented correctly${NC}"
else
    echo -e "${RED}ERROR: push method not implemented correctly${NC}"
    ERRORS=$((ERRORS+1))
fi

# 2. Check for pop method
if grep -q "public void pop" "$OUTPUT_FILE" || grep -q "public int pop" "$OUTPUT_FILE"; then
    echo -e "${GREEN}✓ pop() method implemented correctly${NC}"
else
    echo -e "${RED}ERROR: pop method not implemented correctly${NC}"
    ERRORS=$((ERRORS+1))
fi

# 3. Check for getMin method
if grep -q "public int getMin" "$OUTPUT_FILE"; then
    echo -e "${GREEN}✓ getMin() method implemented correctly${NC}"
else
    echo -e "${RED}ERROR: getMin method not implemented correctly${NC}"
    ERRORS=$((ERRORS+1))
fi

# 4. Check for private fields
if grep -q "private" "$OUTPUT_FILE"; then
    echo -e "${GREEN}✓ private fields used${NC}"
else
    echo -e "${RED}ERROR: private fields not found${NC}"
    ERRORS=$((ERRORS+1))
fi

# 5. Check for 'this.' keyword usage
if grep -q "this\." "$OUTPUT_FILE"; then
    echo -e "${GREEN}✓ 'this.' keyword used correctly${NC}"
else
    echo -e "${RED}ERROR: 'this.' keyword usage not found${NC}"
    ERRORS=$((ERRORS+1))
fi

# 6. Check for JavaDoc style comments
if grep -q "\/\*\*" "$OUTPUT_FILE" && grep -q "\* @" "$OUTPUT_FILE"; then
    echo -e "${GREEN}✓ JavaDoc documentation present${NC}"
else
    echo -e "${RED}ERROR: JavaDoc documentation not properly implemented${NC}"
    ERRORS=$((ERRORS+1))
fi

# 7. Check for O(1) operations mention
if grep -q "O(1)" "$OUTPUT_FILE"; then
    echo -e "${GREEN}✓ O(1) operations confirmed${NC}"
else
    echo -e "${RED}ERROR: O(1) operations not confirmed${NC}"
    ERRORS=$((ERRORS+1))
fi

# Verify iterative improvement process
if grep -q "NEEDS_IMPROVEMENT" "$OUTPUT_FILE" && grep -q "PASS" "$OUTPUT_FILE"; then
    echo -e "${GREEN}✓ Iterative improvement process confirmed (NEEDS_IMPROVEMENT → PASS)${NC}"
    echo -e "${CYAN}  The evaluator-optimizer workflow is functioning correctly!${NC}"
else
    echo -e "${RED}ERROR: Could not verify iterative improvement process${NC}"
    ERRORS=$((ERRORS+1))
fi

# Clean up
rm "$OUTPUT_FILE"

# Final result
if [ $ERRORS -eq 0 ]; then
    echo -e "\n${GREEN}✓ Evaluator-Optimizer executed and verified successfully!${NC}"
    echo -e "${GREEN}✓ Stack implementation meets all requirements.${NC}"
    exit 0
else
    echo -e "\n${RED}× Evaluator-Optimizer verification failed with $ERRORS errors!${NC}"
    exit 1
fi