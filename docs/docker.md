# Docker 環境中使用 Tailscale

本文檔詳細說明如何在 Docker 環境中使用 Tailscale。

## 前提條件

- 已安裝 Docker
- 基本的命令行知識

## 快速開始

1. 複製配置文件：
   ```bash
   cp config.json.example options.json
   ```

2. 根據需要修改 `options.json` 文件

3. 使用腳本運行 Tailscale 容器：
   ```bash
   # 構建和運行 Docker 容器
   ./tailscale.sh run
   ```

   或使用認證密鑰實現自動登錄：
   ```bash
   # 使用認證密鑰運行
   ./tailscale.sh run --authkey=tskey-auth-xxxxxxxxxxxxxxxx
   ```

4. 或者，使用 Docker Compose：
   ```bash
   # 生成 docker-compose.yml 文件
   ./tailscale.sh compose
   
   # 啟動容器
   docker compose up -d
   ```

## Docker 容器配置

Docker 容器的配置主要通過以下方式進行：

1. `options.json` 文件：最簡單的配置方式
2. 環境變量：高級用戶可以直接設置環境變量
3. 命令行參數：通過 `tailscale.sh` 腳本傳遞參數

### 使用 options.json 配置

`options.json` 文件包含了容器的配置選項。`tailscale.sh` 腳本會自動讀取此文件並將配置轉換為相應的環境變量。

詳細的配置選項請參閱 [配置指南](configuration.md)。

### 直接使用 Docker 命令

如果您想直接使用 `docker run` 命令而不使用提供的腳本，可以手動設置環境變量：

```bash
docker run -d --name tailscale-ha \
  --restart unless-stopped \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW \
  --device /dev/net/tun \
  -v $(pwd)/docker-data:/data \
  -v $(pwd)/docker-share:/share \
  -p 41641:41641/udp \
  -e TS_ACCEPT_DNS=true \
  -e TS_ACCEPT_ROUTES=true \
  -e TS_ADVERTISE_EXIT_NODE=true \
  -e TS_ROUTES="192.168.0.0/16" \
  -e TS_USERSPACE=true \
  -e TS_STATE_DIR=/data \
  -e TS_AUTH_ONCE=true \
  -e TS_AUTHKEY=tskey-auth-xxxxxxxxxxxxxxxx \
  tailscale/tailscale:latest
```

## tailscale.sh 腳本用法

`tailscale.sh` 腳本是本專案的核心工具，用於構建和運行 Tailscale 容器。

### 基本用法

```bash
# 顯示幫助信息
./tailscale.sh --help

# 運行 Tailscale 容器
./tailscale.sh run

# 生成 docker-compose.yml 文件
./tailscale.sh compose
```

### 命令行選項

| 選項 | 說明 |
|------|------|
| `--help`, `-h` | 顯示幫助信息 |
| `--tag=TAG` | 指定 Tailscale 映像標籤 (默認: latest) |
| `--name=NAME` | 指定容器名稱 (默認: tailscale-ha) |
| `--output=FILE` | 指定輸出文件名 (默認: docker-compose.yml) |
| `--authkey=KEY` | 指定 Tailscale 認證密鑰 |

### 命令

| 命令 | 說明 |
|------|------|
| `run` | 運行 Tailscale 容器 |
| `compose` | 生成 docker-compose.yml 文件 |

## 持久化存儲

本專案使用以下目錄進行持久化存儲：

- `docker-data`：存儲 Tailscale 狀態和配置
- `docker-share`：用於 Taildrop 文件共享功能

確保這些目錄在容器重啟後仍然存在，以保持 Tailscale 連接狀態。

## 自動登錄配置

使用認證密鑰可以實現自動登錄，無需手動訪問認證 URL：

```bash
./tailscale.sh run --authkey=tskey-auth-xxxxxxxxxxxxxxxx
```

要獲取認證密鑰，請訪問 Tailscale 管理控制台的 [密鑰頁面](https://login.tailscale.com/admin/settings/keys)。生成密鑰時，請確保選擇 "Ephemeral: No"，否則節點仍然會是臨時的。

## 容器功能和權限

Tailscale 容器需要以下特權才能正常運行：

- `NET_ADMIN` 和 `NET_RAW` 能力：用於配置網絡接口和路由
- `/dev/net/tun` 設備：用於創建 TUN 設備（當不使用用戶空間網絡時）

## 網絡端口

- `41641/udp`：WireGuard 和點對點連接使用的 UDP 端口

## 故障排除

如果遇到問題，請檢查：

1. 容器日誌：`docker logs tailscale-ha`
2. Tailscale 狀態：`docker exec tailscale-ha tailscale status`
3. 網絡連接：確保端口 `41641/udp` 未被防火牆阻止

更多故障排除信息，請參閱 [故障排除指南](troubleshooting.md)。 