#!/bin/bash

# Run Integration Tests (rit.sh)
# Simplified script to run integration tests in background with full output capture

set -euo pipefail

# Configuration
LOGS_DIR="logs/background-runs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${LOGS_DIR}/rit_${TIMESTAMP}.log"
PID_FILE="${LOGS_DIR}/rit_${TIMESTAMP}.pid"

# Create logs subdirectory if it doesn't exist
mkdir -p "${LOGS_DIR}"

# Function to cleanup on exit
cleanup() {
    if [[ -f "${PID_FILE}" ]]; then
        rm -f "${PID_FILE}"
    fi
}
trap cleanup EXIT

# Show usage if help requested
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $0 [--foreground]"
    echo ""
    echo "Runs integration tests with full output capture:"
    echo "  Default: Runs in background, shows progress with tail -f"
    echo "  --foreground: Runs in foreground with live output"
    echo ""
    echo "Output files:"
    echo "  Log: ${LOG_FILE}"
    echo "  PID: ${PID_FILE} (background mode only)"
    echo ""
    echo "Background mode commands:"
    echo "  Follow output:  tail -f ${LOG_FILE}"
    echo "  Stop process:   kill \$(cat ${PID_FILE})"
    echo "  Check status:   ps -p \$(cat ${PID_FILE}) > /dev/null && echo 'Running' || echo 'Stopped'"
    exit 0
fi

echo "🚀 Starting Spring AI Examples Integration Tests"
echo "📝 Log file: ${LOG_FILE}"

if [[ "${1:-}" == "--foreground" ]]; then
    echo "🖥️  Running in foreground mode..."
    echo "==============================================="
    
    # Clean logs first, then run tests with live output and log capture
    echo "🧹 Cleaning up old logs..."
    python3 scripts/run_integration_tests.py --clean-logs
    echo "🚀 Starting integration tests..."
    # Run without --verbose or --stream flags (both cause hanging issues)
    python3 scripts/run_integration_tests.py 2>&1 | tee "${LOG_FILE}"
    
    echo ""
    echo "✅ Integration tests completed!"
    echo "📝 Full output saved to: ${LOG_FILE}"
    
else
    echo "🔄 Running in background mode..."
    echo "💾 PID file: ${PID_FILE}"
    echo ""
    
    # Clean logs first
    echo "🧹 Cleaning up old logs..."
    python3 scripts/run_integration_tests.py --clean-logs
    
    echo "🚀 Starting integration tests with live output..."
    echo "💾 Output will be saved to: ${LOG_FILE}"
    echo "==============================================="
    
    # Run without --verbose or --stream flags (both cause hanging issues)
    # TODO: Fix streaming mode hang issue and verbose output overflow - see Phase 3a priorities
    python3 scripts/run_integration_tests.py 2>&1 | tee "${LOG_FILE}"
    
    echo ""
    echo "✅ Integration tests completed!"
fi

echo ""
echo "📁 Background run logs directory: ${LOGS_DIR}"
echo "📝 This run's log: ${LOG_FILE}"