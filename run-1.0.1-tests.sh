#!/bin/bash

# Run all integration tests individually for Spring AI 1.0.1
echo "Running Spring AI 1.0.1 Integration Tests"
echo "========================================"
echo ""

RESULTS_FILE="integration-testing/test-1.0.1-results.txt"
> $RESULTS_FILE

# List of all test modules
MODULES=(
    "agentic-patterns/chain-workflow"
    "agentic-patterns/evaluator-optimizer"
    "agentic-patterns/orchestrator-workers"
    "agentic-patterns/parallelization-workflow"
    "agentic-patterns/routing-workflow"
    "agents/reflection"
    "kotlin/kotlin-function-callback"
    "kotlin/kotlin-hello-world"
    "kotlin/rag-with-kotlin"
    "misc/openai-streaming-response"
    "misc/spring-ai-java-function-callback"
    "model-context-protocol/brave"
    "model-context-protocol/client-starter/starter-default-client"
    "model-context-protocol/client-starter/starter-webflux-client"
    "model-context-protocol/dynamic-tool-update/client"
    "model-context-protocol/dynamic-tool-update/server"
    "model-context-protocol/filesystem"
    "model-context-protocol/sqlite/chatbot"
    "model-context-protocol/sqlite/simple"
    "model-context-protocol/weather/starter-webmvc-server"
    "model-context-protocol/web-search/brave-chatbot"
    "model-context-protocol/web-search/brave-starter"
    "models/chat/helloworld"
    "prompt-engineering/prompt-engineering-patterns"
)

PASSED=0
FAILED=0
TIMEOUT=0

echo "Starting tests at $(date)" | tee -a $RESULTS_FILE
echo "" | tee -a $RESULTS_FILE

for i in "${!MODULES[@]}"; do
    MODULE="${MODULES[$i]}"
    TEST_NUM=$((i + 1))
    echo -n "[$TEST_NUM/24] Testing $MODULE... "
    
    if ! cd "$MODULE" 2>/dev/null; then
        echo "❌ FAILED - Directory not found" | tee -a ../../$RESULTS_FILE
        ((FAILED++))
        continue
    fi
    
    # Find the Run*.java file
    RUN_FILE=$(find integration-tests -name "Run*.java" 2>/dev/null | head -1)
    
    if [ -z "$RUN_FILE" ]; then
        echo "❌ FAILED - No integration test found" | tee -a ../../$RESULTS_FILE
        ((FAILED++))
        cd - > /dev/null
        continue
    fi
    
    # Run the test with timeout (increased for prompt-engineering)
    if [ "$MODULE" = "prompt-engineering/prompt-engineering-patterns" ]; then
        TIMEOUT_SEC=180
    else
        TIMEOUT_SEC=120
    fi
    
    if timeout $TIMEOUT_SEC jbang "$RUN_FILE" > /tmp/test-output-$TEST_NUM.log 2>&1; then
        echo "✅ PASSED" | tee -a ../../$RESULTS_FILE
        ((PASSED++))
    else
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 124 ]; then
            echo "⏱️ TIMEOUT (${TIMEOUT_SEC}s)" | tee -a ../../$RESULTS_FILE
            ((TIMEOUT++))
        else
            echo "❌ FAILED (exit code: $EXIT_CODE)" | tee -a ../../$RESULTS_FILE
            ((FAILED++))
        fi
    fi
    
    cd - > /dev/null
done

echo ""
echo "========================================"
echo "Summary for Spring AI 1.0.1:"
echo "  Passed: $PASSED"
echo "  Failed: $FAILED"
echo "  Timeout: $TIMEOUT"
echo "  Total: 24"
echo ""
echo "Completed at $(date)" | tee -a $RESULTS_FILE
echo "Results saved to: $RESULTS_FILE"