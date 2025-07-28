#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

for i in {1..30}; do
  if curl -fsS "http://127.0.0.1:${HOST_PORT}/" >/dev/null; then
    exit 0
  fi
  sleep 2
done

echo "Health check failed at /"
exit 1
