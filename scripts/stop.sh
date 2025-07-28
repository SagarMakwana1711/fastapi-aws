#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

docker ps -aq --filter "name=^/${CONTAINER_NAME}$" | xargs -r docker rm -f