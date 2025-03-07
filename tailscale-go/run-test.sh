#!/bin/bash

# 創建測試目錄
mkdir -p test-data
mkdir -p test-share/taildrop

# 設置權限
chmod 755 test-data
chmod 755 test-share/taildrop

# 運行程式
echo "啟動 Tailscale 附加元件 (Go 版本)..."
echo "測試程序將在 10 秒後自動退出"

# 使用後台運行和 sleep 實現超時功能
go run cmd/tailscale-ha/main.go --config test-config.json --test --sim &
PID=$!

# 等待 10 秒
sleep 10

# 檢查進程是否還在運行
if kill -0 $PID 2>/dev/null; then
    echo "測試超時，正在終止程序..."
    kill $PID
    echo "測試執行完成 (超時正常退出)"
else
    echo "測試執行完成 (程序自行退出)"
fi 