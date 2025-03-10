#!/bin/bash

# 設置變量
IMAGE_NAME="tailscale/tailscale"
CONTAINER_NAME="tailscale-ha"
TAG="latest"
OUTPUT_FILE="docker-compose.yml"

# 顯示幫助信息
show_help() {
    echo "用法: $0 [選項] [命令]"
    echo ""
    echo "命令:"
    echo "  run              運行 Tailscale 容器"
    echo "  compose          生成 docker-compose.yml 文件"
    echo ""
    echo "選項:"
    echo "  --help, -h       顯示幫助信息"
    echo "  --tag=TAG        指定 Tailscale 映像標籤 (默認: latest)"
    echo "  --name=NAME      指定容器名稱 (默認: tailscale-ha)"
    echo "  --output=FILE    指定輸出文件名 (默認: docker-compose.yml)"
    echo "  --authkey=KEY    指定 Tailscale 認證密鑰"
    echo ""
    exit 0
}

# 處理命令行參數
COMMAND=""
for arg in "$@"; do
    case $arg in
        run)
            COMMAND="run"
            shift
            ;;
        compose)
            COMMAND="compose"
            shift
            ;;
        --help|-h)
            show_help
            ;;
        --tag=*)
            TAG="${arg#*=}"
            shift
            ;;
        --name=*)
            CONTAINER_NAME="${arg#*=}"
            shift
            ;;
        --output=*)
            OUTPUT_FILE="${arg#*=}"
            shift
            ;;
        --authkey=*)
            AUTH_KEY="${arg#*=}"
            shift
            ;;
        *)
            # 未知參數
            ;;
    esac
done

# 如果沒有指定命令，顯示幫助信息
if [ -z "$COMMAND" ]; then
    show_help
fi

# 檢測平台和架構
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    if [[ "$(uname -m)" == "arm64" ]]; then
        # ARM (Apple Silicon)
        PLATFORM="linux/arm64"
    else
        # x86 (Intel)
        PLATFORM="linux/amd64"
    fi
elif [[ "$(uname)" == "Linux" ]]; then
    # Linux
    if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
        # ARM
        PLATFORM="linux/arm64"
    else
        # x86
        PLATFORM="linux/amd64"
    fi
else
    # 默認 (可能是 Windows 或其他平台)
    PLATFORM="linux/amd64"
    echo "無法自動檢測平台，使用默認設置"
    echo "如果您使用的是 Windows，請手動編輯生成的 docker-compose.yml 文件"
fi

echo "檢測到平台: $(uname) $(uname -m)"
echo "使用平台: $PLATFORM"
echo "使用映像: $IMAGE_NAME:$TAG"

# 檢查 jq 是否可用
if ! command -v jq &> /dev/null; then
    echo "錯誤: 未找到 jq 命令，請安裝 jq"
    echo "macOS: brew install jq"
    echo "Linux: apt-get install jq 或 yum install jq"
    exit 1
