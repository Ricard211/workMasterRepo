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

HASH_FILE="image-hash.txt"

echo "🛠 Building Docker image..."
docker build -t "$IMAGE_NAME" .

# Get full sha256 digest (requires image to be pushed or locally content-addressed)
DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE_NAME" 2>/dev/null || true)

# If no digest is found (e.g., image hasn't been pushed), fallback to image ID
if [ -z "$DIGEST" ]; then
    DIGEST="sha256:$(docker images --no-trunc --format '{{.ID}}' "$IMAGE_NAME" | head -n 1)"
fi

echo "$DIGEST" > "$HASH_FILE"
echo "📦 SHA256 digest written to $HASH_FILE: $DIGEST"

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
