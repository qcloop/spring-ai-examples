# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a collection of Spring AI examples demonstrating various AI integration patterns and use cases. The repository is organized as a multi-module Maven project with examples covering:

- **Agentic Patterns**: Chain workflows, orchestrator-workers, parallelization, routing, and evaluator-optimizer patterns
- **Model Context Protocol (MCP)**: Extensive examples for MCP clients and servers including SQLite, filesystem, weather, web search, and annotations
- **Kotlin Examples**: Hello world, function callbacks, and RAG implementations in Kotlin
- **Miscellaneous**: Function callbacks, streaming responses, and prompt engineering patterns

## Build System and Commands

This project uses Maven with the Maven Wrapper (mvnw). Each module can be built and run independently.

### Common Development Commands

**Build entire project:**
```bash
./mvnw clean package
```

**Run a specific example:**
```bash
./run-example.sh <project-directory-name>
# Example: ./run-example.sh agentic-patterns/chain-workflow
```

**Build and run individual module:**
```bash
cd <module-directory>
./mvnw clean package
./mvnw spring-boot:run
```

**Build from root (all modules):**
```bash
mvn clean package
```

## Architecture

### Module Structure
- Each example is a self-contained Spring Boot application
- Modules follow standard Maven directory structure: `src/main/java` and `src/test/java`
- Common Spring AI version: `1.1.0-SNAPSHOT`
- Java version: 17
- Spring Boot parent: `3.4.5`

### Key Module Categories

**Agentic Patterns (`agentic-patterns/`):**
- Demonstrates AI agent workflow patterns
- Each pattern is a separate module with its own Application class

**Model Context Protocol (`model-context-protocol/`):**
- MCP client and server implementations
- Covers various protocols: SQLite, filesystem access, weather APIs, web search
- Includes both manual and starter-based implementations
- Server types: WebMVC, WebFlux, and STDIO

**Kotlin Examples (`kotlin/`):**
- Kotlin-based Spring AI implementations
- Includes RAG (Retrieval-Augmented Generation) examples

### Configuration Patterns
- Application properties typically in `src/main/resources/application.properties` or `application.yaml`
- MCP configurations often use `mcp-servers-config.json`
- Docker Compose files for complex setups (e.g., `compose.yml`)

## Testing Framework

This repository uses a lightweight integration testing framework for ensuring all examples work correctly across releases.

### Testing Approaches

| Example Type | Test Location | Command | Purpose |
|--------------|---------------|---------|---------|
| **Simple** | `src/test/java/` | `./mvnw test` | Unit tests, basic functionality |
| **Complex** | `integration-tests/` | `jbang integration-tests/Run*.java` | End-to-end integration |

### Quick Testing Commands

**Run all integration tests:**
```bash
python3 integration-testing/scripts/run_integration_tests.py
```

**Create integration test for new example:**
```bash
python3 integration-testing/scripts/scaffold_integration_test.py <module-path> [--complexity simple|complex|mcp]
```

**Test specific example:**
```bash
cd <module-directory>
jbang integration-tests/Run*.java  # For complex examples
./mvnw test                         # For simple examples
```

### Integration Test Structure

Complex examples include an optional `integration-tests/` directory:
```
module/
├── integration-tests/
│   ├── ExampleInfo.json      # Test configuration (timeout, success patterns, env vars)
│   └── RunModule.java        # JBang launcher script
```

See `docs/INTEGRATION_TESTING.md` for complete testing guide.

## Development Notes

- Use the provided `run-example.sh` script for quick testing of individual examples
- Each module has its own Maven wrapper for isolated builds
- Examples demonstrate both OpenAI and other AI model integrations
- MCP examples often include database setup scripts (e.g., `create-database.sh`)
- Complex examples should include integration tests for CI/CD validation