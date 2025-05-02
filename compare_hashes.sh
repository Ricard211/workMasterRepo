#!/bin/bash
set -euo pipefail

CURRENT_HASH="image-hash.txt"
PREVIOUS_HASH="previous/image-hash.txt"
CHANGED_LIST="changed-containers.txt"
> "$CHANGED_LIST"

# Check for line-by-line differences
for i in $(seq 1 5); do
  IMG="my-docker-image-$i"
  CUR_HASH=$(grep "^$IMG" "$CURRENT_HASH" | awk '{print $2}')
  PREV_HASH=$(grep "^$IMG" "$PREVIOUS_HASH" 2>/dev/null | awk '{print $2}')

  if [ "$CUR_HASH" != "$PREV_HASH" ]; then
    echo "$i" >> "$CHANGED_LIST"
    echo "⚠️ Hash mismatch for $IMG (or not found)."
  else
    echo "✅ Hash match for $IMG – skipping."
  fi
done
