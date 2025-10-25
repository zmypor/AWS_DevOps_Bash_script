#!/bin/bash

CPU_THRESHOLD=80
MEM_THRESHOLD=85
DISK_THRESHOLD=90

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEM_USAGE=$(free | awk '/Mem/ {print $3/$2 * 100.0}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    aws sns publish --topic-arn arn:aws:sns:us-east-1:<your-account-id>:SystemMonitoringAlerts --message "High CPU Usage: $CPU_USAGE%"
fi

if (( $(echo "$MEM_USAGE > $MEM_THRESHOLD" | bc -l) )); then
    aws sns publish --topic-arn arn:aws:sns:us-east-1:<your-account-id>:SystemMonitoringAlerts --message "High Memory Usage: $MEM_USAGE%"
fi

if (( $(echo "$DISK_USAGE > $DISK_THRESHOLD" | bc -l) )); then
    aws sns publish --topic-arn arn:aws:sns:us-east-1:<your-account-id>:SystemMonitoringAlerts --message "High Disk Usage: $DISK_USAGE%"
fi
