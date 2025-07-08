FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install --no-install-recommends -y gcc netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY ./app ./app
COPY alembic.ini .
COPY ./alembic ./alembic

EXPOSE 80

CMD ["sh", "-c", "set -e && alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port 80"]

