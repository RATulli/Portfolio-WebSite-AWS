#!/usr/bin/env bash
set -euo pipefail

STACK_NAME="$1"
REGION="us-east-1"
SITE_DIR="${2:-./site}"   # carpeta con el contenido (por defecto ./site, o la que pases como argumento)

# Funcion para leer un Output del stack
get_output() {
  aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query "Stacks[0].Outputs[?OutputKey=='$1'].OutputValue" \
    --output text
}

# 1. Validar que la carpeta exista
if [ ! -d "$SITE_DIR" ]; then
  echo "Error: no existe la carpeta '$SITE_DIR'" >&2
  exit 1
fi

# 2. Obtener bucket y distribucion desde el stack
BUCKET=$(get_output BucketName)
DIST_ID=$(get_output DistributionId)
SITE_URL=$(get_output SiteURL)

if [ -z "$BUCKET" ] || [ "$BUCKET" = "None" ]; then
  echo "Error: no se pudo obtener el nombre del bucket. Existe el stack '$STACK_NAME'?" >&2
  exit 1
fi

echo "Bucket:        $BUCKET"
echo "Distribucion:  $DIST_ID"
echo "Contenido:     $SITE_DIR"
echo "Site Web:      $SITE_URL"

# 3. Subir contenido
aws s3 sync "$SITE_DIR" "s3://$BUCKET" --delete --region "$REGION" \
  --exclude ".git/*" 

# 4. Invalidar cache de CloudFront
aws cloudfront create-invalidation \
  --distribution-id "$DIST_ID" \
  --paths "/*" \
  --query "Invalidation.Id" \
  --output text

echo "Listo. Sitio: https://$(aws cloudfront get-distribution --id "$DIST_ID" --query 'Distribution.DomainName' --output text)"