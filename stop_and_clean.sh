#!/bin/bash
set -e

CHANGED="changed-containers.txt"

if [ ! -f "$CHANGED" ] || [ ! -s "$CHANGED" ]; then
  echo "ℹ️ No containers to clean up (no changes detected)."
  exit 0
fi

while read i; do
  CONTAINER="my-container-$i"
  IMAGE="my-docker-image-$i"

  echo "🛑 Stopping $CONTAINER..."
  docker stop "$CONTAINER" || true

  echo "🗑 Removing $CONTAINER..."
  docker rm -f "$CONTAINER" || true

  echo "🧼 Removing image $IMAGE..."
  docker rmi "$IMAGE" || true
done < "$CHANGED"
