#!/bin/sh
set -eu

HASH_FILE="image-hash.txt"
> "$HASH_FILE"

echo "🔍 Detecting html folders in src/..."

HTML_DIRS=$(find src -maxdepth 1 -type d -name 'html*' | sort)
i=1

for FOLDER in $HTML_DIRS; do
    IMAGE_NAME="my-docker-image-$i"

    echo "🔨 Building $IMAGE_NAME from $FOLDER..."
    docker build -t "$IMAGE_NAME" \
        --build-arg APP_DIR=$FOLDER \
        -f Dockerfile .

    IMAGE_ID=$(docker images --no-trunc --format '{{.Repository}} {{.ID}}' | grep "^$IMAGE_NAME " | awk '{print $2}')
    echo "$IMAGE_NAME: $IMAGE_ID" >> "$HASH_FILE"
    echo "✅ Wrote hash for $IMAGE_NAME"

    i=$((i+1))
done

# Build old-red-stream PHP app (as container 6)
IMAGE_NAME="my-docker-image-6"
APP_DIR="php-app"

APP_HASH=$(find $APP_DIR -type f -exec sha256sum {} \; | sort | sha256sum | awk '{print $1}')

echo "🔨 Building $IMAGE_NAME from $APP_DIR..."
docker build -t "$IMAGE_NAME" \
  --build-arg APP_DIR=$APP_DIR \
  --label content-hash=$APP_HASH \
  -f Dockerfile .

IMAGE_ID=$(docker images --no-trunc --format '{{.Repository}} {{.ID}}' | grep "^$IMAGE_NAME " | awk '{print $2}')
echo "$IMAGE_NAME: $IMAGE_ID" >> "$HASH_FILE"
echo "✅ Wrote hash for $IMAGE_NAME"

