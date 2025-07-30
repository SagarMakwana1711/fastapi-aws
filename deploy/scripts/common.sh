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
CONTAINER_PORT_DEFAULT="8080"

echo "Looking for manifest at ${MANIFEST}"

if [[ -f "$MANIFEST" ]]; then
  set -a
  source "$MANIFEST"
  set +a
fi


REGION="us-east-1"
AWS_DEFAULT_REGION="us-east-1"

: "${REPOSITORY_URI:?REPOSITORY_URI is required}"
: "${IMAGE_TAG:?IMAGE_TAG is required}"
: "${CONTAINER_NAME:=$CONTAINER_NAME_DEFAULT}"
: "${HOST_PORT:=$HOST_PORT_DEFAULT}"
: "${CONTAINER_PORT:=$CONTAINER_PORT_DEFAULT}"
: "${LOG_GROUP:=$LOG_GROUP_DEFAULT}"

IMAGE="${REPOSITORY_URI}:${IMAGE_TAG}"
REGISTRY="${REPOSITORY_URI%%/*}"

export REGION
export AWS_DEFAULT_REGION="$REGION"
export IMAGE REGISTRY CONTAINER_NAME HOST_PORT CONTAINER_PORT LOG_GROUP
