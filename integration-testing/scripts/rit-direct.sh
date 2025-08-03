#!/bin/bash

# Direct RIT - Run Integration Tests directly via JBang
# Complete bypass of Python script to avoid hanging issues

# Don't exit on command failure (let tests fail individually)
set -uo pipefail

LOGS_DIR="integration-testing/logs/background-runs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$(pwd)/${LOGS_DIR}/rit-direct_${TIMESTAMP}.log"

mkdir -p "${LOGS_DIR}"

# Create the log file first
touch "${LOG_FILE}"

echo "🚀 Starting Spring AI Examples Integration Tests (Direct Mode)"
echo "📝 Log file: ${LOG_FILE}"
echo "==============================================="

# Clean up old logs (but not the current log file)
echo "🧹 Cleaning up old logs..." | tee -a "${LOG_FILE}"
find logs/ -name "*.log" -not -name "$(basename "${LOG_FILE}")" -delete 2>/dev/null || true

# Port cleanup - kill any processes using port 8080 to prevent conflicts
echo "🔧 Cleaning up port 8080..." | tee -a "${LOG_FILE}"
if lsof -ti:8080 >/dev/null 2>&1; then
    echo "  Found processes using port 8080, terminating..." | tee -a "${LOG_FILE}"
    lsof -ti:8080 | xargs kill -9 2>/dev/null || true
    sleep 2  # Give processes time to cleanup
    echo "  Port 8080 cleanup completed" | tee -a "${LOG_FILE}"
else
    echo "  Port 8080 is free" | tee -a "${LOG_FILE}"
fi

# Find all JBang integration test scripts
jbang_scripts=($(find . -name "Run*.java" -path "*/integration-tests/*" | sort))

echo "Found ${#jbang_scripts[@]} JBang integration test scripts" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

passed=0
failed=0
failed_tests=()

for script in "${jbang_scripts[@]}"; do
    test_dir=$(dirname "${script}")
    module_dir=$(dirname "${test_dir}")
    module_name=$(basename "${module_dir}")
    parent_name=$(basename $(dirname "${module_dir}"))
    full_name="${parent_name}/${module_name}"
    
    # Create individual test log file
    individual_log="${LOGS_DIR}/test_${parent_name}_${module_name}_${TIMESTAMP}.log"
    
    echo "🔄 Testing ${full_name}..." | tee -a "${LOG_FILE}"
    echo "   Script: ${script}" | tee -a "${LOG_FILE}"
    echo "   Individual log: ${individual_log}" | tee -a "${LOG_FILE}"
    
    # Run JBang script with both main log and individual log
    if (cd "${module_dir}" && timeout 300s jbang "integration-tests/$(basename "${script}")") 2>&1 | tee "${individual_log}" >> "${LOG_FILE}"; then
        echo "✅ ${full_name} - PASSED" | tee -a "${LOG_FILE}"
        echo "   ✅ Individual log: ${individual_log}" | tee -a "${LOG_FILE}"
        ((passed++))
    else
        exit_code=$?
        if [ ${exit_code} -eq 124 ]; then
            echo "⏰ ${full_name} - TIMEOUT" | tee -a "${LOG_FILE}"
        else
            echo "❌ ${full_name} - FAILED (exit code: ${exit_code})" | tee -a "${LOG_FILE}"
        fi
        echo "   ❌ Individual log: ${individual_log}" | tee -a "${LOG_FILE}"
        ((failed++))
        failed_tests+=("${full_name}")
    fi
    
    # Clean up any hanging processes on port 8080 after each test
    if lsof -ti:8080 >/dev/null 2>&1; then
        echo "🧹 Cleaning up hanging processes on port 8080..." | tee -a "${LOG_FILE}"
        lsof -ti:8080 | xargs kill -9 2>/dev/null || true
        sleep 1
    fi
    
    echo "" | tee -a "${LOG_FILE}"
done

echo "===============================================" | tee -a "${LOG_FILE}"
echo "📊 Results:" | tee -a "${LOG_FILE}"
echo "  Total: $((passed + failed))" | tee -a "${LOG_FILE}"
echo "  Passed: ${passed}" | tee -a "${LOG_FILE}"
echo "  Failed: ${failed}" | tee -a "${LOG_FILE}"

if [ ${failed} -gt 0 ]; then
    echo "" | tee -a "${LOG_FILE}"
    echo "💥 Failed tests:" | tee -a "${LOG_FILE}"
    for test in "${failed_tests[@]}"; do
        echo "  - ${test}" | tee -a "${LOG_FILE}"
    done
fi

echo "" | tee -a "${LOG_FILE}"
echo "📝 Full log: ${LOG_FILE}"
echo "✅ Testing completed!"