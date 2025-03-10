# 添加 Docker Compose 配置文件的自動生成

## 問題描述

目前專案提供了 docker-compose.yml 文件，但它不會自動使用 options.json 中的配置。用戶需要手動修改 docker-compose.yml 文件來添加環境變量，這增加了使用難度並可能導致配置錯誤。

## 建議改進

添加一個腳本，根據 options.json 自動生成 docker-compose.yml 文件，使其包含所有必要的環境變量。

## 實現方案

1. 創建一個新腳本 `generate-docker-compose.sh`，讀取 options.json 並生成 docker-compose.yml
2. 支持所有配置選項，並將它們轉換為相應的環境變量
3. 提供不同平台的版本（如 mac-arm, mac-x86, linux-arm, linux-x86）

## 示例代碼

```bash
#!/bin/bash

# 設置變量
IMAGE_NAME="tailscale-ha"
TAG="latest"
CONTAINER_NAME="tailscale-ha"
OUTPUT_FILE="docker-compose.yml"

# 檢測平台
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    if [[ "$(uname -m)" == "arm64" ]]; then
        # ARM (Apple Silicon)
        TAG="mac-arm"
        PLATFORM="linux/arm64"
    else
        # x86 (Intel)
        TAG="mac-x86"
        PLATFORM="linux/amd64"
    fi
elif [[ "$(uname)" == "Linux" ]]; then
    # Linux
    if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
        # ARM
        TAG="linux-arm"
        PLATFORM="linux/arm64"
    else
        # x86
        TAG="linux-x86"
        PLATFORM="linux/amd64"
    fi
else
    # 默認
    TAG="latest"
    PLATFORM="linux/amd64"
fi

echo "檢測到平台: $(uname) $(uname -m), 使用標籤: $TAG, 平台: $PLATFORM"

# 從options.json讀取配置
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
    
    # 構建環境變量列表
    ENV_VARS=""
    EXTRA_ARGS=""
    
    # 添加accept_dns
    if [ "$ACCEPT_DNS" = "true" ]; then
        ENV_VARS="$ENV_VARS      - TS_ACCEPT_DNS=true\n"
    else
        ENV_VARS="$ENV_VARS      - TS_ACCEPT_DNS=false\n"
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
        ENV_VARS="$ENV_VARS      - TS_ROUTES=$ADVERTISE_ROUTES\n"
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
        ENV_VARS="$ENV_VARS      - TS_PORT=$PROXY_PORT\n"
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
        ENV_VARS="$ENV_VARS      - TS_TAILDROP=true\n"
    else
        ENV_VARS="$ENV_VARS      - TS_TAILDROP=false\n"
    fi
    
    # 添加userspace_networking
    if [ "$USERSPACE" = "true" ]; then
        ENV_VARS="$ENV_VARS      - TS_USERSPACE=true\n"
    else
        ENV_VARS="$ENV_VARS      - TS_USERSPACE=false\n"
    fi
    
    # 設置最終的EXTRA_ARGS環境變量
    if [ ! -z "$EXTRA_ARGS" ]; then
        ENV_VARS="$ENV_VARS      - TS_EXTRA_ARGS=\"$EXTRA_ARGS\"\n"
    fi
    
    echo "配置環境變量已生成"
else
    echo "配置文件 $CONFIG_FILE 不存在，使用默認設置"
    ENV_VARS=""
fi

# 生成docker-compose.yml文件
cat > $OUTPUT_FILE << EOF
version: '3'

services:
  $CONTAINER_NAME:
    image: $IMAGE_NAME:$TAG
    container_name: $CONTAINER_NAME
    platform: $PLATFORM
    hostname: $CONTAINER_NAME
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
      - "41641:41641/udp"
    environment:
$(echo -e "$ENV_VARS")
EOF

echo "Docker Compose 配置文件已生成: $OUTPUT_FILE"
echo "您可以使用以下命令啟動容器:"
echo "docker-compose up -d"
```

## 預期結果

1. 用戶可以通過運行 `generate-docker-compose.sh` 腳本自動生成 docker-compose.yml 文件
2. 生成的 docker-compose.yml 文件包含所有來自 options.json 的配置
3. 腳本會自動檢測平台並使用適當的映像標籤
4. 用戶可以直接使用 `docker-compose up -d` 命令啟動容器，無需手動修改配置 