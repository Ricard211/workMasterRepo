#!/bin/sh

set -eu

TOTAL=5

for i in $(seq 1 $TOTAL); do
    IMAGE_NAME="my-docker-image-$i"
    CONTAINER_NAME="my-container-$i"

    echo "🛑 Stopping $CONTAINER_NAME..."
    docker stop "$CONTAINER_NAME" || true

    echo "🗑 Removing $CONTAINER_NAME..."
    docker rm -f "$CONTAINER_NAME" || true

    echo "🧼 Removing image $IMAGE_NAME..."
    docker rmi "$IMAGE_NAME" || true
done

echo "✅ All containers and images removed"
