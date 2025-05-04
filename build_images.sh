#!/bin/bash
set -eu

HASH_FILE="image-hash.txt"
> "$HASH_FILE"

echo "🔍 Detecting html folders in src/..."

HTML_DIRS=$(find src -maxdepth 1 -type d -name 'html*' | sort)

MAX_INDEX=0

for FOLDER in $HTML_DIRS; do
    # Extract numeric index from folder name, e.g., html6 → 6
    INDEX=$(basename "$FOLDER" | grep -o '[0-9]*$')
    IMAGE_NAME="my-docker-image-$INDEX"

    APP_HASH=$(find "$FOLDER" -type f -exec sha256sum {} \; | sort | sha256sum | awk '{print $1}')

    echo "🔨 Building $IMAGE_NAME from $FOLDER..."
    docker build -t "$IMAGE_NAME" \
        --build-arg APP_TYPE=html \
        --build-arg APP_DIR=$FOLDER \
        -f Dockerfile .

    echo "$IMAGE_NAME: $APP_HASH" >> "$HASH_FILE"
    echo "✅ Wrote content hash for $IMAGE_NAME"

    # Keep track of the highest index
    if [ "$INDEX" -gt "$MAX_INDEX" ]; then
        MAX_INDEX=$INDEX
    fi
done

# Build PHP app as the next available index
PHP_INDEX=$((MAX_INDEX + 1))
IMAGE_NAME="my-docker-image-$PHP_INDEX"
APP_DIR="php-app"

APP_HASH=$(find "$APP_DIR" -type f -exec sha256sum {} \; | sort | sha256sum | awk '{print $1}')

echo "🔨 Building $IMAGE_NAME from $APP_DIR (PHP)..."
docker build -t "$IMAGE_NAME" \
    --build-arg APP_TYPE=php \
    --build-arg APP_DIR=$APP_DIR \
    -f Dockerfile .

echo "$IMAGE_NAME: $APP_HASH" >> "$HASH_FILE"
echo "✅ Wrote content hash for $IMAGE_NAME"

echo "📄 All hashes written to $HASH_FILE"
