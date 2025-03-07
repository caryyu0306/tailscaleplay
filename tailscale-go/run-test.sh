#!/bin/bash

# 創建測試目錄
mkdir -p test-data
mkdir -p test-share/taildrop

# 設置權限
chmod 755 test-data
chmod 755 test-share/taildrop

# 運行程式
echo "啟動 Tailscale Home Assistant 附加元件 (Go 版本)..."
go run cmd/tailscale-ha/main.go --config test-config.json --test --sim 