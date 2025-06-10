#!/bin/bash

HEALTH_CHECK_URL="http://ws-server-$WORKSPACE_ID-kafka-controller.workspaces:3000"
KAFKA_DIR="kafka_2.13-4.0.0"
CONFIG_FILE="config/broker.properties"

while true; do
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -k "$HEALTH_CHECK_URL")
    if [[ "$STATUS_CODE" -ge 200 && "$STATUS_CODE" -le 299 ]]; then
        echo "Controller ready! (Status: $STATUS_CODE). start broker..."
        break 
    else
        echo "controller not ready yet (status: $STATUS_CODE)"
        sleep 1 
    fi
done

"$KAFKA_DIR/bin/kafka-server-start.sh" "$KAFKA_DIR/$CONFIG_FILE"