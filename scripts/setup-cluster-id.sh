#!/bin/bash

set -e 

VAR_NAME="KAFKA_CLUSTER_ID"
API_URL="https://codesphere.com/api/workspaces/${WORKSPACE_ID}/env-vars"

if [ -z "${WORKSPACE_ID-}" ] || [ -z "${CS_TOKEN-}" ]; then
  echo "error: WORKSPACE_ID or/and CS_TOKEN not set."
  exit 1
fi

EXISTING_VAR_JSON=$(curl -s -H "Authorization: Bearer $CS_TOKEN" "$API_URL" | jq --arg var_name "$VAR_NAME" '.[] | select(.name == $var_name)')

if [ -z "$EXISTING_VAR_JSON" ]; then
    echo "Create cluster id..."
    UUID=$(cd kafka_2.13-4.0.0 && bin/kafka-storage.sh random-uuid)
    cs set-env --env-var "$VAR_NAME=$UUID"
else
    echo "cluster id already exists"
fi