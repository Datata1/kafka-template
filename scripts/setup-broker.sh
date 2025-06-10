#!/bin/bash

set -e 

echo "copy broker setting"
cp kafka-config/templates/broker.properties.template kafka_2.13-4.0.0/config/broker.properties

LOG_DIR="/home/user/app/.codesphere-internal/kafka-logs-broker"
mkdir -p "$LOG_DIR"

if [ ! -f "$LOG_DIR/meta.properties" ]; then
    echo "Formatiere neuen Kafka-Speicher..."
    (
        cd kafka_2.13-4.0.0 && \
        bin/kafka-storage.sh format -t "$KAFKA_CLUSTER_ID" -c config/broker.properties --no-initial-controllers
    )
    echo "Formatierung abgeschlossen."
else
    echo "Kafka-Speicher bereits vorhanden. Überspringe Formatierung."
fi