fi

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
    LOG_LEVEL=$(jq -r '.log_level // "info"' "$CONFIG_FILE")
    LOGIN_SERVER=$(jq -r '.login_server // "https://controlplane.tailscale.com"' "$CONFIG_FILE")
    PROXY=$(jq -r '.proxy // false' "$CONFIG_FILE")
    PROXY_PORT=$(jq -r '.proxy_and_funnel_port // "443"' "$CONFIG_FILE")
    SNAT_SUBNET_ROUTES=$(jq -r '.snat_subnet_routes // true' "$CONFIG_FILE")
    STATEFUL_FILTERING=$(jq -r '.stateful_filtering // false' "$CONFIG_FILE")
    TAGS=$(jq -r '.tags | join(",")' "$CONFIG_FILE")
    TAILDROP=$(jq -r '.taildrop // true' "$CONFIG_FILE")
    USERSPACE=$(jq -r '.userspace_networking // true' "$CONFIG_FILE")
    
    # 設置環境變量
    ENV_VARS=""
    ENV_PARAMS=""
    
    # 添加accept_dns
    if [ "$ACCEPT_DNS" = "true" ]; then
        ENV_VARS="$ENV_VARS      - TS_ACCEPT_DNS=true\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_ACCEPT_DNS=true"
    else
        ENV_VARS="$ENV_VARS      - TS_ACCEPT_DNS=false\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_ACCEPT_DNS=false"
    fi
    
    # 添加accept_routes
    if [ "$ACCEPT_ROUTES" = "true" ]; then
        ENV_VARS="$ENV_VARS      - TS_ACCEPT_ROUTES=true\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_ACCEPT_ROUTES=true"
    else
        ENV_VARS="$ENV_VARS      - TS_ACCEPT_ROUTES=false\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_ACCEPT_ROUTES=false"
    fi
    
    # 添加advertise_exit_node
    if [ "$ADVERTISE_EXIT_NODE" = "true" ]; then
        ENV_VARS="$ENV_VARS      - TS_EXTRA_ARGS=--advertise-exit-node\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_EXTRA_ARGS=--advertise-exit-node"
    fi
    
    # 添加advertise_connector
    if [ "$ADVERTISE_CONNECTOR" = "true" ]; then
        ENV_VARS="$ENV_VARS      - TS_ADVERTISE_CONNECTOR=true\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_ADVERTISE_CONNECTOR=true"
    fi
    
    # 添加advertise_routes
    if [ ! -z "$ADVERTISE_ROUTES" ]; then
        ENV_VARS="$ENV_VARS      - TS_ROUTES=$ADVERTISE_ROUTES\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_ROUTES=$ADVERTISE_ROUTES"
    fi
    
    # 添加funnel
    if [ "$FUNNEL" = "true" ]; then
        ENV_VARS="$ENV_VARS      - TS_FUNNEL=true\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_FUNNEL=true"
    fi
    
    # 添加log_level
    if [ ! -z "$LOG_LEVEL" ] && [ "$LOG_LEVEL" != "info" ]; then
        ENV_VARS="$ENV_VARS      - TS_LOG_LEVEL=$LOG_LEVEL\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_LOG_LEVEL=$LOG_LEVEL"
    fi
    
    # 添加login_server
    if [ ! -z "$LOGIN_SERVER" ]; then
        ENV_VARS="$ENV_VARS      - TS_LOGIN_SERVER=$LOGIN_SERVER\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_LOGIN_SERVER=$LOGIN_SERVER"
    fi
    
    # 添加proxy
    if [ "$PROXY" = "true" ]; then
        ENV_VARS="$ENV_VARS      - TS_PROXY=true\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_PROXY=true"
    else
        ENV_VARS="$ENV_VARS      - TS_PROXY=false\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_PROXY=false"
    fi
    
    # 添加proxy_port
    if [ ! -z "$PROXY_PORT" ]; then
        ENV_VARS="$ENV_VARS      - TS_PORT=$PROXY_PORT\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_PORT=$PROXY_PORT"
    fi
    
    # 添加snat_subnet_routes
    if [ "$SNAT_SUBNET_ROUTES" = "true" ]; then
        ENV_VARS="$ENV_VARS      - TS_SNAT_SUBNET_ROUTES=true\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_SNAT_SUBNET_ROUTES=true"
    else
        ENV_VARS="$ENV_VARS      - TS_SNAT_SUBNET_ROUTES=false\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_SNAT_SUBNET_ROUTES=false"
    fi
    
    # 添加stateful_filtering
    if [ "$STATEFUL_FILTERING" = "true" ]; then
        ENV_VARS="$ENV_VARS      - TS_STATEFUL_FILTERING=true\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_STATEFUL_FILTERING=true"
    else
        ENV_VARS="$ENV_VARS      - TS_STATEFUL_FILTERING=false\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_STATEFUL_FILTERING=false"
    fi
    
    # 添加tags
    if [ ! -z "$TAGS" ]; then
        ENV_VARS="$ENV_VARS      - TS_TAGS=$TAGS\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_TAGS=$TAGS"
    fi
    
    # 添加taildrop
    if [ "$TAILDROP" = "true" ]; then
        ENV_VARS="$ENV_VARS      - TS_TAILDROP=true\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_TAILDROP=true"
    else
        ENV_VARS="$ENV_VARS      - TS_TAILDROP=false\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_TAILDROP=false"
    fi
    
    # 添加userspace_networking
    if [ "$USERSPACE" = "true" ]; then
        ENV_VARS="$ENV_VARS      - TS_USERSPACE=true\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_USERSPACE=true"
    else
        ENV_VARS="$ENV_VARS      - TS_USERSPACE=false\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_USERSPACE=false"
    fi
    
    # 添加持續性服務所需的環境變量
    ENV_VARS="$ENV_VARS      - TS_STATE_DIR=/data\n"
    ENV_PARAMS="$ENV_PARAMS -e TS_STATE_DIR=/data"
    
    ENV_VARS="$ENV_VARS      - TS_AUTH_ONCE=true\n"
    ENV_PARAMS="$ENV_PARAMS -e TS_AUTH_ONCE=true"
    
    # 如果提供了認證密鑰，則添加 TS_AUTHKEY 環境變量
    if [ ! -z "$AUTH_KEY" ]; then
        ENV_VARS="$ENV_VARS      - TS_AUTHKEY=$AUTH_KEY\n"
        ENV_PARAMS="$ENV_PARAMS -e TS_AUTHKEY=$AUTH_KEY"
    fi
    
    echo "配置環境變量已生成"
