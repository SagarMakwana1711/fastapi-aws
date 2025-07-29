#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="${ROOT_DIR}/manifest.env"
IMDS_HOST="http://169.254.169.254"
IMDS_TOKEN_URL="${IMDS_HOST}/latest/api/token"
IMDS_DOC_URL="${IMDS_HOST}/latest/dynamic/instance-identity/document"
DEFAULT_REGION="us-east-1"
LOG_GROUP_DEFAULT="/fastapi/app"
CONTAINER_NAME_DEFAULT="fastapi"
HOST_PORT_DEFAULT="8080"
CONTAINER_PORT_DEFAULT="80"

echo "Looking for manifest at ${MANIFEST}"

if [[ -f "$MANIFEST" ]]; then
  while IFS= read -r line; do
    [[ -z "${line:-}" ]] && continue
    [[ "${line:0:1}" == "#" ]] && continue
    line="${line#export }"
    key="${line%%=*}"
    val="${line#*=}"
    val="${val%\"}"; val="${val#\"}"; val="${val%\'}"; val="${val#\'}"
    export "${key}=${val}"
  done < "$MANIFEST"
fi

if [[ -z "${REGION:-}" ]]; then
  token="$(curl -sS -X PUT "$IMDS_TOKEN_URL" -H "X-aws-ec2-metadata-token-ttl-seconds: 60" || true)"
  meta="$(curl -sS -H "X-aws-ec2-metadata-token: ${token}" "$IMDS_DOC_URL" 2>/dev/null || true)"
  REGION="$(awk -F'"' '/region/ {print $4}' <<<"$meta")"
  REGION="${REGION:-$DEFAULT_REGION}"
fi

: "${REPOSITORY_URI:?REPOSITORY_URI is required}"
: "${IMAGE_TAG:?IMAGE_TAG is required}"
: "${CONTAINER_NAME:=$CONTAINER_NAME_DEFAULT}"
: "${HOST_PORT:=$HOST_PORT_DEFAULT}"
: "${CONTAINER_PORT:=$CONTAINER_PORT_DEFAULT}"
: "${LOG_GROUP:=$LOG_GROUP_DEFAULT}"

IMAGE="${REPOSITORY_URI}:${IMAGE_TAG}"

export REGION
export AWS_DEFAULT_REGION="$REGION"
export IMAGE CONTAINER_NAME HOST_PORT CONTAINER_PORT LOG_GROUP
