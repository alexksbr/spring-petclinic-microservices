# Debezium Connector Setup

This directory contains scripts to automatically register the Debezium MySQL connector after all containers are healthy.

## Files

- `register-debezium-connector.sh` - Standalone script to register the connector
- `start-with-debezium.sh` - Wrapper script that starts docker-compose and registers the connector
- `docker-compose.override.yml` - Docker Compose override that automatically registers the connector (requires jq)
- `docker-compose.override-no-jq.yml` - Alternative override without jq dependency
- `debezium-connector-config.json` - Configuration file for the Debezium connector

## Configuration

The connector configuration is stored in `debezium-connector-config.json` and includes:

```json
{
  "name": "visits-mysql-connector",
  "config": {
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "database.hostname": "mysql",
    "database.port": "3306",
    "database.user": "debezium",
    "database.password": "dbz",
    "database.server.id": "184054",
    "database.server.name": "petclinic",
    "database.include.list": "petclinic",
    "table.include.list": "petclinic.visits",
    "topic.prefix": "petclinic",
    "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
    "schema.history.internal.kafka.topic": "schema_history"
  }
}
```

### Configuration Parameters

- **name**: Connector name (`visits-mysql-connector`)
- **database.hostname**: MySQL container name (`mysql`)
- **database.port**: MySQL port (`3306`)
- **database.user**: MySQL user for Debezium (`debezium`)
- **database.password**: MySQL password for Debezium (`dbz`)
- **database.server.id**: Unique server ID (`184054`)
- **database.server.name**: Logical server name (`petclinic`)
- **database.include.list**: Database to monitor (`petclinic`)
- **table.include.list**: Table to monitor (`petclinic.visits`)
- **topic.prefix**: Kafka topic prefix (`petclinic`)

## Usage Options

### Option 1: Using the wrapper script (Recommended)

```bash
# Start all services and automatically register the connector
./scripts/start-with-debezium.sh
```

### Option 2: Manual approach

```bash
# Start services first
docker-compose up -d

# Wait for services to be healthy, then register connector
./scripts/register-debezium-connector.sh
```

### Option 3: Using Docker Compose override (Automatic)

```bash
# The override file will automatically register the connector
docker-compose up -d
```

### Option 4: Using Docker Compose override without jq dependency

If you encounter "jq: not found" errors, use the alternative override:

```bash
# Copy the no-jq override to the main override file
cp scripts/docker-compose.override-no-jq.yml docker-compose.override.yml

# Start services
docker-compose up -d
```

## Dependencies

### For standalone scripts
- `jq` - Required for JSON parsing (install with `brew install jq` on macOS or `apt-get install jq` on Ubuntu)

### For Docker Compose override
- **Default**: Uses Alpine image with `jq` installed automatically
- **Alternative**: Uses `curlimages/curl` with `grep`/`sed` for JSON parsing (no additional dependencies)

## Verification

After the connector is registered, you can verify it's working:

```bash
# Check connector status
curl http://localhost:8091/connectors/visits-mysql-connector/status

# List all connectors
curl http://localhost:8091/connectors

# Check connector configuration
curl http://localhost:8091/connectors/visits-mysql-connector/config
```

## Troubleshooting

### "jq: not found" error
If you see this error, you have two options:

1. **Install jq locally** (for standalone scripts):
   ```bash
   # macOS
   brew install jq
   
   # Ubuntu/Debian
   sudo apt-get install jq
   ```

2. **Use the no-jq override** (for Docker Compose):
   ```bash
   cp scripts/docker-compose.override-no-jq.yml docker-compose.override.yml
   docker-compose up -d
   ```

### Connector already exists
If you see a message that the connector already exists, this is normal. The script will show the current status instead of creating a duplicate.

### Connection issues
If the connector fails to register, check:
1. All containers are healthy: `docker-compose ps`
2. Kafka Connect is accessible: `curl http://localhost:8091/connectors`
3. MySQL is accessible from the connect container
4. Configuration file exists: `ls -la scripts/debezium-connector-config.json`

### Reset connector
To remove and recreate the connector:

```bash
# Delete the connector
curl -X DELETE http://localhost:8091/connectors/visits-mysql-connector

# Re-run the registration script
./scripts/register-debezium-connector.sh
```

### Modify configuration
To change connector settings, edit `scripts/debezium-connector-config.json` and restart the services:

```bash
# Stop services
docker-compose down

# Start with new configuration
./scripts/start-with-debezium.sh
```

## Services Available

After successful setup, the following services will be available:

- **API Gateway**: http://localhost:8080
- **Admin Server**: http://localhost:9090
- **Discovery Server**: http://localhost:8761
- **Config Server**: http://localhost:8888
- **Grafana**: http://localhost:3030
- **Prometheus**: http://localhost:9091
- **Zipkin**: http://localhost:9411
- **Kafka Connect**: http://localhost:8091 