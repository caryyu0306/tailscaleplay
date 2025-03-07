#!/bin/sh

# 顯示主機名和環境信息
echo "========================================================"
echo "容器主機名: $(hostname)"
echo "系統信息: $(uname -a)"
echo "========================================================"

# 確保目錄存在
mkdir -p /data
mkdir -p /share/taildrop

# 創建 tmpfs 目錄用於 socket
mkdir -p /tmp/tailscale
chmod 1777 /tmp/tailscale

# 檢查網絡配置
echo "網絡配置:"
ip addr show
echo "========================================================"

# 檢查 tun 設備
echo "檢查 tun 設備:"
ls -la /dev/net/tun
echo "========================================================"

# 啟動 tailscaled
echo "啟動 tailscaled..."
/usr/local/bin/tailscaled --state=/data/tailscale/tailscaled.state --socket=/tmp/tailscale/tailscaled.sock --tun=userspace-networking &
TAILSCALED_PID=$!
sleep 2

# 檢查 tailscaled 是否正在運行
if kill -0 $TAILSCALED_PID 2>/dev/null; then
    echo "tailscaled 已成功啟動，PID: $TAILSCALED_PID"
else
    echo "錯誤: tailscaled 啟動失敗"
    exit 1
fi

# 運行 tailscale up 命令並直接輸出認證 URL
echo "配置 tailscale..."
AUTH_OUTPUT=$(/usr/local/bin/tailscale --socket=/tmp/tailscale/tailscaled.sock up --accept-risk=lose-ssh --reset --qr --login-server=https://controlplane.tailscale.com --accept-dns=true --accept-routes=true --advertise-exit-node 2>&1)

# 檢查命令是否成功
if [ $? -ne 0 ]; then
    echo "錯誤: tailscale up 命令失敗"
    echo "$AUTH_OUTPUT"
    exit 1
fi

# 提取並顯示認證 URL
echo ""
echo "========================================================"
echo "$AUTH_OUTPUT" | grep -A 1 "To authenticate, visit:" | head -n 2
echo "========================================================"
echo ""

# 顯示 QR 碼
echo "$AUTH_OUTPUT" | grep -A 50 "^█" | head -n 50

# 保持容器運行
echo "Tailscale 已啟動，請使用上面的 URL 進行認證"
echo "容器將保持運行狀態..."

# 設置定期檢查
while true; do
    # 檢查 tailscaled 是否仍在運行
    if ! kill -0 $TAILSCALED_PID 2>/dev/null; then
        echo "錯誤: tailscaled 進程已終止，嘗試重新啟動..."
        /usr/local/bin/tailscaled --state=/data/tailscale/tailscaled.state --socket=/tmp/tailscale/tailscaled.sock --tun=userspace-networking &
        TAILSCALED_PID=$!
        sleep 2
    fi
    
    # 檢查 Tailscale 狀態
    TAILSCALE_STATUS=$(/usr/local/bin/tailscale --socket=/tmp/tailscale/tailscaled.sock status 2>&1)
    echo "$(date): Tailscale 狀態檢查"
    echo "$TAILSCALE_STATUS" | grep -E "^Machine|^State" || echo "$TAILSCALE_STATUS" | head -n 5
    
    # 每 60 秒檢查一次
    sleep 60
done 