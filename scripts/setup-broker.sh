#!/bin/bash

set -e 

echo "copy broker setting"
cp kafka-config/templates/broker.properties.template kafka_2.13-4.0.0/config/broker.properties