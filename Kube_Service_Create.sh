#!/bin/bash

# Usage: create_service.sh <service-name> <namespace> <port> <target-port> <selector>

SERVICE_NAME=$1
NAMESPACE=$2
PORT=$3
TARGET_PORT=$4
SELECTOR=$5

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: $SERVICE_NAME
  namespace: $NAMESPACE
spec:
  ports:
  - port: $PORT
    targetPort: $TARGET_PORT
  selector:
    app: $SELECTOR
EOF