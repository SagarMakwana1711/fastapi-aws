#!/bin/bash
set -e

echo "Starting Docker Compose deployment..."

cd /home/ec2-user/app || exit 1

docker compose down || true
docker compose up -d --build