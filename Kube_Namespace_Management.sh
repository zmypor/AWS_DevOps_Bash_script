#!/bin/bash

NAMESPACE_NAME=$1
CPU_LIMIT="2"  # Example CPU limit
MEMORY_LIMIT="4Gi"  # Example memory limit

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: example-quota
  namespace: $NAMESPACE_NAME
spec:
  hard:
    requests.cpu: "$CPU_LIMIT"
    requests.memory: "$MEMORY_LIMIT"
    limits.cpu: "$CPU_LIMIT"
    limits.memory: "$MEMORY_LIMIT"
EOF

echo "Resource quota set for namespace '$NAMESPACE_NAME'."