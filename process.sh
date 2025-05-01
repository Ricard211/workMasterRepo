#!/bin/bash

# Build the Docker image
docker build -t my-docker-image .

# Run the Docker container
docker run -d -p 80:80 --name my-container my-docker1
# Wait for the container to be fully up and running
sleep 10
# Check if the container is running
if [ "$(docker ps -q -f name=my-container)" ]; then
    echo "Container is running"
else
    echo "Container is not running"
    exit 1
fi

docker stop my-container
docker rm my-container
# Check if the container is removed
if [ "$(docker ps -aq -f name=my-container)" ]; then
    echo "Container is not removed"
    exit 1
else
    echo "Container is removed"
fi

docker rmi my-docker-image
# Check if the image is removed
if [ "$(docker images -q my-docker-image)" ]; then
    echo "Image is not removed"
    exit 1
else
    echo "Image is removed"
fi

