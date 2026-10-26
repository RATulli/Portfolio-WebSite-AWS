#!/usr/bin/env bash
set -euo pipefail

STACK_NAME="$1"
REGION="us-east-1"

# 1. Obtener el nombre del bucket desde los Outputs
BUCKET=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" \
  --output text)

# 2. Vaciar el bucket
aws s3 rm "s3://$BUCKET" --recursive