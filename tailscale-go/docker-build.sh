#!/bin/bash

# 設置變量
IMAGE_NAME="tailscale-ha"
TAG="latest"

# 構建 Docker 映像
echo "構建 Docker 映像 ${IMAGE_NAME}:${TAG}..."
docker build -t ${IMAGE_NAME}:${TAG} .

echo "構建完成！"
echo "您可以使用以下命令運行容器："
echo "docker run -d --name tailscale-ha \\"
echo "  --restart unless-stopped \\"
echo "  --cap-add NET_ADMIN \\"
echo "  --cap-add NET_RAW \\"
echo "  --device /dev/net/tun \\"
echo "  -v \$(pwd)/docker-data:/data \\"
echo "  -v \$(pwd)/docker-share:/share \\"
echo "  -p 41641:41641/udp \\"
echo "  ${IMAGE_NAME}:${TAG}" 