#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

# Fetch DB credentials from SSM Parameter Store
readarray -t PARAMS < <(aws ssm get-parameters \
  --region "$REGION" \
  --names \
    "/ecs/fastapi-demo/RDS_HOSTNAME" \
    "/ecs/fastapi-demo/RDS_DB_NAME" \
    "/ecs/fastapi-demo/RDS_USERNAME" \
    "/ecs/fastapi-demo/RDS_PASSWORD" \
    "/ecs/fastapi-demo/RDS_PORT" \
  --with-decryption \
  --query 'Parameters[*].{Name:Name,Value:Value}' \
  --output text)

# Convert to uppercase env vars prefixed with RDS_
for param in "${PARAMS[@]}"; do
  name=$(echo "$param" | awk '{print $1}' | sed 's:.*/::' | tr 'a-z' 'A-Z')
  value=$(echo "$param" | awk '{print $2}')
  export "RDS_${name}=${value}"
done


for key in HOSTNAME DB_NAME USERNAME PASSWORD PORT; do
  var="RDS_${key}"
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required environment variable: $var"
    exit 1
  fi
done

aws logs create-log-group \
  --region "${REGION}" \
  --log-group-name "${LOG_GROUP}" \
  2>/dev/null || true

# Run Alembic migrations inside temporary container
docker run --rm \
  -e RDS_HOSTNAME="$RDS_HOSTNAME" \
  -e RDS_DB_NAME="$RDS_DB_NAME" \
  -e RDS_USERNAME="$RDS_USERNAME" \
  -e RDS_PASSWORD="$RDS_PASSWORD" \
  -e RDS_PORT="$RDS_PORT" \
  "${IMAGE}" alembic upgrade head

docker run -d --name "${CONTAINER_NAME}" --restart unless-stopped \
  -p "${HOST_PORT}:${CONTAINER_PORT}" \
  --log-driver awslogs \
  --log-opt awslogs-region="${REGION}" \
  --log-opt awslogs-group="${LOG_GROUP}" \
  --log-opt awslogs-stream="${CONTAINER_NAME}" \
  -e RDS_HOSTNAME="$RDS_HOSTNAME" \
  -e RDS_DB_NAME="$RDS_DB_NAME" \
  -e RDS_USERNAME="$RDS_USERNAME" \
  -e RDS_PASSWORD="$RDS_PASSWORD" \
  -e RDS_PORT="$RDS_PORT" \
  "${IMAGE}"