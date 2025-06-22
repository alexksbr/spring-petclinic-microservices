#!/bin/bash

# Script to start the entire stack and automatically register Debezium connector
# Usage: ./scripts/start-with-debezium.sh

set -e

echo "🚀 Starting Spring PetClinic Microservices with Debezium..."

# Start all services
echo "Starting Docker Compose services..."
docker-compose up -d

echo "⏳ Waiting for services to start up..."
sleep 30

# Register Debezium connector
echo "🔧 Registering Debezium connector..."
./scripts/register-debezium-connector.sh

echo "✅ All services are up and Debezium connector is registered!"
echo ""
echo "📊 Services available at:"
echo "  - API Gateway: http://localhost:8080"
echo "  - Admin Server: http://localhost:9090"
echo "  - Discovery Server: http://localhost:8761"
echo "  - Config Server: http://localhost:8888"
echo "  - Grafana: http://localhost:3030"
echo "  - Prometheus: http://localhost:9091"
echo "  - Zipkin: http://localhost:9411"
echo "  - Kafka Connect: http://localhost:8091"
echo ""
echo "🔍 To check connector status: curl http://localhost:8091/connectors/visits-mysql-connector/status" 