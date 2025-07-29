#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "Looking for manifest at ${ROOT_DIR}/manifest.env"
source "${ROOT_DIR}/manifest.env"
REGION="us-east-1"
APP_NAME="fastapi-app"
CONTAINER_NAME="fastapi"
HOST_PORT=8080
CONTAINER_PORT=80
ENV_FILE="/opt/fastapi/.env"
LOG_GROUP="/fastapi/app"
REGISTRY="${REPOSITORY_URI%%/*}"
IMAGE="${REPOSITORY_URI}:${IMAGE_TAG}"