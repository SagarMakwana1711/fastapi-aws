#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

SSM_PREFIX="/ecs/fastapi-demo"
LOG_DRIVER="awslogs"
PARAM_KEYS=("RDS_HOSTNAME" "RDS_DB_NAME" "RDS_USERNAME" "RDS_PASSWORD" "RDS_PORT")

get_param() {
  aws ssm get-parameter \
    --region "$REGION" \
    --name "$SSM_PREFIX/$1" \
    --with-decryption \
    --query 'Parameter.Value' \
    --output text
}

declare -A VAL
for k in "${PARAM_KEYS[@]}"; do
  v="$(get_param "$k" || true)"
  if [[ -z "$v" || "$v" == "None" ]]; then
    echo "Missing required environment variable: $k"
    exit 1
  fi
  VAL["$k"]="$v"
  export "$k=${VAL[$k]}"
done

aws logs create-log-group --region "$REGION" --log-group-name "$LOG_GROUP" 2>/dev/null || true
aws logs put-retention-policy --region "$REGION" --log-group-name "$LOG_GROUP" --retention-in-days 14 || true

IMDS="http://169.254.169.254"
TOKEN="$(curl -s -X PUT "$IMDS/latest/api/token" -H 'X-aws-ec2-metadata-token-ttl-seconds: 21600' || true)"
IID="$(curl -s "$IMDS/latest/meta-data/instance-id" -H "X-aws-ec2-metadata-token: ${TOKEN}" || echo "unknown")"
LOG_STREAM="${CONTAINER_NAME}-${IID}"

ENV_ARGS=()
for k in "${PARAM_KEYS[@]}"; do ENV_ARGS+=(-e "$k=${VAL[$k]}"); done

docker run --rm "${ENV_ARGS[@]}" "$IMAGE" alembic upgrade head

docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

docker run -d --name "$CONTAINER_NAME" --restart unless-stopped \
  -p "$HOST_PORT:$CONTAINER_PORT" \
  --log-driver "$LOG_DRIVER" \
  --log-opt awslogs-region="$REGION" \
  --log-opt awslogs-group="$LOG_GROUP" \
  --log-opt awslogs-stream="$LOG_STREAM" \
  "${ENV_ARGS[@]}" \
  "$IMAGE"
