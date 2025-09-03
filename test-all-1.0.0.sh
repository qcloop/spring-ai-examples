#!/bin/bash

# Test all examples individually with Spring AI 1.0.0
echo "Testing all examples with Spring AI 1.0.0"
echo "======================================="

PASSED=0
FAILED=0
RESULTS_FILE="integration-testing/test-1.0.0-results.txt"

# Clear results file
> $RESULTS_FILE

# Find all integration tests
TESTS=$(find . -name "Run*.java" -path "*/integration-tests/*" | sort)

for TEST in $TESTS; do
    # Extract module path
    MODULE=$(dirname $(dirname $TEST))
    MODULE_NAME=$(echo $MODULE | sed 's|^\./||')
    
    echo "Testing: $MODULE_NAME"
    
    # Run the test with timeout
    if timeout 120 jbang $TEST > /tmp/test-output.log 2>&1; then
        echo "✅ $MODULE_NAME - PASSED" | tee -a $RESULTS_FILE
        ((PASSED++))
    else
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 124 ]; then
            echo "⏱️ $MODULE_NAME - TIMEOUT" | tee -a $RESULTS_FILE
        else
            echo "❌ $MODULE_NAME - FAILED (exit code: $EXIT_CODE)" | tee -a $RESULTS_FILE
        fi
        ((FAILED++))
    fi
done

echo "======================================="
echo "Results: $PASSED passed, $FAILED failed/timeout out of 24 tests"
echo "Full results saved to: $RESULTS_FILE"