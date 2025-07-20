# Spring AI MCP Annotations Server Sample

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Java Version](https://img.shields.io/badge/Java-17%2B-orange)](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)

This sample project demonstrates how to create an MCP server using Spring AI's MCP annotations. It showcases a comprehensive implementation of MCP server capabilities including tools, resources, prompts, and completions using a clean, declarative approach with Java annotations.

For more information, see the [MCP Server Boot Starter](https://docs.spring.io/spring-ai/reference/api/mcp/mcp-server-boot-starter-docs.html) reference documentation.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Dependencies](#dependencies)
- [Building the Project](#building-the-project)
- [Running the Server](#running-the-server)
- [Configuration](#configuration)
- [Server Implementation](#server-implementation)
- [MCP Capabilities](#mcp-capabilities)
  - [Tools](#tools)
  - [Resources](#resources)
  - [Prompts](#prompts)
  - [Completions](#completions)
- [MCP Clients](#mcp-clients)
  - [Manual Clients](#manual-clients)
  - [Boot Starter Clients](#boot-starter-clients)
- [Additional Resources](#additional-resources)

## Overview

The sample showcases a comprehensive MCP server implementation with:
- Integration with `spring-ai-mcp-server-webmvc-spring-boot-starter`
- Support for both SSE (Server-Sent Events) and STDIO transports
- Automatic registration of MCP capabilities using annotations:
  - `@Tool` for tool registration
  - `@McpResource` for resource registration
  - `@McpPrompt` for prompt registration
  - `@McpComplete` for completion registration
- Comprehensive examples of each capability type

## Features

This sample demonstrates:

1. **Weather Tools** - Tools for retrieving weather forecasts and alerts
2. **User Profile Resources** - Resources for accessing user profile information
3. **Prompt Generation** - Various prompt templates for different use cases
4. **Auto-completion** - Completion suggestions for usernames and countries

## Dependencies

The project requires the Spring AI MCP Server WebMVC Boot Starter and MCP Annotations:

```xml
<dependency>
    <groupId>org.springframework.ai</groupId>
    <artifactId>spring-ai-mcp-server-webmvc-spring-boot-starter</artifactId>
</dependency>
<dependency>
    <groupId>com.logaritex.mcp</groupId>
    <artifactId>spring-ai-mcp-annotations</artifactId>
</dependency>
```

These dependencies provide:
- HTTP-based transport using Spring MVC (`WebMvcSseServerTransport`)
- Auto-configured SSE endpoints
- Optional STDIO transport
- Annotation-based method handling for MCP operations

## Building the Project

Build the project using Maven:
```bash
./mvnw clean install -DskipTests
```

## Running the Server

The server supports two transport modes:

### WebMVC SSE Mode (Default)
```bash
java -jar target/mcp-annotations-server-0.0.1-SNAPSHOT.jar
```

### STDIO Mode
To enable STDIO transport, set the appropriate properties:
```bash
java -Dspring.ai.mcp.server.stdio=true -Dspring.main.web-application-type=none -jar target/mcp-annotations-server-0.0.1-SNAPSHOT.jar
```

## Configuration

Configure the server through `application.properties`:

```properties
# Server identification
spring.ai.mcp.server.name=my-weather-server
spring.ai.mcp.server.version=0.0.1

# Transport configuration
spring.ai.mcp.server.stdio=false
spring.ai.mcp.server.sse-message-endpoint=/mcp/message

# Logging (required for STDIO transport)
spring.main.banner-mode=off
logging.file.name=./target/mcp-annotations-server.log
```

## Server Implementation

The server uses Spring Boot and MCP annotations for automatic registration of capabilities:

```java
@SpringBootApplication
public class McpServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(McpServerApplication.class, args);
    }

    @Bean
    public ToolCallbackProvider weatherTools(WeatherService weatherService) {
        return MethodToolCallbackProvider.builder().toolObjects(weatherService).build();
    }

    @Bean
    public List<SyncResourceSpecification> resourceSpecs(UserProfileResourceProvider userProfileResourceProvider) {
        return SpringAiMcpAnnotationProvider.createSyncResourceSpecifications(List.of(userProfileResourceProvider));
    }

    @Bean
    public List<SyncPromptSpecification> promptSpecs(PromptProvider promptProvider) {
        return SpringAiMcpAnnotationProvider.createSyncPromptSpecifications(List.of(promptProvider));
    }

    @Bean
    public List<SyncCompletionSpecification> completionSpecs(AutocompleteProvider autocompleteProvider) {
        return SpringAiMcpAnnotationProvider.createSyncCompleteSpecifications(List.of(autocompleteProvider));
    }
}
```

## MCP Capabilities

### Tools

The `WeatherService` implements weather-related tools using the `@Tool` annotation:

```java
@Service
public class WeatherService {
    @Tool(description = "Get weather forecast for a specific latitude/longitude")
    public String getWeatherForecastByLocation(double latitude, double longitude) {
        // Implementation using weather.gov API
    }

    @Tool(description = "Get weather alerts for a US state. Input is Two-letter US state code (e.g., CA, NY)")
    public String getAlerts(String state) {
        // Implementation using weather.gov API
    }
}
```

#### Available Tools

1. **Weather Forecast Tool**
   - Name: `getWeatherForecastByLocation`
   - Description: Get weather forecast for a specific latitude/longitude
   - Parameters:
     - `latitude`: double - Latitude coordinate
     - `longitude`: double - Longitude coordinate

2. **Weather Alerts Tool**
   - Name: `getAlerts`
   - Description: Get weather alerts for a US state
   - Parameters:
     - `state`: String - Two-letter US state code (e.g., CA, NY)

### Resources

The `UserProfileResourceProvider` implements resource access using the `@McpResource` annotation:

```java
@Service
public class UserProfileResourceProvider {
    @McpResource(uri = "user-profile://{username}", 
                name = "User Profile", 
                description = "Provides user profile information for a specific user")
    public ReadResourceResult getUserProfile(ReadResourceRequest request, String username) {
        // Implementation to retrieve user profile
    }
    
    // Additional resource methods...
}
```

#### Available Resources

1. **User Profile**
   - URI: `user-profile://{username}`
   - Description: Provides user profile information for a specific user

2. **User Details**
   - URI: `user-profile://{username}`
   - Description: Provides user details using URI variables

3. **User Attribute**
   - URI: `user-attribute://{username}/{attribute}`
   - Description: Provides a specific attribute from a user's profile

4. **User Profile with Exchange**
   - URI: `user-profile-exchange://{username}`
   - Description: Provides user profile with server exchange context

5. **User Connections**
   - URI: `user-connections://{username}`
   - Description: Provides a list of connections for a user

6. **User Notifications**
   - URI: `user-notifications://{username}`
   - Description: Provides notifications for a user

7. **User Status**
   - URI: `user-status://{username}`
   - Description: Provides the current status for a user

8. **User Location**
   - URI: `user-location://{username}`
   - Description: Provides the current location for a user

9. **User Avatar**
   - URI: `user-avatar://{username}`
   - Description: Provides a base64-encoded avatar image for a user

### Prompts

The `PromptProvider` implements prompt generation using the `@McpPrompt` annotation:

```java
@Service
public class PromptProvider {
    @McpPrompt(name = "greeting", description = "A simple greeting prompt")
    public GetPromptResult greetingPrompt(
            @McpArg(name = "name", description = "The name to greet", required = true) String name) {
        // Implementation to generate greeting prompt
    }
    
    // Additional prompt methods...
}
```

#### Available Prompts

1. **Greeting**
   - Name: `greeting`
   - Description: A simple greeting prompt
   - Parameters:
     - `name`: String - The name to greet

2. **Personalized Message**
   - Name: `personalized-message`
   - Description: Generates a personalized message based on user information
   - Parameters:
     - `name`: String - The user's name (required)
     - `age`: Integer - The user's age (optional)
     - `interests`: String - The user's interests (optional)

3. **Conversation Starter**
   - Name: `conversation-starter`
   - Description: Provides a conversation starter with the system

4. **Map Arguments**
   - Name: `map-arguments`
   - Description: Demonstrates using a map for arguments

5. **Single Message**
   - Name: `single-message`
   - Description: Demonstrates returning a single PromptMessage
   - Parameters:
     - `name`: String - The user's name (required)

6. **String List**
   - Name: `string-list`
   - Description: Demonstrates returning a list of strings
   - Parameters:
     - `topic`: String - The topic to provide information about (required)

### Completions

The `AutocompleteProvider` implements auto-completion using the `@McpComplete` annotation:

```java
@Service
public class AutocompleteProvider {
    @McpComplete(uri = "user-status://{username}")
    public List<String> completeUsername(String usernamePrefix) {
        // Implementation to provide username completions
    }
    
    // Additional completion methods...
}
```

#### Available Completions

1. **Username Completion**
   - URI: `user-status://{username}`
   - Provides completion suggestions for usernames

2. **Name Completion**
   - Prompt: `personalized-message`
   - Provides completion suggestions for names

3. **Country Name Completion**
   - Prompt: `travel-planner`
   - Provides completion suggestions for country names

## MCP Clients 

You can connect to the server using either STDIO or SSE transport:

### Manual Clients

#### WebMVC SSE Client

For servers using SSE transport:

```java
var transport = HttpClientSseClientTransport.builder("http://localhost:8080").build();
var client = McpClient.sync(transport).build();
```

#### STDIO Client

For servers using STDIO transport:

```java
var stdioParams = ServerParameters.builder("java")
    .args("-Dspring.ai.mcp.server.stdio=true",
          "-Dspring.main.web-application-type=none",
          "-Dspring.main.banner-mode=off",
          "-Dlogging.pattern.console=",
          "-jar",
          "target/mcp-annotations-server-0.0.1-SNAPSHOT.jar")
    .build();

var transport = new StdioClientTransport(stdioParams);
var client = McpClient.sync(transport).build();
```

The sample project includes example client implementations:
- [SampleClient.java](src/test/java/org/springframework/ai/mcp/sample/client/SampleClient.java): Manual MCP client implementation
- [ClientStdio.java](src/test/java/org/springframework/ai/mcp/sample/client/ClientStdio.java): STDIO transport connection
- [ClientSse.java](src/test/java/org/springframework/ai/mcp/sample/client/ClientSse.java): SSE transport connection

### Boot Starter Clients

For a better development experience, consider using the [MCP Client Boot Starters](https://docs.spring.io/spring-ai/reference/api/mcp/mcp-client-boot-starter-docs.html). These starters enable auto-configuration of multiple STDIO and/or SSE connections to MCP servers.

#### STDIO Transport

1. Create a `mcp-servers-config.json` configuration file:

```json
{
  "mcpServers": {
    "annotations-server": {
      "command": "java",
      "args": [
        "-Dspring.ai.mcp.server.stdio=true",
        "-Dspring.main.web-application-type=none",
        "-Dlogging.pattern.console=",
        "-jar",
        "/absolute/path/to/mcp-annotations-server-0.0.1-SNAPSHOT.jar"
      ]
    }
  }
}
```

2. Run the client using the configuration file:

```bash
java -Dspring.ai.mcp.client.stdio.servers-configuration=file:mcp-servers-config.json \
 -Dai.user.input='What is the weather in NY?' \
 -Dlogging.pattern.console= \
 -jar mcp-starter-default-client-0.0.1-SNAPSHOT.jar
```

#### SSE (WebMVC) Transport

1. Start the MCP annotations server:

```bash
java -jar mcp-annotations-server-0.0.1-SNAPSHOT.jar
```

2. In another console, start the client configured with SSE transport:

```bash
java -Dspring.ai.mcp.client.sse.connections.annotations-server.url=http://localhost:8080 \
 -Dlogging.pattern.console= \
 -Dai.user.input='What is the weather in NY?' \
 -jar mcp-starter-default-client-0.0.1-SNAPSHOT.jar
```

## Additional Resources

* [Spring AI Documentation](https://docs.spring.io/spring-ai/reference/)
* [MCP Server Boot Starter](https://docs.spring.io/spring-ai/reference/api/mcp/mcp-server-boot-starter-docs.html)
* [MCP Client Boot Starter](https://docs.spring.io/spring-ai/reference/api/mcp/mcp-client-boot-starter-docs.html)
* [Model Context Protocol Specification](https://modelcontextprotocol.github.io/specification/)
* [MCP Annotations Project](https://github.com/spring-ai-community/mcp-annotations)
* [Spring Boot Auto-configuration](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.developing-auto-configuration)
