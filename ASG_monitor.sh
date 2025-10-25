#!/bin/bash

# Define variables
ASG_NAME="my-auto-scaling-group"

# Get average CPU utilization
AVERAGE_CPU=$(aws cloudwatch get-metric-statistics --metric-name CPUUtilization --start-time $(date --date='-5 minutes' +%Y-%m-%dT%H:%M:%SZ) --end-time $(date +%Y-%m-%dT%H:%M:%SZ) --period 300 --namespace AWS/EC2 --statistics Average --dimensions Name=AutoScalingGroupName,Value=$ASG_NAME --query 'Datapoints[0].Average' --output text)

# Define CPU thresholds
CPU_SCALE_UP_THRESHOLD=70
CPU_SCALE_DOWN_THRESHOLD=20

# Decision making on when to scale
if [[ $(echo "$AVERAGE_CPU > $CPU_SCALE_UP_THRESHOLD" | bc) -eq 1 ]]
then
    echo "Scaling up..."
    aws autoscaling set-desired-capacity --auto-scaling-group-name $ASG_NAME --desired-capacity $(($(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $ASG_NAME --query 'AutoScalingGroups[0].DesiredCapacity') + 1))
elif [[ $(echo "$AVERAGE_CPU < $CPU_SCALE_DOWN_THRESHOLD" | bc) -eq 1 ]]
then
    echo "Scaling down..."
    aws autoscaling set-desired-capacity --auto-scaling-group-name $ASG_NAME --desired-capacity $(($(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $ASG_NAME --query 'AutoScalingGroups[0].DesiredCapacity') - 1))
fi