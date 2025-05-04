#!/bin/bash
set -eu

HASH_FILE="image-hash.txt"
> "$HASH_FILE"

echo "🔍 Detecting html folders in src/..."

HTML_DIRS=$(find src -maxdepth 1 -type d -name 'html*' | sort)
MAX_INDEX=0

for FOLDER in $HTML_DIRS; do
    INDEX=$(basename "$FOLDER" | grep -o '[0-9]\+$' || echo $((MAX_INDEX + 1)))
    IMAGE_NAME="my-docker-image-$INDEX"

    APP_HASH=$(find "$FOLDER" -type f -exec sha256sum {} \; | sort | sha256sum | awk '{print $1}')

    echo "🔨 Building $IMAGE_NAME from $FOLDER using Dockerfile.html..."
    docker build -t "$IMAGE_NAME" -f Dockerfile.html "$FOLDER"

    echo "$IMAGE_NAME: $APP_HASH" >> "$HASH_FILE"
    echo "✅ Wrote content hash for $IMAGE_NAME"

    if [ "$INDEX" -gt "$MAX_INDEX" ]; then
        MAX_INDEX=$INDEX
    fi
done

# Build PHP app next
PHP_INDEX=$((MAX_INDEX + 1))
IMAGE_NAME="my-docker-image-$PHP_INDEX"
APP_DIR="php-app"
APP_HASH=$(find "$APP_DIR" -type f -exec sha256sum {} \; | sort | sha256sum | awk '{print $1}')

echo "🔨 Building $IMAGE_NAME from $APP_DIR using Dockerfile.php..."
docker build -t "$IMAGE_NAME" -f Dockerfile.php "$APP_DIR"

echo "$IMAGE_NAME: $APP_HASH" >> "$HASH_FILE"
echo "✅ Wrote content hash for $IMAGE_NAME"
echo "📄 All hashes written to $HASH_FILE"
