#!/bin/bash

set -e 

# --- Configuration ---
CERTS_DIR="./certs"
PASSWORD="meinPasswort" 
HOSTNAME="ws-server-${WORKSPACE_ID}-kafka-broker.workspaces"
KEYSTORE_FILE="${CERTS_DIR}/kafka.server.keystore.jks"
TRUSTSTORE_FILE="${CERTS_DIR}/kafka.client.truststore.jks"

echo "download kafka"
[ -f ./kafka_2.13-4.0.0.tgz ] || wget https://dlcdn.apache.org/kafka/4.0.0/kafka_2.13-4.0.0.tgz

echo "unzip tar archive"
[ -d ./kafka_2.13-4.0.0 ] || tar -xzf kafka_2.13-4.0.0.tgz -C ./

mkdir -p "$CERTS_DIR"
if [ -f "$KEYSTORE_FILE" ]; then
    echo "Keystore '$KEYSTORE_FILE' existiert bereits. Überspringe Zertifikatserstellung."
    exit 0
fi

echo "Starte den Prozess zur Zertifikatserstellung..."

CA_KEY="${CERTS_DIR}/ca-key"
CA_CERT="${CERTS_DIR}/ca-cert"
CSR_FILE="${CERTS_DIR}/cert-file"
SIGNED_CERT_FILE="${CERTS_DIR}/cert-signed"

echo "--> Create Certificate Authority (CA)..."
openssl req -new -newkey rsa:4096 -days 3650 -x509 \
  -subj "/CN=Kafka-Self-Signed-CA" \
  -keyout "$CA_KEY" -out "$CA_CERT" -nodes

echo "--> Erstelle Server-Keystore und Certificate Signing Request (CSR)..."
keytool -genkeypair -keystore "$KEYSTORE_FILE" -alias localhost -keyalg RSA -keysize 4096 -validity 3650 \
  -dname "CN=${HOSTNAME}" \
  -storepass "$PASSWORD" -keypass "$PASSWORD"

keytool -keystore "$KEYSTORE_FILE" -alias localhost -certreq -file "$CSR_FILE" -storepass "$PASSWORD"

echo "--> Signiere Server-Zertifikat mit CA..."
openssl x509 -req -CA "$CA_CERT" -CAkey "$CA_KEY" -in "$CSR_FILE" -out "$SIGNED_CERT_FILE" -days 3650 -CAcreateserial

echo "--> Importiere CA-Zertifikat und signiertes Server-Zertifikat in den Keystore..."
keytool -keystore "$KEYSTORE_FILE" -alias CARoot -import -file "$CA_CERT" -storepass "$PASSWORD" -noprompt
keytool -keystore "$KEYSTORE_FILE" -alias localhost -import -file "$SIGNED_CERT_FILE" -storepass "$PASSWORD"

echo "--> Erstelle Client-Truststore..."
keytool -keystore "$TRUSTSTORE_FILE" -alias CARoot -import -file "$CA_CERT" -storepass "$PASSWORD" -noprompt

echo "--> Räume temporäre Dateien auf..."
rm -f "$CSR_FILE" "$SIGNED_CERT_FILE" "${CERTS_DIR}/ca-key.srl"

echo "Zertifikatserstellung erfolgreich abgeschlossen!"