else
    echo "配置文件 $CONFIG_FILE 不存在，使用默認設置"
    ENV_VARS=""
    ENV_PARAMS=""
fi

# 根據命令執行相應的操作
if [ "$COMMAND" = "run" ]; then
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
      --platform=${PLATFORM} \
      --hostname ${CONTAINER_NAME} \
      --restart unless-stopped \
      --cap-add NET_ADMIN \
      --cap-add NET_RAW \
      --device /dev/net/tun \
      -v $(pwd)/docker-data:/data \
      -v $(pwd)/docker-share:/share \
      -p 41641:41641/udp \
      ${ENV_PARAMS} \
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
            AUTH_URL=$(echo "$LOGS" | grep -A 3 "To authenticate, visit:" | grep "https://" | tr -d ' \t')
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
    
    if [ "$TAILSCALE_READY" = false ]; then
        echo "Tailscale 啟動超時，請檢查容器日誌："
        echo "docker logs -f ${CONTAINER_NAME}"
    fi
    
    # 提醒用戶需要在管理控制台中批准出口節點
    if [ "$ADVERTISE_EXIT_NODE" = "true" ]; then
        echo ""
        echo "注意：您已將此設備設置為出口節點 (Exit Node)。"
        echo "您需要在 Tailscale 管理控制台中批准此設備作為出口節點："
        echo "1. 打開 https://login.tailscale.com/admin/machines"
        echo "2. 找到設備 ${CONTAINER_NAME}"
        echo "3. 點擊省略號圖標菜單，打開「編輯路由設置」面板"
        echo "4. 啟用「用作出口節點」選項"
        echo ""
    fi
elif [ "$COMMAND" = "compose" ]; then
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
    
    # 提醒用戶需要在管理控制台中批准出口節點
    if [ "$ADVERTISE_EXIT_NODE" = "true" ]; then
        echo ""
        echo "注意：您已將此設備設置為出口節點 (Exit Node)。"
        echo "啟動容器後，您需要在 Tailscale 管理控制台中批准此設備作為出口節點："
        echo "1. 打開 https://login.tailscale.com/admin/machines"
        echo "2. 找到設備 ${CONTAINER_NAME}"
        echo "3. 點擊省略號圖標菜單，打開「編輯路由設置」面板"
        echo "4. 啟用「用作出口節點」選項"
        echo ""
    fi
fi 