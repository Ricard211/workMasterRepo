#!/bin/bash
set -eu

HASH_FILE="image-hash.txt"
> "$HASH_FILE"

echo "🔍 Detecting html folders in src/ (version-sorted)..."

# Version-aware sort ensures html2 comes after html1, etc.
HTML_DIRS=$(find src -maxdepth 1 -type d -name 'html*' | sort -V)

MAX_INDEX=0

for FOLDER in $HTML_DIRS; do
    BASENAME=$(basename "$FOLDER")
    # Grab the numeric suffix: html12 → 12
    INDEX=$(echo "$BASENAME" | grep -o '[0-9]\+$')
    IMAGE_NAME="my-docker-image-$INDEX"

    # Compute a stable content hash for the folder
    APP_HASH=$(find "$FOLDER" -type f -exec sha256sum {} \; \
               | sort \
               | sha256sum \
               | awk '{print $1}')

    echo "🔨 Building $IMAGE_NAME from $FOLDER..."
    # Build using the per-folder context and shared Dockerfile.html
    docker build -t "$IMAGE_NAME" -f Dockerfile.html "$FOLDER"

    echo "$IMAGE_NAME: $APP_HASH" >> "$HASH_FILE"
    echo "✅ Wrote content hash for $IMAGE_NAME"

    # Track highest index seen
    if [ "$INDEX" -gt "$MAX_INDEX" ]; then
        MAX_INDEX=$INDEX
    fi
done

# Now build the PHP app as the next index
PHP_INDEX=$((MAX_INDEX + 1))
IMAGE_NAME="my-docker-image-$PHP_INDEX"
APP_DIR="php-app"

# Compute its content hash
APP_HASH=$(find "$APP_DIR" -type f -exec sha256sum {} \; \
           | sort \
           | sha256sum \
           | awk '{print $1}')

echo "🔨 Building $IMAGE_NAME from $APP_DIR (PHP)…"
docker build -t "$IMAGE_NAME" -f Dockerfile.php "$APP_DIR"

echo "$IMAGE_NAME: $APP_HASH" >> "$HASH_FILE"
echo "✅ Wrote content hash for $IMAGE_NAME"

echo "📄 All hashes written to $HASH_FILE"
