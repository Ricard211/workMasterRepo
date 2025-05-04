#!/bin/bash
set -e

CURRENT=image-hash.txt
PREVIOUS=previous/image-hash.txt
CHANGED=changed-containers.txt

> "$CHANGED"

echo "🔍 Comparing image hashes..."

while read -r line; do
    IMAGE=$(echo "$line" | cut -d: -f1)
    HASH=$(echo "$line" | cut -d: -f2 | xargs)

    # Try to get matching line from previous file
    PREV_HASH=$(grep "^$IMAGE:" "$PREVIOUS" 2>/dev/null | cut -d: -f2 | xargs || echo "")

    if [ "$HASH" != "$PREV_HASH" ] || [ -z "$PREV_HASH" ]; then
        INDEX=$(echo "$IMAGE" | grep -o '[0-9]*$')
        echo "$INDEX" >> "$CHANGED"
        echo "⚠️  Hash mismatch or missing for $IMAGE – marked as changed."
    else
        echo "✅ Hash match for $IMAGE – skipping."
    fi
done < "$CURRENT"

echo "📄 Containers to run:"
cat "$CHANGED"
