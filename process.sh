#!/bin/bash
set -e  # Exit script if any command fails

IMAGE_NAME=my-docker-image
CONTAINER_NAME=my-container

echo "Building Docker image..."
docker build -t $IMAGE_NAME .

echo "Running Docker container..."
docker run -d -p 80:80 --name $CONTAINER_NAME $IMAGE_NAME

sleep 10

if docker ps -q -f name=$CONTAINER_NAME > /dev/null; then
    echo "✅ Container is running"
else
    echo "❌ Container is not running"
    exit 1
fi

echo "Stopping and removing container..."
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

if docker ps -aq -f name=$CONTAINER_NAME > /dev/null; then
    echo "❌ Container is not removed"
    exit 1
else
    echo "✅ Container is removed"
fi

echo "Removing Docker image..."
docker rmi $IMAGE_NAME

if docker images -q $IMAGE_NAME > /dev/null; then
    echo "❌ Image is not removed"
    exit 1
else
    echo "✅ Image is removed"
fi
echo "All operations completed successfully."
echo "Cleaning up..."