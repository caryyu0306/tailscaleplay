# 改進 Docker 運行腳本中的環境變量處理

## 問題描述

目前的 Docker 運行腳本（如 docker-run-mac-x86.sh）在處理 options.json 中的配置項轉換為環境變量時存在一些問題：

1. 多個 TS_EXTRA_ARGS 環境變量會相互覆蓋，只有最後一個會生效
2. 某些配置項（如 advertise_connector, funnel, proxy 等）未被處理
3. 缺少對數組類型配置項的適當處理

## 建議改進

1. 將多個 TS_EXTRA_ARGS 合併為一個字符串，用空格分隔
2. 添加對所有 options.json 配置項的支持
3. 改進數組類型配置項的處理
4. 添加更詳細的日誌輸出，顯示實際使用的配置

## 示例代碼

```bash
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

# 從options.json讀取配置並設置環境變量
CONFIG_FILE="options.json"
if [ -f "$CONFIG_FILE" ]; then
    echo "從 $CONFIG_FILE 讀取配置..."
    
    # 讀取基本配置項
    ACCEPT_DNS=$(jq -r '.accept_dns // true' "$CONFIG_FILE")
    ACCEPT_ROUTES=$(jq -r '.accept_routes // true' "$CONFIG_FILE")
    ADVERTISE_EXIT_NODE=$(jq -r '.advertise_exit_node // true' "$CONFIG_FILE")
    ADVERTISE_CONNECTOR=$(jq -r '.advertise_connector // true' "$CONFIG_FILE")
    ADVERTISE_ROUTES=$(jq -r '.advertise_routes | join(",")' "$CONFIG_FILE")
    FUNNEL=$(jq -r '.funnel // false' "$CONFIG_FILE")
    LOGIN_SERVER=$(jq -r '.login_server // "https://controlplane.tailscale.com"' "$CONFIG_FILE")
    PROXY=$(jq -r '.proxy // false' "$CONFIG_FILE")
    PROXY_PORT=$(jq -r '.proxy_and_funnel_port // "443"' "$CONFIG_FILE")
    SNAT_SUBNET_ROUTES=$(jq -r '.snat_subnet_routes // true' "$CONFIG_FILE")
    STATEFUL_FILTERING=$(jq -r '.stateful_filtering // false' "$CONFIG_FILE")
    TAGS=$(jq -r '.tags | join(",")' "$CONFIG_FILE")
    TAILDROP=$(jq -r '.taildrop // true' "$CONFIG_FILE")
    USERSPACE=$(jq -r '.userspace_networking // true' "$CONFIG_FILE")
    
    # 設置環境變量參數
    ENV_PARAMS=""
    EXTRA_ARGS=""
    
    # 添加accept_dns
    if [ "$ACCEPT_DNS" = "true" ]; then
        ENV_PARAMS="$ENV_PARAMS -e TS_ACCEPT_DNS=true"
    else
        ENV_PARAMS="$ENV_PARAMS -e TS_ACCEPT_DNS=false"
    fi
    
    # 添加accept_routes
    if [ "$ACCEPT_ROUTES" = "true" ]; then
        EXTRA_ARGS="$EXTRA_ARGS --accept-routes"
    fi
    
    # 添加advertise_exit_node
    if [ "$ADVERTISE_EXIT_NODE" = "true" ]; then
        EXTRA_ARGS="$EXTRA_ARGS --advertise-exit-node"
    fi
    
    # 添加advertise_connector
    if [ "$ADVERTISE_CONNECTOR" = "true" ]; then
        EXTRA_ARGS="$EXTRA_ARGS --advertise-connector"
    fi
    
    # 添加advertise_routes
    if [ ! -z "$ADVERTISE_ROUTES" ]; then
        ENV_PARAMS="$ENV_PARAMS -e TS_ROUTES=$ADVERTISE_ROUTES"
    fi
    
    # 添加funnel
    if [ "$FUNNEL" = "true" ]; then
        EXTRA_ARGS="$EXTRA_ARGS --funnel"
    fi
    
    # 添加login_server
    if [ ! -z "$LOGIN_SERVER" ]; then
        EXTRA_ARGS="$EXTRA_ARGS --login-server=$LOGIN_SERVER"
    fi
    
    # 添加proxy
    if [ "$PROXY" = "true" ]; then
        EXTRA_ARGS="$EXTRA_ARGS --https-proxy"
    fi
    
    # 添加proxy_port
    if [ ! -z "$PROXY_PORT" ]; then
        ENV_PARAMS="$ENV_PARAMS -e TS_PORT=$PROXY_PORT"
    fi
    
    # 添加snat_subnet_routes
    if [ "$SNAT_SUBNET_ROUTES" = "true" ]; then
        EXTRA_ARGS="$EXTRA_ARGS --snat-subnet-routes=true"
    else
        EXTRA_ARGS="$EXTRA_ARGS --snat-subnet-routes=false"
    fi
    
    # 添加stateful_filtering
    if [ "$STATEFUL_FILTERING" = "true" ]; then
        EXTRA_ARGS="$EXTRA_ARGS --stateful-filtering=true"
    fi
    
    # 添加tags
    if [ ! -z "$TAGS" ]; then
        EXTRA_ARGS="$EXTRA_ARGS --advertise-tags=$TAGS"
    fi
    
    # 添加taildrop
    if [ "$TAILDROP" = "true" ]; then
        ENV_PARAMS="$ENV_PARAMS -e TS_TAILDROP=true"
    else
        ENV_PARAMS="$ENV_PARAMS -e TS_TAILDROP=false"
    fi
    
    # 添加userspace_networking
    if [ "$USERSPACE" = "true" ]; then
        ENV_PARAMS="$ENV_PARAMS -e TS_USERSPACE=true"
    else
        ENV_PARAMS="$ENV_PARAMS -e TS_USERSPACE=false"
    fi
    
    # 設置最終的EXTRA_ARGS環境變量
    if [ ! -z "$EXTRA_ARGS" ]; then
        ENV_PARAMS="$ENV_PARAMS -e TS_EXTRA_ARGS=\"$EXTRA_ARGS\""
    fi
    
    echo "配置環境變量: $ENV_PARAMS"
else
    echo "配置文件 $CONFIG_FILE 不存在，使用默認設置"
    ENV_PARAMS=""
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
  $ENV_PARAMS \
  ${IMAGE_NAME}:${TAG}

echo "容器已啟動！"
```

## 預期結果

1. 所有 options.json 中的配置項都能正確轉換為 Docker 環境變量
2. 多個 TS_EXTRA_ARGS 參數能夠合併為一個字符串，避免相互覆蓋
3. 用戶能夠通過修改 options.json 文件來完整配置 Tailscale 容器 