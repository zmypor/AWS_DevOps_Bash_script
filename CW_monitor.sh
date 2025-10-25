#!/bin/bash

REGION="eu-east-1"
CSV_FILE="output.csv"
AWS_ACCESS_KEY='test'
AWS_SECRET_KEY='test'
AWS_REGION="$REGION"

export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_KEY"
export AWS_REGION="$REGION"

# Get EC2 instances
instance_ids=$(aws ec2 describe-instances --region $REGION --query 'Reservations[].Instances[].InstanceId' --output text)

# Initialize CSV file with headers
echo "Instance Name,Instance ID,Metric Name,Namespace,Path,Number of Disks,Disk Names, CPU Status, Status Check, Disk Status, RAM Status" > $CSV_FILE

# Loop through each instance
for instance_id in $instance_ids; do
    # Get instance name
     instance_name=$(aws ec2 describe-tags --region $REGION --filters "Name=resource-id,Values=$instance_id" "Name=key,Values=Name" --query "Tags[0].Value" --output text)
       # Get CloudWatch alarms for the instance
    alarms=$(aws cloudwatch describe-alarms --region $REGION --query "MetricAlarms[?Namespace=='CWAgent' && (Dimensions[?Name=='InstanceId' && Value=='$instance_id'].Value || Dimensions[?Name=='Path' && Value=='/' || Value=='/data'].Value)]")


    paths=$(echo "$alarms" | grep -oP '(?<="Path": ")[^"]+' | sed 's/\\//g')
    # Print the extracted paths
    echo "$paths"
    # Initialize variables
    metric_names=""
    disk_count=0
    disk_names=""
    path=""
    cpu_var=""
    disk_var=""
    status_var=""
    ram_var=""
    cpu_monitor=false
    disk_monitor=false
    status_monitor=false
    ram_monitor=false
    
    # Process alarms
    if [ -n "$alarms" ]; then
        metric_names=$(echo "$alarms" | jq -r '[.[].AlarmName] | join(";")')
        path=$(echo "$alarms" | jq -r '.[].Path')
    else
        metric_names="Not monitored"
    fi
    
    IFS=';' read -ra alarm_array <<< "$metric_names"
    for alarm in "${alarm_array[@]}"; do
        if [ -n "$alarm" ]; then
           echo "$alarm"
           metric=$(aws cloudwatch describe-alarms --alarm-names "$alarm" --query 'MetricAlarms[0].MetricName' --output text)
           echo "$metric"
           if [[ "$metric" == *"CPUUtilization"* ]]; then
             cpu_monitor=true
           elif [[ "$metric" == "StatusCheckFailed_Instance" ]]; then
             status_monitor=true
           elif [[ "$metric" == "disk_used_percent" ]]; then
             disk_monitor=true
           elif [[ "$metric" == "mem_used_percent" ]]; then
             ram_monitor=true

          fi
        else
                   metric_names="Not Monitored"
                   metric="Not Monitored"
       fi
    echo "$cpu_monitor"
    echo "$status_monitor"
    echo "$disk_monitor"
    echo "$ram_monitor"   
       
    done

    if [ "$cpu_monitor" == "true" ]; then
                 cpu_var="CPU Monitored"
    else
                  cpu_var="CPU not Monitored"
    fi
    echo "$cpu_var"
    if [ "$disk_monitor" = true ]; then
                 disk_var="Disk Monitored"
    else
                  disk_var="Disk not Monitored"
    fi
    echo "$disk_var"
    if [ "$status_monitor" = true ]; then
                 status_var="Status Monitored"
    else
             status_var="Status not Monitored"
    fi
    echo "$status_var"
    if [ "$ram_monitor" = true ]; then
                 ram_var="RAM Monitored"
    else
             ram_var="RAM not Monitored"
    fi
    echo "$ram_var"
    
    # Get disk count and names
    disks=$(aws ec2 describe-volumes --region $REGION --filters "Name=attachment.instance-id,Values=$instance_id" --query "Volumes[].Attachments[].Device"  --output json)
    disk_count=$(echo "$disks" | jq length)
    disk_names=$(echo "$disks" | jq -r 'join(";")')

    # Append instance details to CSV file
    echo "$instance_name,$instance_id,$metric_names,CWAgent,$paths,$disk_count,$disk_names,$cpu_var,$status_var,$disk_var,$ram_var" >> $CSV_FILE
done

echo "Output saved to $CSV_FILE"
