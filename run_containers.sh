#!/bin/bash
set -e

CHANGED="changed-containers.txt"

for i in $(seq 1 5); do
  if grep -q "^$i$" "$CHANGED"; then
    PORT=$((8080 + i))
    IMG="my-docker-image-$i"
    CONTAINER="my-container-$i"

    echo "🚀 Starting $CONTAINER on port $PORT..."
    docker run -d -p "$PORT":80 --name "$CONTAINER" "$IMG"
  else
    echo "⏭ Skipping container $i — image unchanged."
  fi
done
