#!/bin/bash
set -e

echo "🚀 Starting changed containers..."

if [ ! -f changed-containers.txt ] || [ ! -s changed-containers.txt ]; then
  echo "ℹ️ No changed containers to run."
  exit 0
fi

while read i; do
  IMAGE="my-docker-image-$i"
  CONTAINER="my-container-$i"
  PORT=$((8080 + i))

  echo "🔧 Running $CONTAINER from $IMAGE on port $PORT..."

  docker run -d -p "$PORT:80" --name "$CONTAINER" "$IMAGE"
done < changed-containers.txt

echo "✅ All changed containers are up."
