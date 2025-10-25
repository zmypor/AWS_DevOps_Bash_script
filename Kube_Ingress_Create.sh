#!/bin/bash

# Usage: create_ingress.sh <ingress-name> <namespace> <service-name> <service-port> <host>

INGRESS_NAME=$1
NAMESPACE=$2
SERVICE_NAME=$3
SERVICE_PORT=$4
HOST=$5

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $INGRESS_NAME
  namespace: $NAMESPACE
spec:
  rules:
  - host: $HOST
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: $SERVICE_NAME
            port:
              number: $SERVICE_PORT
EOF