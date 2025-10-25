#!/bin/bash

# Define trust policy
trust_policy='{
  "Version": "2025-10-01",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}'

echo "Creating IAM role..."
aws iam create-role --role-name myIAMRole --assume-role-policy-document "$trust_policy"

echo "Attaching policy to role..."
aws iam attach-role-policy --role-name myIAMRole --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess

echo "IAM role created and policy attached successfully!"