#!/usr/bin/env bash
set -euo pipefail
REGION="us-east-1"
source "$(dirname "$0")/common.sh"

SSM_PREFIX="/ecs/fastapi-demo"
declare -r LOG_DRIVER="awslogs"
declare -a PARAM_KEYS=("RDS_HOSTNAME" "RDS_DB_NAME" "RDS_USERNAME" "RDS_PASSWORD" "RDS_PORT")

declare -A PARAM_MAP

while read -r name value; do
  key="$(basename "$name")"
  PARAM_MAP["$key"]="$value"
done < <(aws ssm get-parameters \
  --region "$REGION" \
  --names $(printf "%s/%s " "$SSM_PREFIX" "${PARAM_KEYS[@]}") \
  --with-decryption \
  --query 'Parameters[*].[Name,Value]' \
  --output text)

for key in "${PARAM_KEYS[@]}"; do
  val="${PARAM_MAP[$key]:-}"
  if [[ -z "$val" ]]; then
    echo "Missing required environment variable: $key"
    exit 1
  fi
  export "$key=$val"
done

aws logs create-log-group \
  --region "$REGION" \
  --log-group-name "$LOG_GROUP" \
  2>/dev/null || true

docker run --rm \
  -e RDS_HOSTNAME="$RDS_HOSTNAME" \
  -e RDS_DB_NAME="$RDS_DB_NAME" \
  -e RDS_USERNAME="$RDS_USERNAME" \
  -e RDS_PASSWORD="$RDS_PASSWORD" \
  -e RDS_PORT="$RDS_PORT" \
  "$IMAGE" alembic upgrade head

docker run -d --name "$CONTAINER_NAME" --restart unless-stopped \
  -p "$HOST_PORT:$CONTAINER_PORT" \
  --log-driver "$LOG_DRIVER" \
  --log-opt awslogs-region="$REGION" \
  --log-opt awslogs-group="$LOG_GROUP" \
  --log-opt awslogs-stream="$CONTAINER_NAME" \
  -e RDS_HOSTNAME="$RDS_HOSTNAME" \
  -e RDS_DB_NAME="$RDS_DB_NAME" \
  -e RDS_USERNAME="$RDS_USERNAME" \
  -e RDS_PASSWORD="$RDS_PASSWORD" \
  -e RDS_PORT="$RDS_PORT" \
  "$IMAGE"
