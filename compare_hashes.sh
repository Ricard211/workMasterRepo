#!/bin/sh

set -eu

CURRENT="image-hash.txt"
PREVIOUS="previous/image-hash.txt"

if [ ! -f "$PREVIOUS" ]; then
    echo "ℹ️ No previous hash file found."
    exit 0
fi

echo "🔍 Comparing image hashes..."

while IFS= read -r current_line || [ -n "$current_line" ]; do
    image_name=$(echo "$current_line" | cut -d':' -f1 | xargs)
    current_hash=$(echo "$current_line" | cut -d':' -f2- | xargs)

    prev_line=$(grep "^$image_name:" "$PREVIOUS" || true)

    if [ -n "$prev_line" ]; then
        prev_hash=$(echo "$prev_line" | cut -d':' -f2- | xargs)
        if [ "$current_hash" = "$prev_hash" ]; then
            echo "✅ $image_name hash MATCHES previous build."
        else
            echo "⚠️ $image_name hash CHANGED!"
        fi
    else
        echo "🆕 $image_name is NEW in this build."
    fi
done < "$CURRENT"
