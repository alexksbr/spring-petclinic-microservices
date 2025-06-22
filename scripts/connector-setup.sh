#!/bin/sh
set -e

apk add --no-cache curl jq

echo 'Waiting for Kafka Connect to be ready...'
until curl -s -f http://connect:8083/connectors > /dev/null; do
  echo 'Kafka Connect not ready yet, waiting...'
  sleep 10
done

echo 'Kafka Connect is ready!'
sleep 5

echo 'Checking if connector already exists...'
CONNECTOR_NAME=$(jq -r '.name' /config.json)
HTTP_STATUS=$(curl -s -o /dev/null -w '%{http_code}' http://connect:8083/connectors/$CONNECTOR_NAME)

if [ "$HTTP_STATUS" = "200" ]; then
  echo 'Connector already exists, checking status...'
  curl -s http://connect:8083/connectors/$CONNECTOR_NAME/status
else
  echo 'Registering Debezium connector...'
  curl -X POST http://connect:8083/connectors -H 'Content-Type: application/json' -d @/config.json
  echo 'Connector registered successfully!'
  sleep 5
  echo 'Connector status:'
  curl -s http://connect:8083/connectors/$CONNECTOR_NAME/status
fi

echo '✅ Debezium connector setup complete!' 