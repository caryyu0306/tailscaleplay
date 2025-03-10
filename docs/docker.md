# Docker 環境中使用 Tailscale

本文檔詳細說明如何在 Docker 環境中使用 Tailscale。

## 前提條件

- 已安裝 Docker
- 已安裝 Git（用於克隆代碼庫）
- 基本的命令行知識

## 快速開始

1. 克隆代碼庫：
   ```bash
   git clone https://github.com/yourusername/tailscale-go.git
   cd tailscale-go
   ```

2. 複製配置文件：
   ```bash
   cp config.json.example options.json
   ```

3. 根據需要修改 `options.json` 文件

4. 構建 Docker 映像：
   ```bash
   # 對於 macOS x86 (Intel)
   ./docker-build-mac-x86.sh
   
   # 對於其他平台，使用相應的腳本
   ```

5. 運行 Docker 容器：
   ```bash
   # 對於 macOS x86 (Intel)
   ./docker-run-mac-x86.sh
   
   # 對於其他平台，使用相應的腳本
   ```

## 配置選項

Docker 容器的配置主要通過 `options.json` 文件進行。運行腳本會自動讀取此文件並將配置轉換為相應的環境變量。

詳細的配置選項請參閱 [配置指南](configuration.md)。

## 運行腳本說明

本專案提供了多個運行腳本，適用於不同的操作系統和架構：

- `docker-run-mac-arm.sh`: 適用於 macOS ARM (Apple Silicon)
- `docker-run-mac-x86.sh`: 適用於 macOS x86 (Intel)
- `docker-run-linux-arm.sh`: 適用於 Linux ARM
- `docker-run-linux-x86.sh`: 適用於 Linux x86
- `docker-run-win-arm.bat`: 適用於 Windows ARM
- `docker-run-win-x86.bat`: 適用於 Windows x86

這些腳本會：
1. 檢查並停止已存在的容器
2. 創建必要的數據目錄
3. 從 `options.json` 讀取配置並轉換為環境變量
4. 啟動容器並顯示認證 URL

## 環境變量說明

運行腳本會將 `options.json` 中的配置轉換為以下 Docker 環境變量：

| options.json 選項 | Docker 環境變量 |
|-------------------|----------------|
| accept_dns        | TS_ACCEPT_DNS  |
| accept_routes     | TS_ACCEPT_ROUTES |
| advertise_exit_node | TS_EXTRA_ARGS=--advertise-exit-node |
| advertise_routes  | TS_ROUTES      |
| login_server      | TS_LOGIN_SERVER |
| tags              | TS_TAGS |
| userspace_networking | TS_USERSPACE |

此外，腳本還會設置以下環境變量，用於持續性服務：

| 環境變量 | 說明 |
|---------|------|
| TS_STATE_DIR | Tailscale 狀態存儲目錄，設置為 `/data` |
| TS_AUTH_ONCE | 設置為 `true`，容器重啟時如果已經登錄，就不會強制重新登錄 |

## 持續性服務（非臨時節點）

默認情況下，本專案已配置為持續性服務（非臨時節點），這意味著：

1. Tailscale 狀態會保存在持久卷中（`docker-data` 目錄）
2. 容器重啟後會保持相同的 IP 地址和身份
3. 不需要重新認證

這與 Tailscale 的默認行為不同，默認情況下 Tailscale 在容器中運行時是臨時節點（Ephemeral node），每次容器重啟都會獲得新的 IP 地址和身份。

持續性服務是通過以下設置實現的：

- **持久存儲**：
  - 掛載 `docker-data` 目錄到容器的 `/data` 目錄
  - 設置 `TS_STATE_DIR=/data` 環境變量，指示 Tailscale 將狀態存儲在此目錄

- **保持登錄狀態**：
  - 設置 `TS_AUTH_ONCE=true` 環境變量，這樣容器重啟時如果已經登錄，就不會強制重新登錄

## 自動登錄

您可以使用 Tailscale 認證密鑰（Auth Key）來實現自動登錄，無需手動訪問認證 URL：

```bash
./tailscale.sh run --authkey=tskey-auth-xxxxxxxxxxxxxxxx
```

要獲取認證密鑰：

1. 訪問 Tailscale 管理控制台：https://login.tailscale.com/admin/settings/keys
2. 點擊 "Generate auth key"
3. 選擇以下選項：
   - **Reusable**：如果您希望密鑰可以多次使用
   - **Ephemeral: No**：這一點非常重要！選擇 "No" 確保節點不是臨時的
   - **Pre-approved**：如果您希望節點自動獲得批准，無需管理員手動批准
4. 設置有效期（例如 90 天）
5. 點擊 "Generate key"
6. 複製生成的密鑰（格式如 `tskey-auth-xxxxxxxxxxxxxxxx`）

使用認證密鑰的好處：

- 無需手動訪問認證 URL
- 適合自動化部署
- 可以預先設置節點權限和標籤

**注意**：請妥善保管您的認證密鑰，它可以用來訪問您的 Tailscale 網絡。

## 數據持久化

容器使用以下卷進行數據持久化：

- `./docker-data:/data`: 存儲 Tailscale 狀態和配置
- `./docker-share:/share`: 用於 Taildrop 文件共享

## 故障排除

如果您在使用 Docker 容器時遇到問題，可以嘗試以下步驟：

1. 檢查容器日誌：
   ```bash
   docker logs tailscale-ha
   ```

2. 重新啟動容器：
   ```bash
   docker restart tailscale-ha
   ```

3. 重新構建映像並運行容器：
   ```bash
   ./docker-build-mac-x86.sh
   ./docker-run-mac-x86.sh
   ```

更多故障排除信息，請參閱 [故障排除指南](troubleshooting.md)。 