#!/bin/bash

# 設置變量
IMAGE_NAME="tailscale-ha"
TAG="mac-arm"

# 確保 Docker 使用 arm64 平台構建
echo "構建 macOS ARM (Apple Silicon) 兼容的 Docker 映像 ${IMAGE_NAME}:${TAG}..."
docker build --platform=linux/arm64 -t ${IMAGE_NAME}:${TAG} -f Dockerfile.mac-arm .

echo "構建完成！"
echo "您可以使用以下命令運行容器："
echo "docker run -d --name tailscale-ha \\"
echo "  --restart unless-stopped \\"
echo "  --cap-add NET_ADMIN \\"
echo "  --cap-add NET_RAW \\"
echo "  --device /dev/net/tun \\"
echo "  -v \$(pwd)/docker-data:/data \\"
echo "  -v \$(pwd)/docker-share:/share \\"
echo "  -p 8099:8099 \\"
echo "  -p 41641:41641/udp \\"
echo "  ${IMAGE_NAME}:${TAG}"

# 可選：創建一個 docker-compose-mac-arm.yml 文件
cat > docker-compose-mac-arm.yml << EOL
version: '3'

services:
  tailscale-ha:
    image: ${IMAGE_NAME}:${TAG}
    platform: linux/arm64
    container_name: tailscale-ha
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - NET_RAW
    devices:
      - /dev/net/tun
    volumes:
      - ./docker-data:/data
      - ./docker-share:/share
    ports:
      - "8099:8099"
      - "41641:41641/udp"
EOL

echo "已創建 docker-compose-mac-arm.yml 文件，您可以使用以下命令運行："
echo "docker-compose -f docker-compose-mac-arm.yml up -d" 