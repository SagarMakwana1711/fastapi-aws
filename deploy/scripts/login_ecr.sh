#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

aws ecr get-login-password --region "${REGION}" \
  | docker login --username AWS --password-stdin "${REGISTRY}"