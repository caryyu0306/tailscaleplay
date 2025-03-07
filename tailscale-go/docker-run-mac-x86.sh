#!/bin/bash

# 設置變量
IMAGE_NAME="tailscale-ha"
TAG="mac-x86"
CONTAINER_NAME="tailscale-ha"

# 創建數據目錄
mkdir -p docker-data
mkdir -p docker-share/taildrop

# 檢查容器是否已存在
if [ "$(docker ps -a -q -f name=${CONTAINER_NAME})" ]; then
    echo "停止並移除現有容器..."
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
fi

# 運行容器（後台模式）
echo "啟動 ${CONTAINER_NAME} 容器..."
docker run -d --name ${CONTAINER_NAME} \
  --platform=linux/amd64 \
  --hostname ${CONTAINER_NAME} \
  --restart unless-stopped \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW \
  --device /dev/net/tun \
  -v $(pwd)/docker-data:/data \
  -v $(pwd)/docker-share:/share \
  -p 41641:41641/udp \
  ${IMAGE_NAME}:${TAG}

echo "容器已啟動！"
echo "等待 Tailscale 啟動..."

# 等待 Tailscale 啟動
MAX_ATTEMPTS=30
ATTEMPT=0
TAILSCALE_READY=false

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT+1))
    
    # 獲取容器日誌
    LOGS=$(docker logs ${CONTAINER_NAME} 2>&1)
    
    # 檢查是否已經啟動
    if echo "$LOGS" | grep -q "Tailscale 已啟動"; then
        TAILSCALE_READY=true
        break
    fi
    
    # 檢查是否包含舊格式的認證 URL
    if echo "$LOGS" | grep -q "To authenticate, visit:"; then
        # 提取並顯示認證 URL
        AUTH_URL=$(echo "$LOGS" | grep -A 1 "To authenticate, visit:" | tail -n 1 | tr -d ' \t')
        echo ""
        echo "========================================================"
        echo "認證 URL: $AUTH_URL"
        echo "========================================================"
        echo ""
        
        # 顯示 QR 碼
        echo "$LOGS" | grep -A 50 "^█" | head -n 50
        
        TAILSCALE_READY=true
        break
    fi
    
    # 檢查是否包含新格式的認證 URL (control: AuthURL is)
    if echo "$LOGS" | grep -q "control: AuthURL is"; then
        # 提取並顯示認證 URL
        AUTH_URL=$(echo "$LOGS" | grep "control: AuthURL is" | sed 's/.*control: AuthURL is //')
        echo ""
        echo "========================================================"
        echo "認證 URL: $AUTH_URL"
        echo "========================================================"
        echo ""
        
        # 嘗試生成 QR 碼 (如果有)
        QR_CODE=$(echo "$LOGS" | grep -A 50 "^█" | head -n 50)
        if [ ! -z "$QR_CODE" ]; then
            echo "$QR_CODE"
        else
            echo "沒有找到 QR 碼，請使用上面的 URL 進行認證"
        fi
        
        TAILSCALE_READY=true
        break
    fi
    
    echo "等待 Tailscale 啟動 (嘗試 $ATTEMPT/$MAX_ATTEMPTS)..."
    sleep 1
done

if [ "$TAILSCALE_READY" = true ]; then
    echo "Tailscale 已成功啟動！"
    
    # 顯示 Tailscale 狀態
    echo ""
    echo "Tailscale 狀態："
    docker exec ${CONTAINER_NAME} tailscale --socket=/tmp/tailscale/tailscaled.sock status || echo "無法獲取 Tailscale 狀態，請檢查容器日誌"
else
    echo "Tailscale 啟動超時，請檢查容器日誌："
    echo "docker logs -f ${CONTAINER_NAME}"
fi 