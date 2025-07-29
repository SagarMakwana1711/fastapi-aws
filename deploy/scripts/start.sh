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

aws logs create-log-group \
  --region "$REGION" \
  --log-group-name "$LOG_GROUP" \
  2>/dev/null || true

ENV_ARGS=()
for k in "${PARAM_KEYS[@]}"; do ENV_ARGS+=(-e "$k=${VAL[$k]}"); done

docker run --rm "${ENV_ARGS[@]}" "$IMAGE" alembic upgrade head

docker run -d --name "$CONTAINER_NAME" --restart unless-stopped \
  -p "$HOST_PORT:$CONTAINER_PORT" \
  --log-driver "$LOG_DRIVER" \
  --log-opt awslogs-region="$REGION" \
  --log-opt awslogs-group="$LOG_GROUP" \
  --log-opt awslogs-stream="$CONTAINER_NAME" \
  "${ENV_ARGS[@]}" \
  "$IMAGE"