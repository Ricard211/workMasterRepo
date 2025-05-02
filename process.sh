#!/bin/sh

# Enable strict mode if bash
if [ -n "$BASH_VERSION" ]; then
    set -euo pipefail
else
    set -eu
fi

# Detect if running in Jenkins
if [ -n "${JENKINS_HOME:-}" ]; then
    BASE_DIR="${WORKSPACE:-.}"
else
    BASE_DIR="."
fi

TOTAL=5
START_PORT=8081
HASH_FILE="$BASE_DIR/image-hash.txt"

# Clear the hash file
> "$HASH_FILE"

echo "📦 Starting multi-image Docker build & run..."

for i in $(seq 1 $TOTAL); do
    IMAGE_NAME="my-docker-image-$i"
    CONTAINER_NAME="my-container-$i"
    DOCKERFILE="Dockerfile.$i"
    PORT=$((START_PORT + i - 1))

    echo "🔨 Building $IMAGE_NAME from $DOCKERFILE..."
    docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" .

    echo "🔍 Getting image ID for $IMAGE_NAME..."
    IMAGE_ID=$(docker images --no-trunc --format '{{.Repository}} {{.ID}}' | grep "^$IMAGE_NAME " | awk '{print $2}')
    if [ -n "$IMAGE_ID" ]; then
        echo "$IMAGE_NAME: $IMAGE_ID" >> "$HASH_FILE"
        echo "✅ Wrote hash for $IMAGE_NAME to $HASH_FILE"
    else
        echo "❌ Failed to get image ID for $IMAGE_NAME"
        exit 1
    fi

    echo "🚀 Running container $CONTAINER_NAME on port $PORT..."
    docker run -d -p "$PORT":80 --name "$CONTAINER_NAME" "$IMAGE_NAME"

    sleep 5

    echo "🔍 Checking if $CONTAINER_NAME is running..."
    if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo "✅ $CONTAINER_NAME is running"
    else
        echo "❌ $CONTAINER_NAME failed to start"
        exit 1
    fi
done

echo "✅ All containers running. Waiting 10 seconds..."
sleep 10

echo "🧹 Stopping and removing all containers and images..."

for i in $(seq 1 $TOTAL); do
    IMAGE_NAME="my-docker-image-$i"
    CONTAINER_NAME="my-container-$i"

    echo "🛑 Stopping $CONTAINER_NAME..."
    docker stop "$CONTAINER_NAME" || true

    echo "🗑 Removing $CONTAINER_NAME..."
    docker rm -f "$CONTAINER_NAME" || true

    if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo "❌ $CONTAINER_NAME was not removed"
        exit 1
    else
        echo "✅ $CONTAINER_NAME removed"
    fi

    echo "🧼 Removing image $IMAGE_NAME..."
    docker rmi "$IMAGE_NAME" || true

    if docker images --format '{{.Repository}}' | grep -q "^$IMAGE_NAME$"; then
        echo "❌ $IMAGE_NAME was not removed"
        exit 1
    else
        echo "✅ $IMAGE_NAME removed"
    fi
done

echo "🎉 All containers and images cleaned up successfully."
echo "📄 Final hash file written to: $HASH_FILE"
