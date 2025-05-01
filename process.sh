#!/bin/sh

# Check if running in bash for pipefail support
if [ -n "$BASH_VERSION" ]; then
    set -euo pipefail
else
    set -eu
fi

IMAGE_NAME=my-docker-image
CONTAINER_NAME=my-container
HASH_FILE="image-hash.txt"

echo "🛠 Building Docker image..."
# Capture the image ID from the build output
IMAGE_ID=$(docker build -t "$IMAGE_NAME" . | tee /dev/tty | awk '/Successfully built/ {print $NF}')

# Save the image ID to a file
echo "$IMAGE_ID" > "$HASH_FILE"
echo "📦 Image hash written to $HASH_FILE: $IMAGE_ID"

echo "🚀 Running Docker container..."
docker run -d -p 80:80 --name "$CONTAINER_NAME" "$IMAGE_NAME"

sleep 10

echo "🔍 Checking if container is running..."
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "✅ Container is running"
else
    echo "❌ Container is not running"
    exit 1
fi

echo "🧹 Stopping and removing container..."
docker stop "$CONTAINER_NAME" || true
docker rm -f "$CONTAINER_NAME" || true

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "❌ Container is not removed"
    exit 1
else
    echo "✅ Container is removed"
fi

echo "🧼 Removing Docker image..."
docker rmi "$IMAGE_NAME" || true

if docker images --format '{{.Repository}}' | grep -q "^${IMAGE_NAME}$"; then
    echo "❌ Image is not removed"
    exit 1
else
    echo "✅ Image is removed"
fi

echo "🎉 All operations completed successfully."
echo "🧹 Cleaning up..."
