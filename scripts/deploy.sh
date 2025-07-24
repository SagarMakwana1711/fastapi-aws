#!/bin/bash
set -e

echo "Starting Docker Compose deployment..."

export RDS_HOSTNAME=
export RDS_DB_NAME=
export RDS_USERNAME=
export RDS_PASSWORD=
export RDS_PORT=5432

cd /home/ec2-user/app || exit 1

docker compose down || true
docker compose up -d --build
