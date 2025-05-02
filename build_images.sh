#!/bin/sh

set -eu

TOTAL=5
HASH_FILE="image-hash.txt"
START_PORT=8081

# Clear previous hashes
> "$HASH_FILE"

for i in $(seq 1 $TOTAL); do
    IMAGE_NAME="my-docker-image-$i"
    DOCKERFILE="Dockerfile.$i"

    echo "🔨 Building $IMAGE_NAME from $DOCKERFILE..."
    docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" .

    IMAGE_ID=$(docker images --no-trunc --format '{{.Repository}} {{.ID}}' | grep "^$IMAGE_NAME " | awk '{print $2}')
    echo "$IMAGE_NAME: $IMAGE_ID" >> "$HASH_FILE"
    echo "✅ Wrote hash for $IMAGE_NAME"
done

echo "📄 All hashes written to $HASH_FILE"
