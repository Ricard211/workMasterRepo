#!/bin/bash
set -eu

HASH_FILE="image-hash.txt"
> "$HASH_FILE"

echo "🔍 Detecting html folders in src/..."

HTML_DIRS=$(find src -maxdepth 1 -type d -name 'html*' | sort)
i=1

for FOLDER in $HTML_DIRS; do
    IMAGE_NAME="my-docker-image-$i"

    APP_HASH=$(find "$FOLDER" -type f -exec sha256sum {} \; | sort | sha256sum | awk '{print $1}')

    echo "🔨 Building $IMAGE_NAME from $FOLDER..."
    docker build -t "$IMAGE_NAME" \
        --build-arg APP_TYPE=html \
        --build-arg APP_DIR=$FOLDER \
        -f Dockerfile .

    echo "$IMAGE_NAME: $APP_HASH" >> "$HASH_FILE"
    echo "✅ Wrote content hash for $IMAGE_NAME"

    i=$((i+1))
done

# Now PHP app uses next available index
IMAGE_NAME="my-docker-image-$i"
APP_DIR="php-app"
APP_HASH=$(find "$APP_DIR" -type f -exec sha256sum {} \; | sort | sha256sum | awk '{print $1}')

echo "🔨 Building $IMAGE_NAME from $APP_DIR (PHP)..."
docker build -t "$IMAGE_NAME" \
    --build-arg APP_TYPE=php \
    --build-arg APP_DIR=$APP_DIR \
    -f Dockerfile .

echo "$IMAGE_NAME: $APP_HASH" >> "$HASH_FILE"
echo "✅ Wrote content hash for $IMAGE_NAME"

