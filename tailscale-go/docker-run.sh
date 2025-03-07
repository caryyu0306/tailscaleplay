#!/bin/bash

# 設置變量
IMAGE_NAME="tailscale"
VERSION="latest"
CONTAINER_NAME="tailscale"

# 確保目錄存在
mkdir -p docker-data
mkdir -p docker-share/taildrop

# 設置權限
chmod 755 docker-data
chmod 755 docker-share/taildrop

# 運行 Docker 容器
echo "啟動 Tailscale 附加元件..."
docker run -d --name $CONTAINER_NAME \
  --restart unless-stopped \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW \
  --device /dev/net/tun \
  -v $(pwd)/docker-data:/data \
  -v $(pwd)/docker-share:/share \
  -p 41641:41641/udp \
  $IMAGE_NAME:$VERSION

echo "Tailscale 附加元件已啟動，請查看 Docker 日誌"
echo "使用: docker logs $CONTAINER_NAME" 