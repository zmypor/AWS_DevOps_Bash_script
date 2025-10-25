#!/bin/bash
BUCKET_NAME="your-bucket-name"

POLICY='{
    "Version": "2025-10-01",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::'$BUCKET_NAME'/*"
        }
    ]
}'

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy "$POLICY"