#!/bin/bash

set -e 

echo "copy controller setting"
cp kafka-config/templates/controller.properties.template kafka_2.13-4.0.0/config/controller.properties

echo "Kafka-Speicher initialisieren (falls nötig)..."

LOG_DIR="/home/user/app/.codesphere-internal/kafka-logs-controller"
mkdir -p "$LOG_DIR"

if [ ! -f "$LOG_DIR/meta.properties" ]; then
    echo "Formatiere neuen Kafka-Speicher..."
    (
        cd kafka_2.13-4.0.0 && \
        bin/kafka-storage.sh format -t "$UUID" -c config/controller.properties --standalone
    )
    echo "Formatierung abgeschlossen."
else
    echo "Kafka-Speicher bereits vorhanden. Überspringe Formatierung."
fi