#!/bin/bash

# Enable strict mode
set -euo pipefail

# Check if Kafka metadata is initialized
if [ ! -f "/var/lib/kafka/data/meta.properties" ]; then
    echo "Initializing Kafka metadata..."
    /opt/kafka/bin/kafka-storage.sh format -t "${KAFKA_NODE_ID}" -c /opt/kafka/config/kraft/server.properties
fi

# Start Kafka
/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties &

# Wait for Kafka to be ready
timeout 60s bash -c '
until /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list &>/dev/null; do
  echo "Waiting for Kafka to be ready..."
  sleep 5
done'

# Debug: Print the admin password (remove in production)
echo "Admin password: ${KAFKA_ADMIN_PASSWORD}"

# Create SCRAM credentials
/opt/kafka/bin/kafka-configs.sh --bootstrap-server localhost:9092 --alter --add-config "SCRAM-SHA-256=[password=${KAFKA_ADMIN_PASSWORD}]" --entity-type users --entity-name admin

echo "SCRAM credentials created for admin user"

# Keep the script running to prevent the container from stopping
tail -f /dev/null