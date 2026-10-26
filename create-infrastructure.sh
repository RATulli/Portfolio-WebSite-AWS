#!/usr/bin/env bash
set -euo pipefail

echo ">>> Creando Infrastructura..."
 
./create-stack.sh mi-portfolio-web front-end-infrastructure.yml parameters.json

echo ">>> Esperando a que el stack termine (CloudFront puede tardar 5-10 min)..."

aws cloudformation wait stack-create-complete \
  --stack-name "mi-portfolio-web" \
  --region "us-east-1"

echo ">>> Subiendo contenido..."

./upload-site.sh mi-portfolio-web 

