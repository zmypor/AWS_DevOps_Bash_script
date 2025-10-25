#!/bin/bash

# Define thresholds
CPU_THRESHOLD=85
MEMORY_THRESHOLD=95

# Define namespace list
NAMESPACES=("bos" "gts" "wallet")

# Loop through namespaces
for NAMESPACE in "${NAMESPACES[@]}"; do
    # Get all Pod names in each namespace
    POD_NAMES=$(/usr/local/bin/kubectl get pod -n $NAMESPACE | awk '{print $1}' | tail -n +2)

    # Loop through Pod Names
    for POD_NAME in $POD_NAMES; do
        # Get the CPU and memory limits of each pod
        CPU_STATS=$(/usr/local/bin/kubectl top pod -n $NAMESPACE | grep $POD_NAME | awk '{print $2}' | sed 's/m$//')
        MEM_STATS=$(/usr/local/bin/kubectl top pod -n $NAMESPACE | grep $POD_NAME | awk '{print $3}' | sed 's/Mi$//')

        # Get the CPU and memory limits of each pod
        CPU_LIMITS=$(/usr/local/bin/kubectl describe pod $POD_NAME -n $NAMESPACE | grep cpu | head -n 1 | awk '{print $2}')
        MEM_LIMITS=$(/usr/local/bin/kubectl describe pod $POD_NAME -n $NAMESPACE | grep memory | head -n 1 | awk '{print $2}')

        # Process CPU limitations
        if [[ "$CPU_LIMITS" != *"m"* ]]; then
            CPU_LIMITS_END=$(echo "$CPU_LIMITS * 1024" | bc)
        else
            CPU_LIMITS_END=$(echo "$CPU_LIMITS" | sed 's/m$//')
        fi

        # Process memory limitations
        if [[ "$MEM_LIMITS" != *"Mi"* ]]; then
            MEMORY_LIMITS_SECOND=$(echo "$MEM_LIMITS" | sed 's/Gi$//')
            MEMORY_LIMITS_END=$(echo "$MEMORY_LIMITS_SECOND * 1024" | bc)
        else
            MEMORY_LIMITS_END=$(echo "$MEM_LIMITS" | sed 's/Mi$//')
        fi

        # Calculate CPU and memory usage
        CPU_PERCENTAGE=$(echo "scale=2; $CPU_STATS / $CPU_LIMITS_END * 100" | bc -l)
        MEMORY_PERCENTAGE=$(echo "scale=2; $MEM_STATS / $MEMORY_LIMITS_END * 100" | bc -l)

        # Check if the CPU usage exceeds the threshold
        if (($(echo "$CPU_PERCENTAGE > $CPU_THRESHOLD" | bc -l))); then
            echo -e "\e[31mPOD_NAME: $POD_NAME CPU_LIMITS: $CPU_LIMITS $CPU_PERCENTAGE MEM_LIMITS: $MEM_LIMITS $MEMORY_PERCENTAGE\e[0m"
            # Send alarm notifications to Lark Webhook robot
            curl -X POST -H "Content-Type: application/json" -d '{"msg_type":"text","content":{"text":"Alarm：'"$POD_NAME"' Resource usage is too high! CPU usage：'"$CPU_PERCENTAGE"'%"}}' https://open.larksuite.com/open-apis/bot/v2/hook/xxxxxxxx
        else
            # Print the values of CPU_LMITS and MEM_LMITS
            echo POD_NAME: $POD_NAME "CPU_LIMITS: $CPU_LIMITS" $CPU_PERCENTAGE "MEM_LIMITS: $MEM_LIMITS" $MEMORY_PERCENTAGE
        fi

        # Check if the memory usage exceeds the threshold
        if (($(echo "$MEMORY_PERCENTAGE > $MEMORY_THRESHOLD" | bc -l))); then
            echo -e "\e[31mPOD_NAME: $POD_NAME CPU_LIMITS: $CPU_LIMITS $CPU_PERCENTAGE MEM_LIMITS: $MEM_LIMITS $MEMORY_PERCENTAGE\e[0m"
            # Send alarm notifications to Lark Webhook robot
            curl -X POST -H "Content-Type: application/json" -d '{"msg_type":"text","content":{"text":"Alarm：'"$POD_NAME"' Resource usage is too high! memory usage：'"$MEMORY_PERCENTAGE"'%"}}' https://open.larksuite.com/open-apis/bot/v2/hook/xxxxxxxx
        else
            # Print the values of CPU_LMITS and MEM_LMITS
            echo POD_NAME: $POD_NAME "CPU_LIMITS: $CPU_LIMITS" $CPU_PERCENTAGE "MEM_LIMITS: $MEM_LIMITS_FIRST" $MEMORY_PERCENTAGE
        fi
    done
done
