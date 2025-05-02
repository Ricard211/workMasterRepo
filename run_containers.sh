#!/bin/sh

set -eu

TOTAL=5
START_PORT=8081

for i in $(seq 1 $TOTAL); do
    IMAGE_NAME="my-docker-image-$i"
    CONTAINER_NAME="my-container-$i"
    PORT=$((START_PORT + i - 1))

    echo "🚀 Running $CONTAINER_NAME on port $PORT..."
    docker run -d -p "$PORT":80 --name "$CONTAINER_NAME" "$IMAGE_NAME"

    sleep 2

    if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo "✅ $CONTAINER_NAME is running"
    else
        echo "❌ $CONTAINER_NAME failed to start"
        exit 1
    fi
done
