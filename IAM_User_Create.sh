#!/bin/bash

echo "Creating IAM user..."
aws iam create-user --user-name newuser

echo "Attaching policy to user..."
aws iam attach-user-policy --user-name newuser --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

echo "IAM user created and policy attached successfully!"