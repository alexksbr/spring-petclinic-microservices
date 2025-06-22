#!/bin/bash

# Script to register Debezium connector after all containers are healthy
# This script should be run after docker-compose up

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/debezium-connector-config.json"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "✗ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

echo "Waiting for all containers to be healthy..."

# Function to check if a container is healthy
check_container_health() {
    local container_name=$1
    local max_attempts=60
    local attempt=1
    
    echo "Waiting for $container_name to be healthy..."
    
    while [ $attempt -le $max_attempts ]; do
        if docker ps --filter "name=$container_name" --filter "health=healthy" --format "table {{.Names}}\t{{.Status}}" | grep -q "$container_name"; then
            echo "✓ $container_name is healthy"
            return 0
        fi
        
        echo "Attempt $attempt/$max_attempts: $container_name is not healthy yet..."
        sleep 10
        ((attempt++))
    done
    
    echo "✗ $container_name failed to become healthy after $max_attempts attempts"
    return 1
}

# Wait for critical containers to be healthy
check_container_health "mysql"
check_container_health "config-server"
check_container_health "discovery-server"
check_container_health "connect"

# Additional wait for Kafka Connect to be fully ready
echo "Waiting for Kafka Connect REST API to be available..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -s -f http://localhost:8091/connectors > /dev/null 2>&1; then
        echo "✓ Kafka Connect REST API is available"
        break
    fi
    
    echo "Attempt $attempt/$max_attempts: Kafka Connect REST API not ready yet..."
    sleep 5
    ((attempt++))
    
    if [ $attempt -gt $max_attempts ]; then
        echo "✗ Kafka Connect REST API failed to become available"
        exit 1
    fi
done

# Get connector name from config file
CONNECTOR_NAME=$(jq -r '.name' "$CONFIG_FILE")

# Check if connector already exists
echo "Checking if Debezium connector already exists..."
if curl -s -f "http://localhost:8091/connectors/$CONNECTOR_NAME" > /dev/null 2>&1; then
    echo "✓ Debezium connector '$CONNECTOR_NAME' already exists"
    echo "Current connector status:"
    curl -s "http://localhost:8091/connectors/$CONNECTOR_NAME/status" | jq .
    exit 0
fi

# Register the Debezium connector
echo "Registering Debezium connector..."

response=$(curl -s -w "%{http_code}" -X POST http://localhost:8091/connectors \
  -H "Content-Type: application/json" \
  -d @"$CONFIG_FILE")

http_code="${response: -3}"
response_body="${response%???}"

if [ "$http_code" -eq 201 ] || [ "$http_code" -eq 409 ]; then
    echo "✓ Debezium connector registered successfully"
    echo "Connector details:"
    echo "$response_body" | jq .
    
    # Wait a moment and check connector status
    sleep 5
    echo "Connector status:"
    curl -s "http://localhost:8091/connectors/$CONNECTOR_NAME/status" | jq .
else
    echo "✗ Failed to register Debezium connector"
    echo "HTTP Status: $http_code"
    echo "Response: $response_body"
    exit 1
fi

echo "✅ Debezium connector setup complete!" 