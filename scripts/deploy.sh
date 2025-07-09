#!/bin/bash
set -e

echo "Starting Docker Compose deployment..."

export RDS_HOSTNAME=database-1.cud4ao0gqt8o.us-east-1.rds.amazonaws.com
export RDS_DB_NAME=my_db
export RDS_USERNAME=postgres
export RDS_PASSWORD=SagarMakwana
export RDS_PORT=5432

cd /home/ec2-user/app || exit 1

docker compose down || true
docker compose up -d --build
